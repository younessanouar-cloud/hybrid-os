# 00 — Sommaire du dossier de conception & journal des décisions

> **Statut : Phase 1 (conception). Soumis à validation avant toute génération de code.**
> Date des vérifications : 25 novembre 2026. Sources : documentations officielles
> Fedora/KDE/bootc et état de l'écosystème vérifié par recherche (listées par document).

## Sommaire du dossier

| N° | Document | Contenu |
|---|---|---|
| 01 | ANALYSE_FAISABILITE | Verdict argumenté, preuves d'existence, contraintes, conditions |
| 02 | ARCHITECTURE_TECHNIQUE | Architecture cible, modules, alternatives comparées |
| 03 | COMPOSANTS_VERSIONS_LICENCES | Inventaire des composants, versions, licences, statut de vérification |
| 04 | BOOT_SECUREBOOT_DUALBOOT | Chaîne de démarrage, Secure Boot, GRUB vs UKI, BitLocker |
| 05 | INSTALLATEUR_DUALBOOT | Anaconda vs Calamares vs bootc, parcours d'installation |
| 06 | SECURITE | Défense en profondeur, Security Center, risques résiduels |
| 07 | DESIGN_SYSTEM_OPALE | Identité graphique HYBRID (chapitre obligatoire du cahier des charges) |
| 08 | REGISTRE_RISQUES | Risques techniques et projet, probabilité/impact/mitigation |
| 09 | PLAN_TESTS | Pyramide de tests, machines de référence, méthodes de mesure |
| 10 | PLAN_ALPHA_01 | Plan précis du premier jalon : ISO amorçable en machine virtuelle |

## Journal des décisions (ADR)

| ID | Date | Décision | Motif principal | Statut |
|---|---|---|---|---|
| ADR-001 | 2026-11-25 | Base = image OCI bootable Fedora Atomic (voie `bootc`), dérivée KDE, **pas de noyau maison** | Voie officiellement soutenue par Fedora (Image Mode Phase 2, 2026), prouvée par des distributions dérivées existantes | Validée (25/11/2026) |
| ADR-002 | 2026-11-25 | Construction d'image **100 % en CI (GitHub Actions)**, pas en local | Machine de développement locale insuffisante (8 Go RAM, CPU faible) ; runners publics gratuits suffisants | Validée (25/11/2026) |
| ADR-003 | 2026-11-25 | Bureau = KDE Plasma 6 sous Wayland, personnalisé via design system **OPALE** | Puissant, scriptable (QML), Wayland natif ; évite de réécrire un DE complet | Validée (25/11/2026) |
| ADR-004 | 2026-11-25 | Amorceur v1 = **GRUB2** (chaîne Secure Boot Fedora conservée) ; UKI + systemd-boot = cible v2 | GRUB seul chemin éprouvé aujourd'hui pour Secure Boot + dual boot Windows sur Atomic ; UKI encore en phase test amont (suivi bootc #806) | Validée (25/11/2026) |
| ADR-005 | 2026-11-25 | Installateur v1 = **Anaconda** (ISO type `anaconda-iso` via bootc-image-builder) + branding HYBRID ; installateur graphique custom = Phase 5 | Anaconda est le seul installateur prouvé pour images Atomic (utilisé par Fedora Kinoite et les dérivées majeures) ; Calamares non adapté à bootc à ce jour | Validée (25/11/2026) |
| ADR-006 | 2026-11-25 | Applications = **Flatpak prioritaire** (Flathub vérifié) ; Wine/Proton via conteneurs/Flatpak | Isolation, provenance signée, mises à jour découplées du système | Validée (25/11/2026) |
| ADR-007 | 2026-11-25 | **Le design system s'appelle OPALE** (remplace « Aurora ») | « Aurora » est déjà une distribution réelle basée sur la même stack (Universal Blue) — collision de marque rédhibitoire ; OPALE : pierre hybride par nature, aucune collision OS identifiée | Validée (25/11/2026) |
| ADR-008 | 2026-11-25 | Mises à jour = `bootc update` (pull d'image OCI **signée cosign/Sigstore**) + rollback intégré | Modèle image-based = exigence atomique/retour arrière du cahier des charges, éprouvé | Validée (25/11/2026) |
| ADR-009 | 2026-11-25 | Secure Boot v1 = chaîne Fedora conservée (shim Microsoft → GRUB Fedora → noyau Fedora) ; clés propres = v2 avec enrollment assisté | Évite le processus « shim-review » (lourd) pour v1 ; l'enrollment de clés personnalisées post-install est prouvé par les distributions dérivées | Validée (25/11/2026) |

## Ce que ce dossier n'est pas

- Ce n'est pas du code : aucun composant du système n'est écrit à ce stade.
- Ce n'est pas une promesse commerciale : chaque document distingue
  **vérifié**, **à re-vérifier au moment du build**, et **non retenue**.
- Les maquettes visuelles (`branding/reference/`) sont des **concepts
  illustratifs non fonctionnels**, comme l'exige le cahier des charges.

## Prochaine étape (après validation)

Lancer **Alpha 0.1** (doc 10) : première image ISO construite de façon
reproductible en CI et amorcée en machine virtuelle. Aucune écriture sur
matériel physique ne sera effectuée sans autorisation explicite.
