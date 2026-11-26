# Preuve du run de captures 45880139331 (26/11/2026, 20h)

> **Verdict honnête : mécanisme VALIDÉ, cible NON atteinte.**

## Ce qui est prouvé

- Job `vm-capture` SUCCESS complet : installation kickstart (2070 s),
  boot du système installé (multi-user 32,7 s, SELinux **enforcing**),
  screendumps QEMU réels archivés, conversion et statistiques OK.
- Les captures `shot-1..5` montrent la **console texte de boot réelle**
  (framebuffer VGA : fond noir, caractères des messages systemd) —
  c'est un contenu réel du démarrage de HYBRID OS, pas une maquette.
- `shot-6..7` : écran noir.

## Ce qui N'EST PAS atteint (honnêteté §12)

- **L'écran SDDM OPALE n'apparaît dans aucune capture** : la fenêtre de
  captures (~16 min après les mesures) est trop courte pour
  `graphical.target` en émulation TCG (SDDM/KWin y mettent davantage).
- Par conséquent, **aucune validation visuelle de l'identité OPALE n'est
  acquise à ce stade** — la règle §12 reste applicable aux rendus.

## Correctifs prévus (prochain run)

1. Fenêtre de captures étendue (~38 min, pas de capture avant ~10 min).
2. **Surveillance en direct** : état `sddm`/`graphical.target` interrogé
   par SSH pendant la boucle → distinguer « lent mais en route » de
   « service défaillant » (le rapport tranchera).
3. Si SDDM actif mais toujours sans écran graphique au-delà de ~40 min :
   investiguer KWin/Wayland en TCG (shader compilation très lente) —
   éventuellement réduire les effets compositing pour la capture.
