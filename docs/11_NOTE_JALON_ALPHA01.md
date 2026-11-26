# 11 — Note de jalon : **Alpha 0.1 atteint**

> Date : 26 novembre 2026 · Validation client : OUI (26/11/2026) ·
> Tag : `v0.1.0-alpha`

## Définition du jalon (cahier des charges, conclusion)

> « Le premier jalon concret est HYBRID OS Alpha 0.1 : une image ISO réellement
> amorçable, construite de façon reproductible et testée en machine virtuelle. »

**Statut : ATTEINT.**

## Preuves d'exécution réelle (toutes archivées/consultables)

| Preuve | Référence |
|---|---|
| Chaîne CI complète verte, **2 runs consécutifs** (reproductibilité) | GitHub Actions runs `45719798169` et `45727510479` (conclusion `success`) |
| Image de base + desktop construites par digest figé | `build/manifest.yaml` : `quay.io/fedora/fedora-kinoite:45` @ `sha256:79f701ea…` |
| Image signée + signature vérifiée dans le run | `ghcr.io/younessanouar-cloud/hybridos:desktop-0.1.0-alpha.1` (cosign keyless OIDC) |
| ISO installable + SHA256 | Artefact `hybridos-alpha01-iso` ; SHA256 `10bda05f6626a5c93ed0416cf24fdf15685d473e78732a4d297bdabafa99a3e4` |
| **Premier boot en VM UEFI** | `tests/reports/run45719798169/BOOT_PROOF.md` + trace série (noyau 7.2.11-300.fc45 → systemd → slice Anaconda) |

## Versions réelles constatées (rapports CI archivés)

Fedora 45 (Kinoite Atomic) · noyau installé 7.3.4-300.fc45 · KDE Plasma 6.8.3 ·
bootc 1.17.1 · SELinux policy 45.24 · branding OPALE 4/4 fichiers embarqués
(wallpaper « Opale nuit » 4K, palette `HybridOpale.colors`, look-and-feel
`com.hybridos.opale`, `kdeglobals`).

## Historique des corrections (7, toutes diagnostiquées par log réel)

1. `.gitignore` qui ignorait `build/` (dossier source du CDC §10)
2. `podman run \| head` → broken pipe (exit 126) → `head` dans le conteneur
3. cosign n'utilise pas l'authentification podman → `cosign login` séparé
4. bootc-image-builder : montage `/var/lib/containers/storage` obligatoire
5. bootc-image-builder ne pull plus → `sudo podman pull` préalable
6. `--rootfs xfs` exigé (image dérivée sans étiquette par défaut)
7. ISO produite dans `output/bootiso/` → chemins récursifs ; et OVMF 4M en
   mode pflash canonique (CODE + VARS), stderr QEMU toujours capturé

## Complément du 26/11 (matin) — étape 7 exécutée : installation complète prouvée

Le run `45772086234` (après rebase de la base) a validé **l'installation
kickstart automatisée de bout en bout** : ISO → Anaconda kickstart → système
installé sur disque virtuel → redémarrage sur ce disque → SSH → mesures.
Constats réels : noyau installé `7.3.4-300.fc45`, **SELinux enforcing après
installation** (critère bloquant doc 09 ✅), RAM 461 Mo en multi-user sans
bureau, boot 1 min 13 en TCG (non représentatif — voir limites détaillées
dans `tests/reports/run45772086234/INSTALL_PROOF.md`).

**Alpha 0.1 est COMPLET** (8/8 étapes validées par exécution réelle).

## Ce que Alpha 0.1 ne couvre PAS (règle d'honnêteté §12)

- L'installation complète sur disque et les mesures → **suite immédiate**
  (kickstart `tests/vm/ks-alpha01.cfg` vérifié contre la doc Fedora) ;
- mesures sur matériel de référence (obligatoires pour les objectifs
  ≤ 1,8 Go / ≤ 20 s — doc 09) ;
- interface complète OPALE (Phase 2), sécurité renforcée (Phase 3),
  Store/Wine (Phase 4), installateur dual boot (Phase 5).

## Décision d'architecture confirmée par ce jalon

Le modèle « dérivée d'image OCI Fedora Atomic (bootc) + CI de build + ISO
anaconda embarquant l'image » est **opérationnel de bout en bout** — ce que
la Phase 1 avait conçu est maintenant prouvé par exécution.
