#!/usr/bin/env bash
# =====================================================================
# HYBRID OS — Smoke test d'amorçage en VM (Alpha 0.1, étape 6)
# =====================================================================
# MÉTHODE (honnêteté — ce que ce test prouve et ne prouve pas) :
#   Il prouve : le noyau + initrd de NOTRE ISO démarrent sous UEFI
#   (firmware OVMF), que systemd s'initialise et que le chargeur
#   d'installation Anaconda (stage2 embarqué dans l'ISO) se lance.
#   Il NE prouve PAS : le menu GRUB complet (le direct-kernel-boot
#   saute GRUB), le mode graphique, l'installation, le dual boot.
#   Le chemin GRUB complet et l'installation seront validés à l'étape
#   suivante (doc 10) et par tests interactifs documentés.
#
# ENVIRONNEMENT : QEMU SANS KVM (TCG = émulation logicielle, lente) —
# fonctionne aussi bien en CI (runner GitHub) qu'en local. Budget
# temps généreux + timeout dur obligatoire.
#
# ⚠ À AJUSTER SUR L'ISO RÉELLE (produite par le run CI étape 5) :
#   chemins des fichiers dans l'ISO et format de grub.cfg — les
#   valeurs actuelles suivent la structure standard des ISO
#   anaconda-iso Fedora, à vérifier par listing au premier run.
# =====================================================================
set -euo pipefail

ISO="${1:?Usage : smoke_boot.sh <chemin ISO>}"
TIMEOUT_S="${2:-2400}"          # 40 min max (TCG : un boot peut être long)
RAM_MB="${3:-4096}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
LOG="$WORK/serial.log"

echo "== Smoke boot : $ISO (timeout ${TIMEOUT_S}s, ${RAM_MB} Mo RAM) =="

# ---------------------------------------------------------------------
# 1. Vérifications préalables
# ---------------------------------------------------------------------
command -v qemu-system-x86_64 >/dev/null || {
  echo "qemu-system-x86_64 absent — installer : apt install qemu-system-x86 ovmf" >&2; exit 2; }
[ -f "$ISO" ] || { echo "ISO introuvable : $ISO" >&2; exit 2; }

# OVMF (firmware UEFI) — méthode pflash CANONIQUE (CODE + copie VARS) :
# -bios seul avec OVMF 4M moderne peut refuser de démarrer.
OVMF_CODE=""
for f in /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_CODE.fd \
         /usr/share/ovmf/OVMF_CODE.fd; do
  [ -f "$f" ] && OVMF_CODE="$f" && break
done
[ -n "$OVMF_CODE" ] || { echo "OVMF_CODE introuvable — apt install ovmf" >&2; exit 2; }
OVMF_VARS_SRC=""
for f in /usr/share/OVMF/OVMF_VARS_4M.fd /usr/share/OVMF/OVMF_VARS.fd \
         /usr/share/ovmf/OVMF_VARS.fd; do
  [ -f "$f" ] && OVMF_VARS_SRC="$f" && break
done
[ -n "$OVMF_VARS_SRC" ] || { echo "OVMF_VARS introuvable — apt install ovmf" >&2; exit 2; }
cp "$OVMF_VARS_SRC" "$WORK/vars.fd"   # copie : QEMU écrit les variables NVRAM
echo "Firmware UEFI : $OVMF_CODE (+ VARS $OVMF_VARS_SRC)"

# ---------------------------------------------------------------------
# 2. Extraire noyau + initrd + grub.cfg depuis l'ISO
#    (bsdtar/libarchive lit ISO9660 ; installer libarchive-tools)
# ---------------------------------------------------------------------
command -v bsdtar >/dev/null || {
  echo "bsdtar absent — installer : apt install libarchive-tools" >&2; exit 2; }

echo "== Extraction vmlinuz / initrd / grub.cfg depuis l'ISO =="
bsdtar -xf "$ISO" -C "$WORK" \
  images/pxeboot/vmlinuz images/pxeboot/initrd.img EFI/BOOT/grub.cfg \
  || { echo "Extraction échouée : STRUCTURE ISO À AJUSTER (voir listing bsdtar -tf)" >&2
       bsdtar -tf "$ISO" | head -40 >&2; exit 2; }

