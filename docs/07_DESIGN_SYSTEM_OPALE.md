# 07 — HYBRID Design System : **OPALE**

> Chapitre obligatoire du cahier des charges (demande client) : identité
> graphique originale de HYBRID OS. Maquettes de référence :
> `branding/reference/maquette_conceptuelle_v1.png` — **concepts illustratifs
> non fonctionnels** ; les indicateurs visibles devront être branchés sur de
> vraies données système.

## 1. Pourquoi « OPALE » ? (décision ADR-007)

### Le nom « Aurora » est éliminé
Vérifié le 25/11/2026 : **Aurora est déjà une distribution Linux réelle**
(Universal Blue, getaurora.dev) basée sur… la même stack Fedora Kinoite KDE.
Conserver ce nom = collision de marque directe sur le même segment. Il a
aussi été éliminé : « Prism » (rétro-acronisme NSA — rédhibitoire pour un OS
sécurité), « Vega » (AMD GPU), « Halo » (Microsoft), « Opal » seul en anglais
(trop générique).

### Ce que l'opale apporte à HYBRID OS
L'opale est **l'objet hybride par excellence** :
- **Hybride dans sa matière** : silice + eau, structure amorphe — elle n'a
  pas de réseau cristallin rigide, comme notre système : modulaire, pas
  monolithique.
- **Le chatoyement** (play-of-color) : UNE pierre, UNE lumière, mais un
  spectre selon l'angle — exactement la mission HYBRID OS : une seule base
  cohérente, plusieurs expériences (Windows-like, macOS-like, Linux-like).
- **L'opale noire** est la variété la plus précieuse — notre fond bleu nuit
  profond, mesuré sur la maquette du client (dominantes #001830/#001848).
- **Résonance positive et assumée** : « TCG Opal » est le standard du
  chiffrement matériel des SSD — dans l'univers d'un OS axé sécurité, cette
  résonance est un clin d'œil favorable, pas une collision (aucun OS majeur
  ne porte ce nom).

**Nom complet** : **HYBRID OS — Design System OPALE**.

## 2. Concept innovant : le « Chatoyement adaptatif »

