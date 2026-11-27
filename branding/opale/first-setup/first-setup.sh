#!/bin/bash
# =====================================================================
# HYBRID OS — first setup OPALE par utilisateur (Phase 2, doc 07)
# Exécuté par XDG autostart au démarrage de CHAQUE nouvelle session.
# Idempotent : marqueur ~/.config/hybrid-firstsetup.done
# Applique le look-and-feel OPALE (couleurs, wallpaper, layout dock,
# splash) + désactive le wizard Plasma standard pour cet utilisateur.
# =====================================================================
MARKER="$HOME/.config/hybrid-firstsetup.done"
[ -f "$MARKER" ] && exit 0

plasma-apply-lookandfeel -a com.hybridos.opale 2>/dev/null || true
plasma-apply-wallpaperimage \
  /usr/share/wallpapers/OpaleNuit/contents/images/3840x2160.png \
  2>/dev/null || true

mkdir -p "$HOME/.config"
touch "$MARKER"
exit 0
