#!/bin/bash
# =====================================================================
# HYBRID OS — first setup OPALE par utilisateur (Phase 2, doc 07)
# Exécuté par XDG autostart au démarrage de CHAQUE nouvelle session.
# Idempotent : marqueur ~/.config/hybrid-firstsetup.done
# =====================================================================
# RÈGLE (§12) : AUCUNE sortie masquée — tout est journalisé dans
# ~/.config/opale-firstsetup.log pour diagnostic via SSH (phase D).
MARKER="$HOME/.config/hybrid-firstsetup.done"
LOG="$HOME/.config/opale-firstsetup.log"
[ -f "$MARKER" ] && exit 0

{
  echo "=== HYBRID first setup $(date -u '+%Y-%m-%d %H:%M:%S') user=$(whoami) ==="
  echo "--- LookAndFeelPackage (déploiement) ---"
  ls -la /usr/share/plasma/look-and-feel/com.hybridos.opale/contents/ 2>&1
  echo "--- plasma-apply-lookandfeel -a com.hybridos.opale ---"
  plasma-apply-lookandfeel -a com.hybridos.opale 2>&1 || echo "ECHEC lookandfeel code $?"
  echo "--- plasma-apply-wallpaperimage OpaleNuit ---"
  plasma-apply-wallpaperimage \
    /usr/share/wallpapers/OpaleNuit/contents/images/3840x2160.png \
    2>&1 || echo "ECHEC wallpaper code $?"
  echo "--- état après application ---"
  kreadconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage 2>&1 || true
} >> "$LOG" 2>&1

mkdir -p "$HOME/.config"
touch "$MARKER"
exit 0

