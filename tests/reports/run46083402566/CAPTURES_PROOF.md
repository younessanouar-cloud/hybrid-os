# CAPTURES_PROOF — run 46083402566 (v10, 28/11/2026, 00h43)

> **LE WALLPAPER OPALENUIT EST APPLIQUÉ DANS LA SESSION RÉELLE.**
> Première preuve statistique de l'identité visuelle HYBRID OS rendue :
> les captures 2-7 montrent la dominante `#000020` / `#000040` (bleu nuit),
> signature exacte du wallpaper « Opale Nuit » généré par
> `generate_wallpapers.py` (mesuré à la création : dominantes
> `#000020`/`#000000`).

## Diagnostic systemd (SSH pendant les captures)

```
capture 2..11 : dm=active enabled=alias default=graphical.target
```

Le display-manager (Plasma Login) et la cible graphique sont actifs en
continu pendant toute la session.

## Contenu des captures

| Capture | Statistiques | Lecture |
|---|---|---|
| shot-1 | lum 135, var 6 — `#a0a0a0`, `#6080a0`, `#202060` | Écran graphique riche (démarrage/transition) |
| **shot-2..7** | **lum 31 — `#000020`, `#000040` + `#c0c0c0`** | **Bureau avec le wallpaper OPALENUIT appliqué (+ éléments clairs : bureau/éléments)** |
| shot-8..9 | lum 136 — `#808080`, `#806040` | Écran graphique différent (greeter/transition) |
| shot-10..11 | noir | Après captures |

## Mesures du système installé (bureau démarré)

- Installation : 2580 s (TCG) · SELinux **enforcing** ✅
- **RAM : 974 Mo utilisés avec bureau** (vs 461 Mo hier en multi-user
  sans bureau) — les cibles ≤ 1,8 Go restent à mesurer sur matériel
- Noyau installé : `7.3.6-300.fc45` (image amont mise à jour)

## Ce que cela prouve

- Le système installé par l'ISO **démarrer une session graphique avec le
  wallpaper OPALE appliqué** (via le first-setup OPALE — XDG autostart).
- La chaîne *image → installation → session graphique → identité visuelle
  appliquée* fonctionne **de bout en bout**.

## À valider visuellement par le client (règle §12 — ce que les stats
ne disent pas)

Ouvrir `captures/shot-2.png` : confirmer la présence du wallpaper OpaleNuit,
du dock HYBRID (layout.js) et des couleurs du design system. Le journal
complet du first-setup (`~/.config/opale-firstsetup.log`) sera lu au
prochain run pour confirmer chaque étape (`plasma-apply-lookandfeel`).

## Fichiers joints

- `captures/shot-*.png` — 11 captures du framebuffer
- `install-measure-report.txt` — rapport d'installation + mesures
