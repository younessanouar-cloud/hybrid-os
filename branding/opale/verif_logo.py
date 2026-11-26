from PIL import Image
import os

for f in ['hybridos-opale-plein-1024.png', 'hybridos-opale-monochrome-1024.png',
          'hybridos-opale-appicon-512.png', 'hybridos-opale-favicon-16.png',
          'hybridos-opale-splash-1920x1080.png']:
    path = os.path.join('logo', f)
    img = Image.open(path).convert('RGBA')
    px = list(img.getdata())
    opaques = [p for p in px if p[3] > 200]
    if opaques:
        bleus = sum(1 for p in opaques if p[2] > p[0] + 10)
        pct = round(100 * bleus / len(opaques))
    else:
        pct = 0
    taille = os.path.getsize(path) // 1024
    print(f"{f}: {img.size}, {pct}% pixels bleu dominant, {taille} Ko")
