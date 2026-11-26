# HYBRID OS — Distribution hybride nouvelle génération

> **Statut : Alpha 0.1 ATTEINT (26/11/2026) — ISO amorçable construite de façon
> reproductible et bootée en VM UEFI. Preuves : `tests/reports/run45719798169/`.**
> Validation client du jalon en cours — ensuite : mesures, installation
> automatisée, puis Phase 2 (interface complète OPALE).

> Phase 1 (conception) : dossier complet dans `docs/` — vérifié le 25/11/2026.

HYBRID OS est un système d'exploitation hybride destiné au grand public et aux
professionnels : l'ergonomie de Windows et macOS, la liberté et la sécurité de
Linux, avec une identité technique et graphique **propre** — pas une simple
personnalisation cosmétique.

## Caractéristiques cibles (v1.0)

| Domaine | Cible |
|---|---|
| Architecture | x86-64 / UEFI, image système atomique (Fedora Atomic / bootc) |
| Bureau | HYBRID Desktop — KDE Plasma 6 personnalisé sous Wayland, design system **OPALE** |
| Sécurité | Secure Boot, LUKS2 + TPM 2.0, SELinux enforcing, pare-feu actif, isolation applicative |
| Applications | Flatpak prioritaire, Wine/Proton optionnel, Hybrid Store |
| Installation | Autonome ou **dual boot à côté de Windows** (sans destruction de données) |
| Performances | ≤ 1,8 Go RAM au repos, démarrage ≤ 20 s sur SSD de référence |

## Structure du dépôt

```
hybrid-os/
├── README.md                  ← ce fichier
├── docs/                      ← dossier de conception (Phase 1)
│   ├── 00_SOMMAIRE.md         ← sommaire + journal des décisions
│   ├── 01_ANALYSE_FAISABILITE.md
│   ├── 02_ARCHITECTURE_TECHNIQUE.md
│   ├── 03_COMPOSANTS_VERSIONS_LICENCES.md
│   ├── 04_BOOT_SECUREBOOT_DUALBOOT.md
│   ├── 05_INSTALLATEUR_DUALBOOT.md
│   ├── 06_SECURITE.md
│   ├── 07_DESIGN_SYSTEM_OPALE.md
│   ├── 08_REGISTRE_RISQUES.md
│   ├── 09_PLAN_TESTS.md
│   └── 10_PLAN_ALPHA_01.md    ← plan du premier jalon (ISO amorçable en VM)
├── adr/                       ← Architecture Decision Records
└── branding/
    └── reference/             ← maquettes conceptuelles (référence, non contractuelles)
```

Les dossiers `build/`, `system/`, `installer/`, `applications/`… seront créés
**après validation de l'architecture** (jalon de la Phase 1), conformément au
cahier des charges §16 : *« Attendre la validation de l'architecture avant
toute modification du dépôt ou génération de code. »*

## Règles du projet (extraites du cahier des charges)

1. Ne jamais simuler une fonctionnalité ni déclarer un test réussi sans exécution réelle.
2. Ne jamais toucher aux partitions ou au démarrage d'un ordinateur physique sans autorisation explicite.
3. Ne jamais désactiver une protection de sécurité pour contourner un problème.
4. Documenter chaque décision et ses limites.
5. Procéder par jalons validés.

## Phase en cours

**Phase 1 — Fondations** : faisabilité, architecture, composants, risques,
plan de tests, plan Alpha 0.1. Voir `docs/00_SOMMAIRE.md`.
