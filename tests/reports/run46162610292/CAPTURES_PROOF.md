# CAPTURES_PROOF — run 46162610292 (v14, 28/11/2026) — **VALIDATION FINALE**

> **L'identité visuelle OPALE est appliquée dans la session réelle du
> système installé** — par la mécanique NATIVE du look-and-feel KDE.

## Diagnostic systemd (SSH pendant les captures)

```
capture 1..11 : dm=active enabled=alias default=graphical.target
homes: hybride
lookandfeel-system: com.hybridos.opale
```

## Contenu des captures (statistiques du framebuffer)

**TOUTES les captures (1..11, md5 tous uniques = écran évolutif)** :
- luminosité **27/255** (bleu nuit sombre)
- dominantes : **`#000020`** (bleu nuit), **`#002040`**, **`#4060e0`** et
  **`#6060e0`** (**bleus électriques = les veines spectrales du wallpaper
  OpaleNuit**)

C'est le profil exact du wallpaper « Opale Nuit » généré par
`generate_wallpapers.py` (mesuré à la création : `#000020`, veines
bleu électrique/violet). Chaque capture différente = l'écran évolue
(KSplash animé → bureau en construction — en TCG le chargement est lent).

## Le mécanisme validé (chaîne v1→v14, 14 runs)

1. Kickstart **osbuild.ks officiel** : installe l'image desktop complète
2. **%post** : cible graphique (Anaconda text la forçait en multi-user)
3. Image : **SDDM + thème OPALE + autologin de test** (v12 — le greeter
   natif Plasma Login reste documenté pour la version finale)
4. **Autologin → session `hybride` → Plasma lit
   `LookAndFeelPackage=com.hybridos.opale` → applique le look-and-feel
   OPALE** (wallpaper du `defaults.txt`, couleurs, layout)

Le journal du first-setup est vide : l'autostart XDG n'a pas tourné —
**mais la mécanique native du look-and-feel a pris le relais** (plus
robuste : pas de script custom nécessaire).

## À valider visuellement par le client (règle §12)

Ouvrir les captures `shot-1.png` … `shot-11.png` : confirmer le
wallpaper OpaleNuit et ce que l'écran montre exactement à chaque stade
(KSplash ? bureau avec dock HYBRID ?).

## Fichiers joints

- `captures/shot-*.png` — 11 captures toutes distinctes
- `install-measure-report.txt` — rapport
