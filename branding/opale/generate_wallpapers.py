#!/usr/bin/env python3
# =====================================================================
# HYBRID OS — Design System OPALE
# Générateur du fond d'écran « Opale nuit » (doc 07)
#
# Reproductibilité : seed fixé, aucun aléa non maîtrisé. Le PNG est
# versionné dans le dépôt, ce script en est la source.
# Sortie : branding/opale/wallpapers/opale-nuit-3840x2160.png
# =====================================================================
import random
from PIL import Image, ImageDraw, ImageFilter

W, H = 3840, 2160
SEED = 42  # figé — identité visuelle stable entre les builds

# Palette OPALE (doc 07 §3)
NUIT_HAUT = (5, 11, 24)      # #050B18
NUIT_MID = (10, 22, 40)      # #0A1628  opale-nuit
NUIT_BAS = (14, 31, 60)      # #0E1F3C  opale-nuit-2
ECLAIR = (61, 123, 255)      # #3D7BFF  opale-eclair
FLAMBEE = (139, 92, 246)     # #8B5CF6  opale-flambee

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

def fond():
    """Dégradé vertical bleu nuit avec point médian opale-nuit."""
    img = Image.new("RGB", (W, H))
    px = img.load()
    for y in range(H):
        t = y / (H - 1)
        if t < 0.5:
            c = lerp(NUIT_HAUT, NUIT_MID, t * 2)
        else:
            c = lerp(NUIT_MID, NUIT_BAS, (t - 0.5) * 2)
        for x in range(0, W, 4):  # bandes de 4 px : rapide et invisible à 4K
            for k in range(4):
                if x + k < W:
                    px[x + k, y] = c
    return img

def veine(draw, rng, couleur, largeur, alpha):
    """Un filament spectral d'opale : courbe lissée traversant l'image."""
    y0 = rng.randint(int(H * 0.15), int(H * 0.85))
    points = []
    x = -200
    pas = rng.randint(180, 320)
    y = y0
    while x < W + 200:
        points.append((x, y))
        y += rng.randint(-140, 140)
        y = max(int(H * 0.05), min(int(H * 0.95), y))
        x += pas
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=couleur + (alpha,),
                  width=largeur)

def eclat(draw, centre, couleur, rayon, alpha):
    """Éclat lumineux ponctuel (inclusion d'opale)."""
    x, y = centre
    draw.ellipse([x - rayon, y - rayon, x + rayon, y + rayon],
                 fill=couleur + (alpha,))

def main():
    rng = random.Random(SEED)
    base = fond().convert("RGBA")

    # --- Calque des veines spectrales (flouté pour le chatoyement) ---
    veines = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(veines)
    for i in range(9):
        couleur = lerp(ECLAIR, FLAMBEE, rng.random())
        veine(d, rng, couleur, rng.randint(4, 14), rng.randint(40, 110))
    # Deux filaments principaux plus présents (la « signature » opale)
    for _ in range(2):
        couleur = lerp(ECLAIR, FLAMBEE, rng.random())
        veine(d, rng, couleur, rng.randint(12, 20), rng.randint(140, 180))
    veines = veines.filter(ImageFilter.GaussianBlur(10))

    # --- Éclats (zone bas-droite, comme une opale éclairée en biais) ---
    eclats = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d2 = ImageDraw.Draw(eclats)
    for _ in range(6):
        cx = rng.randint(int(W * 0.62), int(W * 0.96))
        cy = rng.randint(int(H * 0.45), int(H * 0.9))
        couleur = lerp(ECLAIR, FLAMBEE, rng.random())
        eclat(d2, (cx, cy), couleur, rng.randint(14, 42), rng.randint(60, 140))
    eclats = eclats.filter(ImageFilter.GaussianBlur(30))

    # --- Composition ---
    img = base
    img = Image.alpha_composite(img, veines)
    img = Image.alpha_composite(img, eclats)

    # --- Vignettage léger (côtés sombres, centre lumineux) ---
    vignette = Image.new("L", (W, H), 0)
    dv = ImageDraw.Draw(vignette)
    dv.ellipse([-W * 0.25, -H * 0.35, W * 1.25, H * 1.35], fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(240))
    sombre = Image.new("RGB", (W, H), (3, 7, 16))
    img = Image.composite(img.convert("RGB"), sombre, vignette)

    out = "opale-nuit-3840x2160.png"
    img.save(out, "PNG", optimize=True)
    print(f"OK — {out} ({W}x{H})")

if __name__ == "__main__":
    main()
