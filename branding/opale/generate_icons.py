#!/usr/bin/env python3
# =====================================================================
# HYBRID OS — Design System OPALE
# Icônes de marque au format standard hicolor (Phase 2, doc 07 §8)
#
# Stratégie v1 (documentée) : Breeze (base KDE, déjà homogène) reste le
# jeu applicatif ; les icônes de MARQUE HYBRID OS sont déclinées de la
# gemme OPALE. « start-here » est le nom standard du lanceur de menu
# (déjà référencé dans layout.js) → l'icône OPALE le remplace visuellement
# via la priorité hicolor, sans toucher au jeu Breeze.
#
# Sorties (branding/opale/icons/) : arborescence hicolor prête à COPY :
#   hicolor/<taille>/apps/start-here.png      (16 → 256)
#   hicolor/<taille>/apps/hybridos.png        (icône système)
#   hicolor/<taille>/status/hybrios-selinux-ok.png   (pastille brume, 16/22/24)
# =====================================================================
from PIL import Image, ImageDraw
import os

# Palette (doc 07 §3)
NUIT = (10, 22, 40)
NUIT2 = (14, 31, 60)
ECLAIR = (61, 123, 255)
FLAMBEE = (139, 92, 246)
BRUME = (45, 212, 191)
LUMIERE = (241, 245, 251)

TAILLES = [16, 22, 24, 32, 48, 64, 96, 128, 256]

BASE = None  # appicon-512 chargé ci-dessous


def base_appicon():
    """Reconstruit l'icône de base (fond nuit coins arrondis + gemme)."""
    S = 512
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    fond = Image.new("RGBA", (S, S))
    d = ImageDraw.Draw(fond)
    for y in range(S):
        t = y / (S - 1)
        c = tuple(int(NUIT[i] + (NUIT2[i] - NUIT[i]) * t) for i in range(3))
        d.line([(0, y), (S, y)], fill=c + (255,))
    mask = Image.new("L", (S, S), 0)
    dm = ImageDraw.Draw(mask)
    dm.rounded_rectangle([0, 0, S, S], radius=120, fill=255)
    img.paste(fond, (0, 0), mask)
    gemme = Image.open(os.path.join("logo", "hybridos-opale-plein-1024.png"))
    gemme = gemme.resize((430, 430), Image.LANCZOS)
    img.alpha_composite(gemme, (41, 41))
    return img


def export(img, chemin, taille):
    out = img.resize((taille, taille), Image.LANCZOS)
    os.makedirs(os.path.dirname(chemin), exist_ok=True)
    out.save(chemin, "PNG", optimize=True)


def pastille_selinux(taille):
    """Pastille « SELinux enforcing » : bouclier brume sur fond nuit."""
    img = Image.new("RGBA", (taille, taille), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = taille // 2
    # disque fond nuit
    d.ellipse([1, 1, taille - 2, taille - 2], fill=NUIT + (235,))
    # bouclier (forme simple)
    cx, cy = taille // 2, taille // 2
    w = max(2, taille // 5)
    d.polygon([(cx - w, cy - w), (cx + w, cy - w), (cx + w, cy),
               (cx, cy + w + 1), (cx - w, cy)], fill=BRUME + (255,))
    return img


def main():
    base = base_appicon()
    for t in TAILLES:
        export(base, os.path.join("icons", "hicolor", str(t), "apps",
                                  "start-here.png"), t)
        export(base, os.path.join("icons", "hicolor", str(t), "apps",
                                  "hybridos.png"), t)
    for t in [16, 22, 24]:
        img = pastille_selinux(t)
        chemin = os.path.join("icons", "hicolor", str(t), "status",
                              "hybrios-selinux-ok.png")
        os.makedirs(os.path.dirname(chemin), exist_ok=True)
        img.save(chemin, "PNG", optimize=True)

    total = sum(len(f) for _, _, f in os.walk(os.path.join("icons")))
    print(f"OK — {total} icônes générées dans branding/opale/icons/hicolor/")
    print("(start-here + hybridos en 9 tailles, pastille SELinux en 3 tailles)")


if __name__ == "__main__":
    main()
