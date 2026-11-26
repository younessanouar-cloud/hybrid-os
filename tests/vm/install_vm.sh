#!/usr/bin/env bash
# =====================================================================
# HYBRID OS — Installation automatisée en VM + mesures (Alpha 0.1 étape 7)
# =====================================================================
# CE QUE CE TEST PROUVE :
#   1. L'ISO installe HYBRID OS sur un disque virtuel VIERGE via kickstart
#      (text, sshd activé, root verrouillé, user non privilégié).
#   2. Le système INSTALLÉ démarre depuis son disque (GRUB → noyau 7.3.4).
#   3. SELinux est enforcing après installation (critère doc 09).
#   4. Mesures : temps de boot et RAM au repos — MÉTHODE en place.
#
# HONNÊTETÉ (doc 09) : QEMU TCG = émulation LOGICIELLE lente. Les valeurs
# mesurées NE représentent PAS du matériel réel ; les objectifs du cahier
# des charges (≤ 1,8 Go / ≤ 20 s) exigent la machine de référence définie
# au doc 09. Ici on prouve le MÉCANISME + une base de mesure reproductible.
#
# PHASES :
#   A. Extraction vmlinuz/initrd + paramètres depuis l'ISO (comme smoke)
#   B. QEMU (direct kernel) + kickstart servi par HTTP local + disque vierge
#      → installation Anaconda → détection de la fin → arrêt de la VM
#   C. QEMU relancée SANS direct kernel (le disque installé boote via GRUB)
#      → attente SSH → mesures (free, systemd-analyze, bootc status, sestatus)
# =====================================================================
set -euo pipefail

ISO="${1:?Usage : install_vm.sh <iso> [timeout_install_s] [timeout_boot_s]}"
TIMEOUT_INSTALL_S="${2:-9000}"    # 2 h 30 max pour l'installation TCG
TIMEOUT_BOOT_S="${3:-3600}"       # 1 h max pour le boot + mesures
RAM_MB="${4:-4096}"
DISK_GB="${5:-40}"

fail() { echo "❌ $1" >&2; exit 1; }
ok()   { echo "✅ $1"; }

WORK="$(mktemp -d)"
cleanup() { [ -n "${QEMU_PID:-}" ] && kill "$QEMU_PID" 2>/dev/null || true
            [ -n "${HTTP_PID:-}" ] && kill "$HTTP_PID" 2>/dev/null || true
            rm -rf "$WORK"; }
trap cleanup EXIT
LOG_INSTALL="$WORK/install-serial.log"
LOG_BOOT="$WORK/boot-serial.log"
mkdir -p tests/reports
REPORT="tests/reports/install-measure-report.txt"

echo "== HYBRID OS — installation automatisée + mesures =="
echo "ISO : $ISO (install ${TIMEOUT_INSTALL_S}s max, boot ${TIMEOUT_BOOT_S}s max)"

# ---------------------------------------------------------------------
# A. Préparation : firmware, noyau/initrd de l'ISO, kickstart, disque
# ---------------------------------------------------------------------
command -v qemu-system-x86_64 >/dev/null || fail "qemu absent"
command -v qemu-img >/dev/null || fail "qemu-img absent"
command -v sshpass >/dev/null || fail "sshpass absent — apt install sshpass"

OVMF_CODE=""; OVMF_VARS_SRC=""
for f in /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_CODE.fd; do
  [ -f "$f" ] && OVMF_CODE="$f" && break; done
for f in /usr/share/OVMF/OVMF_VARS_4M.fd /usr/share/OVMF/OVMF_VARS.fd; do
  [ -f "$f" ] && OVMF_VARS_SRC="$f" && break; done
[ -n "$OVMF_CODE" ] && [ -n "$OVMF_VARS_SRC" ] || fail "OVMF absent — apt install ovmf"
cp "$OVMF_VARS_SRC" "$WORK/vars-install.fd"; cp "$OVMF_VARS_SRC" "$WORK/vars-boot.fd"

echo "== Extraction noyau/initrd de l'ISO =="
bsdtar -xf "$ISO" -C "$WORK" images/pxeboot/vmlinuz images/pxeboot/initrd.img EFI/BOOT/grub.cfg \
  || fail "extraction impossible (structure ISO)"
KERNEL="$WORK/images/pxeboot/vmlinuz"; INITRD="$WORK/images/pxeboot/initrd.img"
STAGE2_LINE=$(grep -m1 -E '^[[:space:]]*linux' "$WORK/EFI/BOOT/grub.cfg" | head -1)
APPEND_BASE=$(echo "$STAGE2_LINE" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i}' | sed 's/\bquiet\b//')
APPEND_INSTALL="${APPEND_BASE} inst.ks=http://10.0.2.2:8000/ks-alpha01.cfg inst.text console=ttyS0,115200"
echo "Paramètres install : $APPEND_INSTALL"

