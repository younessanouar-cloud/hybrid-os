# Arborescence du dépôt HYBRID OS

> Structure conforme au cahier des charges §10. **Honnêteté oblige** :
> chaque dossier indique son statut réel — « vide » signifie vide.
> Rien n'est rempli de code factice en attendant la vraie phase.

| Dossier | Rôle | Statut (25/11/2026) |
|---|---|---|
| `build/` | Chaîne de construction d'image | ✅ **Actif** — `manifest.yaml` (base figée), `image/Containerfile.base` (v0) |
| `build/image/` | Containerfiles des couches (base → desktop → apps) | ✅ v0 présent (base sans modification) |
| `build/iso/` | Génération ISO (bootc-image-builder) | 🕳 Vide — étape 5 du plan Alpha 0.1 |
| `scripts/` | Outils communs (préflight, mesure, réparation) | 🕳 Vide — Phase 3/5 |
| `system/kernel/` | Configuration noyau (jamais de fork — doc 02) | 🕳 Vide — Phase 2 |
| `system/boot/` | GRUB, entrées, récupération de boot (doc 04) | 🕳 Vide — Phase 2/3 |
| `system/security/` | SELinux policies custom, LUKS/TPM (doc 06) | 🕳 Vide — Phase 3 |
| `system/services/` | Services systemd HYBRID | 🕳 Vide — Phase 2/3 |
| `desktop/` | HYBRID Desktop (Plasma + OPALE, doc 07) | 🕳 Vide — Phase 2 |
| `desktop/shell/` `dock/` `launcher/` `notifications/` `settings/` | Composants du bureau | 🕳 Vide — Phase 2 |
| `applications/` | Applications natives Kirigami | 🕳 Vide — Phase 3/4 |
| `applications/security-center/` | Hybrid Security Center (doc 06) | 🕳 Vide — Phase 3 |
| `applications/app-store/` | Hybrid Store (doc 02) | 🕳 Vide — Phase 4 |
| `applications/file-manager/` | Intégration explorateur | 🕳 Vide — Phase 4 |
| `applications/control-center/` | Paramètres regroupés | 🕳 Vide — Phase 4 |
| `installer/` | Installateur (doc 05) | 🕳 Vide — Phase 5 |
| `installer/partitioning/` `dual-boot/` `hardware-detection/` | Partitionnement, détection Windows/matériel | 🕳 Vide — Phase 5 |
| `recovery/` | Sauvegarde/restauration, clés LUKS, réparation ESP | 🕳 Vide — Phase 3/5 |
| `updates/` | Mises à jour signées, historique, rollback | 🕳 Vide — Phase 4 |
| `compatibility/` | Wine/Proton, profils de compatibilité | 🕳 Vide — Phase 4 |
| `branding/` | Identité OPALE, logo, thèmes | 🟡 Référence seulement (maquette conceptuelle) |
| `documentation/` | Documentation technique/utilisateur | 🟡 Pointeur vers `docs/` + ce fichier |
| `tests/` | Tous les tests (doc 09) | 🟡 `ci/test_image.sh` actif ; reste vide |
| `tests/reports/` | Rapports de tests exécutés (traçabilité §6 doc 09) | 🕳 Rempli par la CI (artefacts) |
| `adr/` | Architecture Decision Records | 🟡 Journal centralisé dans `docs/00_SOMMAIRE.md` |

## Règles applicables à cette arborescence

1. Un dossier ne devient « actif » que s'il contient du code réel, testé.
2. Aucun code n'est ajouté avant la phase prévue par le plan validé.
3. Les secrets de signature ne vivent jamais ici (règle cahier des charges §10).
