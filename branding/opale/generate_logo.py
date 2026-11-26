#!/usr/bin/env python3
# =====================================================================
# HYBRID OS — Design System OPALE
# Générateur du logo « Opale facettée » (doc 07 §5)
#
# Concept (doc 07 §5) : une opale noire facettée traversée par un filet
# de lumière bleu→violet qui entre à gauche et se diffracte en étincelles
# à droite. Style géométrique « flat premium » (propre à toutes les
# tailles, lisible dès 16 px).
#
# Reproductibilité : géométrie 100 % déterministe (aucun aléa).
# Sorties (branding/opale/logo/) :
#   hybridos-opale-plein-1024.png      couleur, fond transparent
#   hybridos-opale-monochrome-1024.png monochrome lumière
#   hybridos-opale-appicon-512.png     fond nuit, coins arrondis
#   hybridos-opale-favicon-16.png      16 px
#   hybridos-opale-splash-1920x1080.png fond nuit + gemme centrée
# =====================================================================
from PIL import Image, ImageDraw, ImageFilter

S = 1024  # canvas de travail

# Palette OPALE (doc 07 §3)
NUIT = (10, 22, 40)
NUIT2 = (14, 31, 60)
NUIT3 = (19, 39, 80)
NUIT4 = (25, 50, 102)
ECLAIR = (61, 123, 255)
FLAMBEE = (139, 92, 246)
LUMIERE = (241, 245, 251)

# --- Géométrie de la gemme (canvas 1024) ---
TABLE = [(340, 300), (684, 300), (796, 452), (228, 452)]   # couronne
POINTES = [(228, 452), (796, 452), (512, 894)]              # girdle + pointe
CENTRE_C = (512, 382)                                        # centre couronne


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gemme(couleurs, alpha_base=255):
    """Dessine la gemme facettée sur fond transparent.
    couleurs = dict {fond_table, facettes..., chatoyante1, chatoyante2}"""
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # --- Pavillon : triangles du girdle vers la pointe (dégradé vertical) ---
    p1, p2, p3 = POINTES
    centre_p = (512, 640)
    d.polygon([p1, p2, centre_p], fill=couleurs["pav_g"] + (alpha_base,))
    d.polygon([p1, centre_p, p3], fill=couleurs["pav_d"] + (alpha_base,))
    d.polygon([p2, p3, centre_p], fill=couleurs["pav_g2"] + (alpha_base,))

    # --- Couronne : 4 facettes de la table vers le centre ---
    a, b, c, e = TABLE
    cc = CENTRE_C
    d.polygon([a, cc, e], fill=couleurs["courg"] + (alpha_base,))
    d.polygon([a, b, cc], fill=couleurs["table"] + (alpha_base,))
    d.polygon([b, c, cc], fill=couleurs["courd"] + (alpha_base,))
    d.polygon([c, e, cc], fill=couleurs["table2"] + (alpha_base,))

    # --- Deux facettes chatoyantes (l'identité opale) ---
    d.polygon([a, cc, (420, 300)], fill=couleurs["chat1"] + (min(200, alpha_base),))
    d.polygon([(512, 894), (650, 452), (796, 452)],
              fill=couleurs["chat2"] + (min(170, alpha_base),))

    # --- Liseré spectral : arête supérieure (bleu → violet) ---
    for i in range(0, 100):
        t = i / 99
        x0 = a[0] + (b[0] - a[0]) * t
        col = lerp(ECLAIR, FLAMBEE, t)
        d.line([(x0, 300), (x0 + 3.5, 300)], fill=col + (alpha_base,), width=4)

    # --- Rayon de lumière : entre à gauche au niveau du girdle ---
    calque = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    dc = ImageDraw.Draw(calque)
    for i in range(0, 60):
        t = i / 59
        col = lerp(LUMIERE, ECLAIR, t)
        dc.line([(30 + i * 6, 452), (30 + i * 6 + 4, 452)],
                fill=col + (int(220 * (1 - t * 0.6)),), width=3)
    calque = calque.filter(ImageFilter.GaussianBlur(2))
    img = Image.alpha_composite(img, calque)

    # --- Étincelles à droite de la pointe (diffraction) ---
    et = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    de = ImageDraw.Draw(et)
    for (cx, cy, r, col) in [(860, 700, 16, FLAMBEE), (800, 540, 11, ECLAIR),
                              (905, 560, 7, LUMIERE)]:
        de.polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)],
                   fill=col + (200,))
    et = et.filter(ImageFilter.GaussianBlur(1.5))
    img = Image.alpha_composite(img, et)
    return img


# --- 1. Version couleur (fond transparent) ---
COL = {
    "table": NUIT3, "table2": NUIT2,
    "courg": NUIT4, "courd": NUIT2,
    "pav_g": NUIT, "pav_d": NUIT2, "pav_g2": NUIT3,
    "chat1": ECLAIR, "chat2": FLAMBEE,
}
plein = gemme(COL)
plein.save("logo/hybridos-opale-plein-1024.png", "PNG", optimize=True)

# --- 2. Monochrome (lumière, fond transparent) ---
MONO = {k: LUMIERE for k in COL}
MONO["chat1"] = LUMIERE
MONO["chat2"] = lerp(LUMIERE, ECLAIR, 0.4)
mono = gemme(MONO)
mono.save("logo/hybridos-opale-monochrome-1024.png", "PNG", optimize=True)

# --- 3. App icon 512 : fond nuit + coins arrondis + gemme centrée ---
app = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
fond_icon = Image.new("RGBA", (512, 512), NUIT + (255,))
# léger dégradé vertical dans le fond
grad = ImageDraw.Draw(fond_icon)
for y in range(512):
    grad.line([(0, y), (512, y)],
              fill=lerp(NUIT, NUIT2, y / 511) + (255,))
# coins arrondis (rayon 120)
mask = Image.new("L", (512, 512), 0)
dm = ImageDraw.Draw(mask)
dm.rounded_rectangle([0, 0, 512, 512], radius=120, fill=255)
app.paste(fond_icon, (0, 0), mask)
gem = plein.copy().resize((430, 430), Image.LANCZOS)
app.alpha_composite(gem, (41, 41))
app.save("logo/hybridos-opale-appicon-512.png", "PNG", optimize=True)

# --- 4. Favicon 16 px (gemme seule, downscale LANCZOS) ---
fav = plein.copy().resize((64, 64), Image.LANCZOS).resize((16, 16), Image.LANCZOS)
fav.save("logo/hybridos-opale-favicon-16.png", "PNG", optimize=True)

# --- 5. Splash 1920x1080 : fond nuit + gemme centrée ---
splash = Image.new("RGB", (1920, 1080), NUIT)
gs = ImageDraw.Draw(splash)
for y in range(1080):
    gs.line([(0, y), (1920, y)], fill=lerp(NUIT, NUIT2, y / 1079))
gem_s = plein.copy().resize((340, 340), Image.LANCZOS)
splash = splash.convert("RGBA")
splash.alpha_composite(gem_s, ((1920 - 340) // 2, (1080 - 340) // 2 - 60))
splash.convert("RGB").save("logo/hybridos-opale-splash-1920x1080.png",
                           "PNG", optimize=True)

print("OK — 5 déclinaisons générées dans branding/opale/logo/")