OPALE n'est pas un simple thème figé. Son principe signature : **l'accent du
système change de teinte selon le profil actif**, comme une opale selon
l'angle d'observation — tandis que le fond, la typographie et la géométrie
restent constants (l'identité ne se perd jamais) :

| Profil système | Accent actif | Teinte OPALE |
|---|---|---|
| Équilibré (défaut) | Bleu électrique | `opale-eclair` |
| Performances / Gaming | Violet spectral | `opale-flambee` |
| Économie d'énergie | Aigue-marine | `opale-brume` |
| Sécurité (alertes/centre) | Violet | `opale-flambee` |

Un seul token d'accent (`--opale-accent`) propage la teinte à tout le bureau
(dock, liserés, focus, curseur) — implémentation QML/Kirigami dans les
thèmes Plasma. Les profils sont **réellement** ceux du gestionnaire
d'énergie (doc 02) : le visuel reflète un état système vrai, pas un décor.

## 3. Palette (tokens) — alignée sur la maquette mesurée

| Token | Hex | Usage |
|---|---|---|
| `opale-nuit` | `#0A1628` | Fond principal (dominante maquette : #001830) |
| `opale-nuit-2` | `#0E1F3C` | Surfaces |
| `opale-nuit-3` | `#132750` | Surfaces élevées / focus |
| `opale-eclair` | `#3D7BFF` | Accent principal — Équilibré |
| `opale-flambee` | `#8B5CF6` | Accent — Gaming/Sécurité |
| `opale-brume` | `#2DD4BF` | Accent — Économie ; succès |
| `opale-ambre` | `#F59E0B` | Avertissements |
| `opale-rouge` | `#E5484D` | Erreurs/critique |
| `opale-lumiere` | `#F1F5FB` | Texte principal |
| `opale-lumiere-2` | `#A8B3CC` | Texte secondaire |
| Liseré spectral | dégradé `#3D7BFF → #8B5CF6` | Arêtes « verre » |

**Iridescence (verre)** : surfaces translucides (flou réel, pas une image)
avec liseré spectral bleu→violet en arête supérieure — composition propre
à HYBRID OS, distincte des glass effects Windows/macOS.

**Mode clair « Opale blanche »** : opale laiteuse — mêmes accents, fonds
`#F4F7FD`/`#E9EEF8` — livré avec le thème sombre (exigence §5 du cahier
des charges), pas en option ultérieure.

## 4. Typographie

- **Interface** : Inter (variable, hinting excellent, licence OFL) —
  gratuite, largement installée, excellent rendu Wayland.
- **Terminal** : IBM Plex Mono (OFL).
- Deux poids principaux (Regular/ SemiBold) + métriques figées dans les
  thèmes — pas de « police de démonstration » non libre.

## 5. Logo (concept à produire en Phase 2)

- **Forme** : une **opale noire facettée** (gemme arrondie à facettes
  géométriques) traversée par un **filet de lumière bleu→violet** qui
  entre à gauche et se diffracte en petit spectre à droite.
- Déclinaisons : plein couleur · monochrome `opale-lumiere` · app icon
  carrée · favicon 16 px (la gemme seule + l'éclat) · KSplash/SDDM.
- Règles d'usage : marges, fonds interdits (pas sur photo chargée), taille
  mini — documentées dans `branding/` au moment de la production (Phase 2).

## 6. Composants graphiques réutilisables (bibliothèque OPALE)

| Composant | Description |
|---|---|
| Carte verre | Panneau translucide, liseré spectral, ombre douce |
| Bouton gemme | Rectangulaire arrondi, accent = profil actif ; états hover/focus visibles au clavier |
| Dock « Filon » | Barre centrale ou basse, verre + indicateurs réels (CPU/RAM/réseau — vraies sources, doc 02) |
| Notification « Éclat » | Toast translucide, bord accent selon sévérité |
| Centre de contrôle rapide | Panneau coulissant : réseau/son/énergie/profils |
| Lanceur « Diffraction » | Recherche universelle (apps, fichiers, réglages, calculs) |
| Jauges « Chatoyement » | Indicateurs circulaires d'accent — **v1 : branchées sur de vraies métriques système** |

## 7. Accessibilité (exigence §5 du cahier des charges)

- Contrastes : texte principal `opale-lumiere` sur `opale-nuit` ≈ 13:1 (AAA) ;
  accents testés ≥ 4.5:1 (AA) sur leurs fonds.
- **Réduction d'animations** : option système (aussi détectée : `prefers-reduced-motion`) — les transitions OPALE s'effacent proprement.
- Navigation clavier complète (focus visible = liseré spectral), tailles de
  police système respectées, daltonisme : les accents ne portent JAMAIS
  seuls une information (icône + forme + libellé).

## 8. Intégration KDE Plasma 6 (voie technique)

| Élément | Implémentation |
|---|---|
| Plasma Theme + couleurs | Thème OPALE (SVG/QML), schéma de couleurs standard |
| Décorations KWin | Thème boutons/gemmes + effets transparence (Wayland) |
| Dock/lanceur | Panels Plasma custom (layouts livrés) — pas de dépendance à des docks tiers abandonnés |
| Icônes | Jeu dérivé de jeux libres OFL (recolré OPALE) — création originale, jamais extrait d'icônes propriétaires |
| SDDM/KSplash | Écrans d'accueil OPALE |
| Applications natives | Bibliothèque Kirigami de composants OPALE (§6) partagée |

## 9. Statut — ce qui existe / ce qui reste à produire

- **Existe aujourd'hui** : direction, tokens, palette (mesurée sur la
  maquette), règles d'accessibilité — **ce document**.
- **À produire en Phase 2** : logo (5 déclinaisons), icônes, thèmes Plasma
  complets, bibliothèque QML, maquettes par application (Store, Security
  Center, Paramètres…).
- **Interdiction permanente** (règle §12) : aucune capture d'écran d'une
  maquette ne sera présentée comme capture du système réel.
