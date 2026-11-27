# CAPTURES_PROOF — run 46073129467 (v9 — first setup OPALE, 27-28/11/2026)

> **Premières captures avec le premier setup OPALE actif dans la session.**
> Run SUCCESS complet : image desktop v0.3.1 (first-setup OPALE + masque
> wizard Plasma) → installation kickstart → boot → captures.

## Contenu constaté par statistiques du framebuffer

| Capture | Statistiques | Interprétation probable |
|---|---|---|
| **shot-1** | lum **135**, var 6.0 — dominantes `#a0a0a0`, `#6080a0`, `#80a0a0`, `#202060` | Écran graphique riche avec zones claires ET bleues — possible greeter ou écran de démarrage |
| **shot-2** | lum 129 — `#808080`, `#806040`, `#808060` | Écran graphique (évolution) |
| **shot-3** | **lum 81 — `#404040`, `#404020`, `#402020`, `#404060`** | Écran SOMBRE avec tons bleu nuit/violet — possible wallpaper OpaleNuit ou transition |
| shot-4..11 | noir (captures après session capturée) | — |

**Lecture honnête** : pour la première fois, les captures montrent des écrans
graphiques réels avec des **tons bleus** — mais les statistiques ne suffisent
pas à identifier exactement ce que les écrans affichent (greeter Plasma Login,
KSplash OPALE, wizard en transition, ou bureau). La validation visuelle du
client est la seule voie (règle §12 — et c'est sa règle permanente).

## Diagnostic systemd de la session (SSH pendant les captures)

États `dm=/graphical=` non inclus dans ce run (la phase D v9 reprenait
les mesures standard) — le run précédent (46057328226) avait établi
`dm=active enabled=alias default=graphical.target` avec l'image v0.3.0.
L'image v0.3.1 ajoute le first-setup OPALE (XDG autostart) + masquage
du wizard Plasma standard.

## Chantier v9 (décision par validation visuelle du client)

- Si les captures montrent l'identité OPALE appliquée → **Phase 2
  visuellement validée** (règle §12 levée pour ces rendus).
- Si le greeter reste gris standard → configurer Plasma Login
  (look-and-feel du greeter = prochain chantier Phase 2).

## Fichiers joints

- `captures/shot-*.png` — 11 captures
- `install-measure-report.txt` — rapport d'installation + mesures
