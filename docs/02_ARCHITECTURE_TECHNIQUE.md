# 02 — Architecture technique

> Phase 1 — conception. Composants retenus après comparaison des alternatives.
> Les versions exactes seront figées dans un manifeste au premier build (doc 03).

## 1. Vue d'ensemble (v1 « Foundry »)

```
┌────────────────────────────────────────────────────────────────────┐
│  HYBRID OS — image système OCI bootable (atomique, signée)          │
├────────────────────────────────────────────────────────────────────┤
│  HYBRID Desktop (KDE Plasma 6 · Wayland · design system OPALE)     │
│   └─ Dock, lanceur universel, notifications, bureaux virtuels      │
├────────────────────────────────────────────────────────────────────┤
│  Applications natives (Kirigami/QML, identité OPALE)               │
│   └─ Security Center · Store · Control · Update · Recovery         │
├────────────────────────────────────────────────────────────────────┤
│  Couche applications utilisateur                                   │
│   └─ Flatpak (Flathub vérifié) · Steam/Proton · Wine (Bottles)     │
├────────────────────────────────────────────────────────────────────┤
│  Base système Fedora Atomic (bootc) — read-only /usr               │
│   └─ systemd · SELinux enforcing · firewalld · fwupd · PipeWire    │
├────────────────────────────────────────────────────────────────────┤
│  Amorçage : UEFI → shim → GRUB2 → noyau (chaîne signée, doc 04)     │
│  Données  : LUKS2 (+ TPM 2.0 si présent) sur / et /home            │
└────────────────────────────────────────────────────────────────────┘
```

## 2. Décision structurante : image OCI bootable (bootc)

**Retenu** : HYBRID OS est construit comme une **image conteneur bootable**
dérivant de l'image Fedora Atomic KDE officielle, gérée par `bootc`.

- Le système de fichiers racine `/usr` est **en lecture seule** (immutabilité).
- Les mises à jour = nouvelle image → déploiement atomique → **rollback**
  natif (le déploiement précédent reste amorçable).
- Toute la personnalisation (packages, configuration, branding, applications
  natives) est déclarée dans des **Containerfiles versionnés** → build
  reproductible en CI (ADR-002).

**Alternatives comparées** :

| Option | Verdict | Raison |
|---|---|---|
| Noyau + distro from scratch | ❌ Rejeté | Coût énorme, sécurité dégradée, aucun bénéfice utilisateur (cahier des charges §3) |
| Distro classique « mutable » (Debian/Arch fork) | ❌ Rejeté | Pas d'atomicité ni de rollback natif ; exigerait construire l'outillage qui existe déjà en Atomic |
| Fedora Atomic + scripts de post-install | ❌ Rejeté | Non reproductible, non signé, « déjà vu » — cahier des charges exige une vraie image maîtrisée |
| **Fedora Atomic (bootc) + nos Containerfiles** | ✅ Retenu | Officiel, éprouvé par des dérivées existantes, atomique, signable, reproductible |
| OpenSUSE MicroOS / NixOS | ❌ Rejeté (v1) | Écosystèmes valables mais KDE/Wayland + SELinux + francophonie doc + maturité dual boot : Fedora est le meilleur terrain pour v1 |

## 3. Les modules HYBRID (mapping technique réel)

Le cahier des charges définit 10 modules (§3). Voici leur traduction
technique concrète — chaque module a un dossier, un responsable, des tests :

| Module | Implémentation v1 | Densité de développement |
|---|---|---|
| **Hybrid Core** | Containerfiles de base (`base`, `hybrid-common`, `hybrid-kde`) + configuration systemd/SELinux | Faible-moyenne (déclaratif) |
| **Hybrid Desktop** | Thèmes Plasma 6 : Plasma Theme, KWin (déco + effets), couleurs, icônes, curseurs, KSplash, SDDM + layout dock/lanceur (QML) | Moyenne-forte (design + QML) |
| **Hybrid Security** | App Kirigami « Security Center » consommant de **vraies** sources système (aucune donnée simulée) : `sestatus`, `cryptsetup`, `firewalld`, `fwupd`, `journalctl`, `bootc status` | Forte |
| **Hybrid Store** | Frontal Flatpak/Flathub (découverte, permissions, mises à jour) — pas de réinvention du packaging | Moyenne |
| **Hybrid Control** | Regroupement Paramètres (KCM existants + énergie/profils custom) | Moyenne |
| **Hybrid Installer** | v1 : ISO `anaconda-iso` + kickstart + branding ; v1.5 : assistant dual boot custom (doc 05) | Très forte (chantier critique) |
| **Hybrid Boot** | Config GRUB + entrées + intégrité + récupération ; v2 : UKI/systemd-boot (doc 04) | Moyenne |
| **Hybrid Update** | `bootc update` vers nos images signées + interface d'historique/rollback (frontend `bootc status`) | Moyenne |
| **Hybrid Compatibility** | Steam Flatpak + Proton + Wine/Bottles préconfigurés, profils documentés par logiciel | Faible-moyenne (intégration + doc) |
| **Hybrid Recovery** | Environnement de récupération sur l'image + procédures (clés LUKS, rollback, réparation ESP) | Moyenne-forte |

## 4. Chaîne de construction (reproductible, ADR-002)

```
Containerfile (dépôt Git)
   │  CI GitHub Actions (runners publics Linux)
   ├── podman build → image OCI hybride-os:<version>
   ├── cosign sign (Sigstore) → image signée  ──► registre (GHCR)
   └── bootc-image-builder --type anaconda-iso
        └── ISO Live/installable (embarque l'image → installation offline possible)

Mise à jour côté utilisateur :
   bootc update → pull image signée (vérification signature/commit)
   → déploiement atomique au prochain redémarrage
   → rollback = sélection du déploiement précédent (natif)
```

Reproductibilité : le manifeste `docs/03` fige les versions de base (tag
d'image Fedora exact + digest), le reste du build est déclaratif. Les builds
sont vérifiés par les tests CI (doc 09) avant publication.

## 5. Séparation système / utilisateur (principe directeur)

- **Système** : image signée, lecture seule, mise à jour atomiquement.
- **Applications** : Flatpak (sandbox, permissions contrôlées), provenance
  Flathub vérifiée ; jamais d'installation RPM à la volée par l'utilisateur.
- **Données** : `/home` et `/var` chiffrables LUKS2, séparés du système
  (doc 06) — la sauvegarde utilisateur est découplée du rollback système
  (exigence cahier des charges §9).
- **Exception contrôlée** : `rpm-ostree`/layering reste possible pour le
  pilote NVIDIA propriétaire si nécessaire — documenté, non encouragé,
  testé à part (doc 09).

## 6. Ce que v1 ne fait PAS (honnêteté d'architecture)

- Pas de noyau recompilé (noyau Fedora signé, maintenu).
- Pas de chaîne Secure Boot 100 % HYBRID (v1 = chaîne Fedora, doc 04).
- Pas de compatibilité macOS ; pas de promesse de compatibilité Windows
  universelle (niveaux affichés par logiciel, cahier des charges §6).
- Pas de réinvention de pipewire/pulseaudio/printing : intégration et
  présentation uniquement.
- Pas d'applications natives « simulées » : chaque app listée dans les
  livrables sera réellement branchée sur des sources système (règle §12).