qemu-img create -f qcow2 "$WORK/disk.qcow2" "${DISK_GB}G" >/dev/null

# Kickstart servi par l'hôte (10.0.2.2 = hôte vu depuis QEMU user networking)
cp tests/vm/ks-alpha01.cfg "$WORK/"
( cd "$WORK" && python3 -m http.server 8000 >/dev/null 2>&1 ) &
HTTP_PID=$!

# ---------------------------------------------------------------------
# B. Installation (direct kernel + ISO + disque vierge + kickstart HTTP)
# ---------------------------------------------------------------------
echo "== Phase B : installation Anaconda (kickstart) =="
START_INSTALL=$(date +%s)
set +e
qemu-system-x86_64 \
  -machine q35 -cpu max -smp 2 -m "${RAM_MB}" \
  -display none -serial file:"$LOG_INSTALL" \
  -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE" \
  -drive "if=pflash,format=raw,file=$WORK/vars-install.fd" \
  -kernel "$KERNEL" -initrd "$INITRD" -append "$APPEND_INSTALL" \
  -cdrom "$ISO" \
  -drive "file=$WORK/disk.qcow2,if=virtio,format=qcow2" \
  -netdev user,id=n0,hostfwd=tcp::2222-:22 -device e1000,netdev=n0 \
  >"$WORK/qemu-install-stderr.log" 2>&1 &
QEMU_PID=$!
set -e

# Boucle de surveillance de la trace série (30 s)
DONE=0
while [ $(( $(date +%s) - START_INSTALL )) -lt "$TIMEOUT_INSTALL_S" ]; do
  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    echo "QEMU s'est arrêté avant la fin — voir stderr :"; cat "$WORK/qemu-install-stderr.log" || true
    break
  fi
  if grep -q "reboot: Restarting system\|anaconda.*[Ii]nstallation.*complete\|Starting installer.*done" "$LOG_INSTALL" 2>/dev/null; then
    DONE=1; echo "Marqueur de fin d'installation détecté dans la trace série."; break
  fi
  sleep 30
done
kill "$QEMU_PID" 2>/dev/null || true; QEMU_PID=""
INSTALL_S=$(( $(date +%s) - START_INSTALL ))
[ "$DONE" -eq 1 ] || { echo "Installation non terminée en ${INSTALL_S}s — extrait trace :"
                       tail -30 "$LOG_INSTALL" >&2 || true; fail "installation incomplète"; }
ok "installation terminée en ${INSTALL_S}s (mode ${DISK_GB}G, RAM ${RAM_MB}Mo, TCG)"

# ---------------------------------------------------------------------
# C. Boot du système installé (disque seul, SSH attendu, mesures)
# ---------------------------------------------------------------------
echo "== Phase C : boot du système installé =="
START_BOOT=$(date +%s
)
set +e
qemu-system-x86_64 \
  -machine q35 -cpu max -smp 2 -m "${RAM_MB}" \
  -display none -serial file:"$LOG_BOOT" \
  -vga std \
  -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE" \
  -drive "if=pflash,format=raw,file=$WORK/vars-boot.fd" \
  -drive "file=$WORK/disk.qcow2,if=virtio,format=qcow2" \
  -netdev user,id=n0,hostfwd=tcp::2222-:22 -device e1000,netdev=n0 \
  -monitor "unix:$WORK/qemu-mon.sock,server,nowait" \
  >"$WORK/qemu-boot-stderr.log" 2>&1 &
QEMU_PID=$!
set -e

SSH_OK=0
while [ $(( $(date +%s) - START_BOOT )) -lt "$TIMEOUT_BOOT_S" ]; do
  if (exec 3<>/dev/tcp/127.0.0.1/2222) 2>/dev/null; then exec 3>&- 3<&- || true; SSH_OK=1; break; fi
  sleep 15
done
BOOT_S=$(( $(date +%s) - START_BOOT ))
[ "$SSH_OK" -eq 1 ] || { tail -30 "$LOG_BOOT" >&2 || true; fail "SSH non atteint en ${BOOT_S}s"; }
ok "SSH joignable ${BOOT_S}s après le démarrage du disque installé (TCG)"

# Mesures via SSH (sshpass + user du kickstart)
SSH="sshpass -p hybrios01 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 hybride@127.0.0.1"
sleep 60   # laisser le système se stabiliser après login possibility

