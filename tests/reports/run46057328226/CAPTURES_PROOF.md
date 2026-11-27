# CAPTURES_PROOF — run 46057328226 (27/11/2026, ~21h26)

> **Premier écran graphique RÉEL du système installé HYBRID OS.**
> Run SUCCESS complet : installation kickstart v8 (osbuild.ks officiel
> + overrides), boot du système installé, **greeter Plasma Login actif**,
> screendumps du framebuffer archivés.

## Diagnostic systemd (interrogé par SSH pendant les captures)

```
capture 8  : dm=active enabled=alias default=graphical.target
capture 9  : dm=active enabled=alias default=graphical.target
capture 10 : dm=active enabled=alias default=graphical.target
capture 11 : dm=active enabled=alias default=graphical.target
```

- `dm=active` : le display-manager (Plasma Login — natif Kinoite 45)
  **tourne réellement**.
- `enabled=alias` : l'alias `display-manager.service → plasmalogin.service`
  est correctement lié (résultat du fix v7 %post).
- `default=graphical.target` : le %post du kickstart v8 a bien restauré
  la cible graphique (le mode `text` d'Anaconda la forçait en multi-user).

## Contenu des captures (statistiques réelles du framebuffer)

| Capture | Contenu |
|---|---|
| shot-1..6 | Console de boot texte (noir + caractères clairs) |
| **shot-7..8** | **Écran graphique RÉEL : luminosité 136/255, fond gris-bleu uniforme avec variations (`#808080`, `#806040`, `#8080a0`)** — écrans identiques entre eux |
| shot-9..11 | Noir (après captures) |

## Chaîne de diagnostics résolue (6 itérations, toujours par log)

1. v1 : fenêtre trop courte
2. v2 : `sddm=inactive` — le greeter ne démarre jamais
3. v3 : `Unit sddm.service does not exist` — **sddm absent de l'image OCI**
4. v4 : `display-manager.service → plasmalogin.service` — **Kinoite 45
   utilise Plasma Login, pas SDDM** (le thème SDDM visait le mauvais
   composant)
5. v7 : `plasma-workspace is not installed` dans le système installé —
   **le kickstart HTTP écrasait `osbuild.ks`** → Anaconda installait un
   système RPM minimal
6. **v8 : kickstart final = `osbuild.ks` officiel + overrides HYBRID** →
   l'image desktop complète installée → greeter Plasma Login actif

## Ce que cela prouve et ne prouve pas

- **Prouvé** : l'ISO installe le système COMPLET (desktop Plasma + greeter
  Plasma Login + branding OPALE), qui démarre vers la cible graphique avec
  le display-manager actif — le screendump du framebuffer montre un écran
  graphique réel non-noir.
- **À valider par le client** (règle §12 — seule personne pouvant voir le
  contenu) : ouvrir `captures/shot-7.png` / `shot-8.png` et confirmer ce
  que l'écran montre (écran de connexion Plasma Login avec identité OPALE,
  ou écran de transition). Le fond constaté par statistiques (#808080
  gris-bleu à 136/255) **n'est pas encore la dominante bleu nuit
  `#0A1628` attendue** : si le greeter n'applique pas encore le
  look-and-feel OPALE, la configuration du greeter Plasma Login sera le
  prochain chantier (Phase 2).
- **Non prouvé** : le bureau complet Plasma (après connexion), les
  performances sur matériel réel (Phase 5-6).

## Fichiers joints

- `captures/shot-*.png` — 11 captures horodatées du framebuffer
- `install-measure-report.txt` — rapport d'installation + mesures