KERNEL="$WORK/images/pxeboot/vmlinuz"
INITRD="$WORK/images/pxeboot/initrd.img"
GRUBCFG="$WORK/EFI/BOOT/grub.cfg"
for f in "$KERNEL" "$INITRD" "$GRUBCFG"; do
  [ -f "$f" ] || { echo "Fichier extrait manquant : $f" >&2; exit 2; }
done

# ---------------------------------------------------------------------
# 3. Reconstituer la ligne de démarrage de l'entrée par défaut
#    (fidélité au boot réel : mêmes paramètres stage2 que GRUB)
#    + console série pour capturer la sortie.
# ---------------------------------------------------------------------
# Ligne « linux ... inst.stage2=... » de l'entrée par défaut :
STAGE2_LINE=$(grep -m1 -E '^[[:space:]]*linux' "$GRUBCFG" | head -1 || true)
if [ -z "$STAGE2_LINE" ]; then
  echo "Aucune ligne 'linux' dans grub.cfg — FORMAT À AJUSTER" >&2
  grep -n . "$GRUBCFG" | head -30 >&2; exit 2
fi
# Paramètres kernel après le chemin (3e champ et au-delà) :
APPEND=$(echo "$STAGE2_LINE" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i}')
# Retirer « quiet » (on veut la trace) et rediriger sur la console série :
APPEND="$(echo "$APPEND" | sed 's/\bquiet\b//') console=ttyS0,115200"
echo "Paramètres kernel : $APPEND"

# ---------------------------------------------------------------------
# 4. Amorcer la VM (UEFI + ISO attachée, noyau direct, série sur log)
# ---------------------------------------------------------------------
echo "== Démarrage QEMU (TCG, UEFI pflash) — capture série dans $LOG =="
set +e
timeout "${TIMEOUT_S}" qemu-system-x86_64 \
  -machine q35 -cpu max -smp 2 -m "${RAM_MB}" \
  -display none -serial file:"$LOG" \
  -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE" \
  -drive "if=pflash,format=raw,file=$WORK/vars.fd" \
  -kernel "$KERNEL" -initrd "$INITRD" \
  -append "$APPEND" \
  -cdrom "$ISO" \
  -net none >"$WORK/qemu-stderr.log" 2>&1
RC=$?
set -e

echo "== Fin QEMU (code $RC ; 124 = timeout prévu en smoke test) =="
# Le stderr de QEMU n'est JAMAIS masqué (règle : diagnostic honnête)
if [ -s "$WORK/qemu-stderr.log" ]; then
  echo "--- stderr QEMU (à archiver avec la trace) ---"
  cat "$WORK/qemu-stderr.log"
fi

# ---------------------------------------------------------------------
# 5. Analyser la trace série — critères de succès explicites
# ---------------------------------------------------------------------
[ -f "$LOG" ] || { echo "Aucune sortie série capturée : ÉCHEC" >&2; exit 1; }

echo "--- Trace série (extrait) ---"
tail -40 "$LOG" || true

echo "== Marqueurs d'amorçage =="

check() {  # marqueur, description
  if grep -q "$1" "$LOG"; then
    echo "✅ $2"
    return 0
  else
    echo "❌ $2"
    return 1
  fi
}

FAIL=0
check "Linux version"      "le noyau de l'ISO a démarré"            || FAIL=1
check "Reached target"    "systemd a atteint une cible"               || FAIL=1
# Marqueur de l'installeur (l'un ou l'autre selon le mode atteint) :
if grep -qE "Starting Installer|anaconda|Anaconda" "$LOG"; then
  echo "✅ le chargeur d'installation Anaconda s'est lancé"
else
  echo "❌ le chargeur d'installation Anaconda s'est lancé"; FAIL=1
fi

# Rapport (traçabilité doc 09 §6)
mkdir -p tests/reports
cp "$LOG" "tests/reports/smoke-boot-serial.log" 2>/dev/null || true
cp "$WORK/qemu-stderr.log" "tests/reports/qemu-stderr.log" 2>/dev/null || true
echo "Trace complète archivée : tests/reports/smoke-boot-serial.log"

if [ "$FAIL" -eq 1 ]; then
  echo "SMOKE TEST : ÉCHEC (détails dans la trace série ci-dessus)" >&2
  exit 1
fi
echo "SMOKE TEST : RÉUSSI — l'ISO HYBRID OS amorce en VM UEFI (noyau + systemd + Anaconda)."
