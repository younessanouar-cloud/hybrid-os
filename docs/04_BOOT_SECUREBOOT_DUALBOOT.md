# 04 — Amorçage, Secure Boot et dual boot

> Zone à plus fort risque du projet (cahier des charges §8). Aucune action
> sur matériel physique sans autorisation explicite.

## 1. Chaîne de démarrage v1 (retenu, ADR-004)

```
UEFI (mode Secure Boot ACTIF)
  └─ shim (signé Microsoft, fourni par Fedora)      ← confiance firmware
       └─ GRUB2 (signé Fedora)                      ← binaire amont non modifié
            └─ noyau + initramfs (signés Fedora)     ← déploiement bootc
                 └─ /usr image OCI (notre contenu custom)   ← notre espace
```

**Point clé** : tout notre contenu personnalisé (bureau OPALE, apps, config)
vit dans `/usr` (image atomique en lecture seule). **Aucun binaire de la
chaîne d'amorçage n'est modifié ni resigné par nous en v1** → Secure Boot
reste actif sans enrollment utilisateur et sans procédure « shim-review ».

**Contrepartie assumée (transparence)** : la confiance de v1 repose sur les
clés Fedora/microsoft. C'est le même niveau de garantie que Fedora Kinoite —
mais ce n'est pas « notre » chaîne. La v2 y remédie (§3).

## 2. GRUB2 vs systemd-boot/UKI — comparaison honnête

| Critère | GRUB2 (v1) | systemd-boot + UKI (v2) |
|---|---|---|
| Maturité sur Atomic/Secure Boot | ✅ Chemin de production (Fedora + dérivées) | ⚠️ Images « sealed » de test amont (avr. 2026), tracker bootc #806 ouvert |
| Dual boot Windows | ✅ Détection automatique (os-prober) | ✅ Entrées Windows auto sur ESP partagé, mais moins éprouvé avec Secure Boot chaîne tierce |
| Rollback des déploiements | ✅ Intégré au flux bootc | ✅ Prévu (entrées UKI par déploiement) |
| Complexité de signature | Binaire amont signé Fedora (rien à faire) | Il faut signer sd-boot + UKI (nos clés) → enrollment requis |
| Vitesse/esthétique | Correcte | Démarrage plus direct, écran plus sobre |
| Verdict | **Retenu v1** | **Cible v2**, suivi actif du travail amont |

Décision : **GRUB2 en v1** (le seul chemin éprouvé aujourd'hui pour
Secure Boot + dual boot Windows sur Atomic), UKI/systemd-boot documenté
comme cible et suivi (bootc issue #806 + images sealed Fedora).

## 3. Cible v2 — nos propres clés (après v1)

1. Générer une paire de clés HYBRID (offline, stockage sécurisé — jamais
   dans le dépôt, règle §10 du cahier des charges).
2. Signer systemd-boot + UKI (`ukify`, `sbctl`).
3. **Enrollment assisté post-installation** (modèle prouvé par les dérivées :
   assistant graphique qui inscrit nos clés dans db après confirmation et
   vérification d'un code affiché à l'écran). Réversible (désenrollment
   documenté).
4. Windows reste détecté : l'entrée `bootmgfw.efi` est listée par
   systemd-boot si ESP partagé.

## 4. Dual boot Windows — règles impératives (cahier des charges §8)

Respectées **par conception** dans le parcours d'installation (doc 05) :

- Jamais de formatage du disque entier par défaut ; jamais de modification
  de la partition EFI existante ; jamais d'écriture sur une partition
  Windows sans confirmation explicite, écran par écran.
- GRUB installe son entrée **dans l'ESP existante** (dossier `hybrid/`)
  et s'ajoute à la NVRAM **sans toucher** à `EFI/Microsoft` ; Windows
  reste listé au menu ; le choix par défaut est explicite.
- **BitLocker détecté** (`manage-bde`/attributs détectables) → écran
  d'avertissement dédié : risque de demande de clé de récupération au
  premier démarrage alterné → exiger de l'utilisateur la confirmation
  qu'il **possède** sa clé de récupération avant de continuer.
- **Fast Startup / hibernation Windows** : les partitions NTFS ne seront
  jamais montées en écriture si le dernier arrêt Windows est « hybride »
  (détection via l'indicateur hiberfile) — montage en lecture seule et
  message explicite.
- ESP : sauvegarde intégrale de l'ESP **avant** toute écriture (archive
  stockée sur la future partition HYBRID + procédure de restauration live).

## 5. Récupération (exigence §8 & §9 du cahier des charges)

| Scénario | Procédure prévue v1 |
|---|---|
| Mise à jour défectueuse | Rollback natif : sélection du déploiement précédent dans GRUB (standard bootc) — testé en CI (doc 09) |
| GRUB cassé / entrée perdue | Live USB → réparation de l'entrée NVRAM + réinstallation GRUB dans l'ESP (script `hybrid-repair-boot`) |
| Windows ne démarre plus | L'entrée `EFI/Microsoft` est intacte par conception ; restauration = `bcdedit` côté Windows ou sélection directe dans le firmware ; la doc utilisateur détaille le secours |
| Clé LUKS perdue | La **passphrase de secours** (imprimée à l'installation) reste le mécanisme principal ; TPM = confort, jamais l'unique clé (doc 06) |
| Coupure électrique pendant l'install | Écriture transactionnelle : phases préparatoires réversibles ; l'installateur vérifie l'état du disque au relancement et propose reprise/annulation |

## 6. Limites documentées (jamais de promesse absolue)

- Secure Boot ne protège pas tout le disque : `/boot` et l'ESP restent des
  surfaces physiques ; v1 en hérite (attestation locale possible plus tard).
- Le dual boot avec BitLocker **peut** déclencher une demande de clé de
  récupération selon les stratégies OEM — nous informant, nous ne contrôlons
  pas la réponse du firmware OEM.
- Certains firmwares OEM boguent avec les entrées multiples : l'installateur
  propose le mode « entrée firmware » en secours.
- os-prober peut manquer des installations exotiques : le parcours inclut
  une vérification manuelle de la liste détectée **avant** confirmation.
