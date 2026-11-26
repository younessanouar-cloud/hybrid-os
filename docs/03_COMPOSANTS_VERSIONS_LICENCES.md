# 03 — Composants, versions et licences

> État vérifié le 25 novembre 2026. **Règle** : les versions ci-dessous sont
> les courantes constatées ; le manifeste de build (créé au jalon Alpha 0.1)
> figera le **tag + digest** exacts de l'image de base. Toute dérive de
> version passera par une mise à jour du manifeste + tests CI.

## 1. Socle

| Composant | Version courante constatée (nov. 2026) | Licence | Statut |
|---|---|---|---|
| Fedora (base Atomic) | **Fedora 45** — tag stable courant de `quay.io/fedora/fedora-kinoite`, figé par digest le 25/11/2026 (API quay) ; versions constatées dans notre image (rapport CI) : kernel 7.3.4-300.fc45, Plasma 6.8.3, bootc 1.17.1, SELinux policy 45.24. **Rebase 26/11/2026** : l'amont a mis à jour le tag 45 (l'ancien digest a été retiré par le GC de quay) → manifeste mis à jour vers le nouveau digest + fenêtre de tests complète relancée — le contrôleur de dérive CI a détecté et signalé l'écart exact | Licences Fedora (GPL, MIT,…) | ✅ figée + vérifiée, rebase documenté |
| Image de base OCI | `quay.io/fedora/fedora-bootc` (officielle, KDE en variante desktop) ou image Kinoite selon disponibilité exacte au build | idem | ⚠️ choisir + figer digest |
| Noyau Linux | **7.3.4-300.fc45** constaté (rapport CI 25/11/2026) | GPLv2 | ✅ vérifié |
| bootc | outil de déploiement d'images OCI bootables (amont Fedora, « Image Mode Phase 2 ») | Apache-2.0/MIT | ✅ |
| bootc-image-builder | génération qcow2/raw/**anaconda-iso** (projet osbuild) | GPL | ✅ |
| rpm-ostree | historique ; encore présent pour le layering exceptionnel (ex. NVIDIA) | GPLv2+ | ✅ transitoire |
| systemd | ≥ 257 (chaîne Fedora) | LGPL-2.1+ | ✅ |

## 2. Bureau et graphique

| Composant | Version | Licence | Rôle |
|---|---|---|---|
| KDE Plasma | **6.8.3** constaté (rapport CI 25/11/2026, fc45) | GPLv2+ (GPL/LGPL mix) | Bureau cible ✅ |
| KF6 / Kirigami | Frameworks 6.23 constatés (F43) | LGPL/GPL | Applications natives OPALE |
| KWin / Wayland | intégré Plasma 6 | GPLv2+ | Gestionnaire de fenêtres ; XWayland pour la compat. |
| PipeWire | chaîne Fedora | MIT/LGPL | Audio/vidéo |
| Pilotes GPU | Mesa (AMD/Intel) ; NVIDIA : module propriétaire en couche testée | MIT / propriétaire | Doc 09 : matrice de tests |

## 3. Sécurité

| Composant | Version | Licence | Rôle |
|---|---|---|---|
| SELinux (policy targeted) | enforcing par défaut sur Fedora | GPL | Contrôle d'accès (doc 06) |
| cryptsetup / dm-crypt LUKS2 | chaîne Fedora | GPLv2+ | Chiffrement au repos |
| Clevis / systemd-cryptenroll | chaîne Fedora | GPL/LGPL | Liaison TPM 2.0 |
| firewalld | chaîne Fedora | GPLv2+ | Pare-feu actif par défaut |
| fwupd + LVFS | chaîne Fedora | LGPL | Firmware/UEFI, détection Secure Boot |
| shim (signé Microsoft) + GRUB2 + noyau Fedora | chaîne Fedora | BSD/GPLv2+/GPLv2 | Secure Boot v1 (doc 04) |
| sbctl / ukify (cible v2) | outils systemd | GPL/LGPL | Clés propres + UKI signés |
| cosign (Sigstore) | chaîne CI | Apache-2.0 | Signature des images OCI (ADR-008) |

## 4. Applications et compatibilité

| Composant | Licence | Rôle |
|---|---|---|
| Flatpak / Flathub (filtre vérifié) | Libre (flatpak LGPL ; apps selon licences) | Format applicatif prioritaire |
| Steam (Flatpak) + Proton | propriétaire/valve ; Proton open | Jeux — compatibilité documentée par titre |
| Wine / Bottles (Flatpak) | LGPL | Compatibilité Windows partielle, profils séparés |
| Discover / frontal Store custom (Kirigami) | GPL | Interface d'installation |

## 5. Synthèse licences — conformité

- **Tous les composants système sont libres** (GPL/LGPL/MIT/Apache/BSD) à
  l'exception : pilote NVIDIA propriétaire (optionnel, isolé), Steam
  (distribué tel quel par Valve via Flatpak).
- Obligations de redistribution : fournir les sources/scripts → **satisfaits
  par construction** (le dépôt de build est le source de l'image ; les
  licences amont sont celles de Fedora, non modifiées pour les paquets).
- **Marque** : « HYBRID OS », logo OPALE et design system = créations
  originales du projet (doc 07) — licences Creative Commons BY-SA pour les
  assets, marque nominative à part (à documenter au moment de la diffusion).
- Mentions obligatoires Fedora/Red Hat dans l'à-propos (transparence de la
  dérivation, doc 01 §5).

## 6. Risques de dépendance identifiés (détail au doc 08)

- Transition amont « Image Mode Phase 2 » : les images officielles Atomic
  migrent vers bootc — le projet **adopte la cible dès v1** pour ne pas
  hériter d'un socle en fin de vie.
- Calendrier Fedora (2 versions/an) : chaque rebase = fenêtre de test CI
  obligatoire avant diffusion (doc 09).
- Anaconda : si son intégration aux images bootc évolue, l'ISO type
  `anaconda-iso` reste la voie documentée — la couche « assistant dual boot »
  (doc 05) est conçue pour survivre à ce changement.
