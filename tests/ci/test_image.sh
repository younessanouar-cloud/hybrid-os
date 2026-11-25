#!/usr/bin/env bash
# =====================================================================
# HYBRID OS — tests CI niveau 1 (image OCI, en conteneur)
# Alpha 0.1, étape 1 (plan docs/10). Ce script ne teste QUE ce que
# l'étape 1 peut prouver : l'image se construit, démarre en conteneur,
# et contient les composants attendus de la base Atomic KDE.
# Il NE teste PAS l'amorçage (niveau VM — étapes suivantes du plan).
#
# RÈGLE (cahier des charges §12) : échec explicite et immédiat ;
# aucune tolérance silencieuse ; tout résultat est affiché.
# =====================================================================
set -euo pipefail

IMAGE="${1:?Usage : test_image.sh <image>}"

fail() { echo "❌ TEST ÉCHOUÉ : $1" >&2; exit 1; }
ok()   { echo "✅ $1"; }

echo "Image testée : $IMAGE"
echo ""

echo "== Test 1 : le conteneur démarre et rend la main =="
podman run --rm "$IMAGE" /bin/true || fail "le conteneur ne démarre pas"
ok "le conteneur démarre"

echo "== Test 2 : paquets système attendus présents =="
for pkg in bootc systemd kernel-core selinux-policy-targeted plasma-workspace grub2-efi-x64; do
  podman run --rm "$IMAGE" rpm -q "$pkg" >/dev/null 2>&1 \
    || fail "paquet absent de l'image : $pkg"
  ok "paquet présent : $pkg"
done

echo "== Test 3 : binaires critiques présents =="
for bin in /usr/bin/bootc /usr/bin/plasmashell /usr/bin/systemctl /usr/bin/kwin_wayland; do
  podman run --rm "$IMAGE" test -x "$bin" \
    || fail "binaire absent ou non exécutable : $bin"
  ok "binaire présent : $bin"
done

echo "== Test 4 : bootc opérationnel dans l'image =="
podman run --rm "$IMAGE" bootc --version || fail "bootc --version échoue"
ok "bootc opérationnel"

echo "== Test 5 : policy SELinux targeted installée =="
podman run --rm "$IMAGE" bash -c \
  '[ -n "$(ls -A /etc/selinux/targeted/policy/ 2>/dev/null)" ]' \
  || fail "policy SELinux targeted absente de l'image"
ok "policy SELinux targeted présente"

echo ""
echo "TOUS LES TESTS NIVEAU 1 SONT PASSÉS pour $IMAGE"
echo "Rappel honnêteté : ceci NE prouve PAS que l'image amorce (niveau VM)."