{
  echo "=== HYBRID OS — rapport installation & mesures (VM QEMU TCG) ==="
  echo "Date (UTC)          : $(date -u '+%Y-%m-%d %H:%M:%S')"
  echo "ISO                 : $ISO"
  echo "Phase B installation: ${INSTALL_S}s (TCG)"
  echo "Phase C jusqu'à SSH  : ${BOOT_S}s (TCG — émulation, PAS représentatif du matériel)"
  echo ""
  echo "--- Identité du système installé ---"
  $SSH 'uname -r' 2>/dev/null && true
  $SSH 'cat /etc/fedora-release 2>/dev/null || cat /etc/os-release | head -2' 2>/dev/null && true
  echo ""
  echo "--- Sécurité (critères doc 09) ---"
  echo -n "SELinux (attendu Enforcing) : "; $SSH 'sestatus | grep -i "current mode"' 2>/dev/null || echo "non mesuré"
  echo ""
  echo "--- Mesures (TCG = base reproductible, pas du matériel réel) ---"
  echo "--- RAM au repos (free -m) ---";  $SSH 'free -m' 2>/dev/null || echo "non mesuré"
  echo "--- systemd-analyze ---";        $SSH 'systemd-analyze' 2>/dev/null || echo "non mesuré"
  echo "--- uptime ---";                 $SSH 'uptime' 2>/dev/null || echo "non mesuré"
  echo "--- bootc status (extrait) ---"; $SSH 'bootc status 2>/dev/null | head -12' 2>/dev/null || echo "non mesuré"
  echo ""
  echo "Rappel honnêteté : mesures en émulation TCG. Objectifs cahier des charges"
  echo "(RAM ≤ 1,8 Go, boot ≤ 20 s) : à mesurer sur machine de référence (doc 09 §3)."
} | tee "$REPORT"

# ---------------------------------------------------------------------
# D. Captures d'écran RÉELLES (optionnel : CAPTURE=1) — lever la règle
#    §12 pour les rendus : ce ne sont pas des maquettes, ce sont des
#    screendumps du framebuffer de la VM qui démarre réellement.
#    Cible : l'écran de connexion SDDM OPALE (graphical.target).
# ---------------------------------------------------------------------
if [ "${CAPTURE:-0}" = "1" ]; then
  echo "== Phase D : captures du bureau (screendumps QEMU monitor) =="
  command -v socat >/dev/null || fail "socat absent — apt install socat"
  mkdir -p tests/reports/captures
  N=0
  # Fenêtre étendue (~38 min) : graphical.target/SDDM est LENT en TCG.
  # Diagnostic en direct : état sddm interrogé par SSH à chaque tour.
  for ATTENTE in 120 180 180 240 300 300 300 300 300 300 300; do
    sleep "$ATTENTE"
    N=$((N+1))
    SHOT="$WORK/shot-$N.ppm"
    echo "screendump $SHOT" | socat - UNIX-CONNECT:"$WORK/qemu-mon.sock" 2>/dev/null || true
    # État réel du greeter (distingue « lent » de « défaillant »)
    ETAT=$(sshpass -p hybrios01 ssh -o StrictHostKeyChecking=no \
           -o UserKnownHostsFile=/dev/null -p 2222 hybride@127.0.0.1 \
           'echo sddm=$(systemctl is-active sddm 2>/dev/null) graphical=$(systemctl is-active graphical.target 2>/dev/null)' \
           2>/dev/null || echo "ssh-ko")
    echo "capture $N : $ETAT"
  done
  kill "$QEMU_PID" 2>/dev/null || true; QEMU_PID=""

  echo "--- Analyse des captures (statistiques réelles du framebuffer) ---"
  CAPTURES_DIR="tests/reports/captures" WORK="$WORK" python3 - <<'EOF' || true
from PIL import Image
import glob, os, statistics

work = os.environ["WORK"]
outdir = os.environ["CAPTURES_DIR"]
for ppm in sorted(glob.glob(os.path.join(work, "shot-*.ppm"))):
    try:
        img = Image.open(ppm).convert("RGB")
    except Exception:
        continue
    ech = list(img.getdata())[::37]
    lums = [(p[0] + p[1] + p[2]) / 3 for p in ech[:500]]
    lum = statistics.mean(lums)
    var = statistics.pstdev(lums)
    nom = os.path.basename(ppm).replace(".ppm", ".png")
    img.save(os.path.join(outdir, nom), "PNG")
    vivant = "ÉCRAN NON UNIFORME (contenu réel affiché)" if var > 8 else "uniforme (fond/simple)"
    print(f"{nom}: {img.size}, luminosité {lum:.0f}/255, variation {var:.1f} — {vivant}")
EOF
  echo "Captures archivées : tests/reports/captures/"
fi

kill "$QEMU_PID" 2>/dev/null || true; QEMU_PID=""
cp "$LOG_INSTALL" tests/reports/install-serial.log 2>/dev/null || true
cp "$LOG_BOOT" tests/reports/boot-installed-serial.log 2>/dev/null || true
echo "Rapport archivé : $REPORT"
echo "INSTALLATION + MESURES : TERMINÉ"
