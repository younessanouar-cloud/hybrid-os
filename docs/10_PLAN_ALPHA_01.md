# 10 — Plan du jalon Alpha 0.1

> Premier jalon concret du projet (conclusion du cahier des charges) :
> **une image ISO réellement amorçable, construite de façon reproductible
> et testée en machine virtuelle.** Ce plan ne sera exécuté qu'après
> validation de l'architecture par le client.

## Périmètre d'Alpha 0.1 (ce qu'il EST)

1. Dépôt Git complet avec chaîne CI fonctionnelle.
2. `Containerfile` dérivant de l'image Fedora Atomic KDE (base figée :
   tag + digest dans le manifeste).
3. Branding minimal : fond OPALE, couleurs système, KSplash simple —
   assez pour prouver la personnalisation intégrée à l'image.
4. Build CI : image OCI → signature cosign (clé de test) → ISO
   (`bootc-image-builder`, type `anaconda-iso`).
5. Tests VM QEMU documentés : boot live → installation disque virtuel →
   redémarrage → **rollback** vérifié → SELinux enforcing vérifié.
6. Premier rapport de mesures (RAM repos, temps de boot) sur VM de
   référence.

## Hors périmètre d'Alpha 0.1 (ce qu'il N'EST PAS — règle d'honnêteté)

- ❌ Pas d'installateur graphique custom ni de dual boot validé.
- ❌ Pas de Store, Security Center, Wine/Proton, NVIDIA.
- ❌ Pas de Secure Boot à nos clés (chaîne Fedora conservée).
- ❌ Pas de thèmes OPALE complets (simple branding initial).
- ❌ Rien d'installé sur un ordinateur physique.

## Étapes d'exécution (une fois l'architecture validée)

| # | Étape | Produit | Validation |
|---|---|---|---|
| 1 | Initialiser le dépôt technique (structure cahier des charges §10 : build/, system/, desktop/… + CI vierge) | Dépôt + workflow CI qui build l'image de base sans modification | ✅ **VALIDÉE** — run 45709596687 (25/11/2026) : base ET desktop verts |
| 2 | Manifeste des versions (base figée) + `Containerfile` HYBRID v0 | Image OCI `hybridos/base` | ✅ **VALIDÉE** — bootc 1.17.1 opérationnel en conteneur CI |
| 3 | Couche KDE + branding OPALE v0 (fond, couleurs, KSplash simple, paquets de base FR) | Image `hybridos/desktop` | ✅ **VALIDÉE** — Plasma 6.8.3, locale FR, branding OPALE 4/4 fichiers PRÉSENTS (rapport artefact) |
| 4 | Signature cosign (clé de test, hors dépôt) + publication registre GHCR | Image signée | Vérification `cosign verify` en CI |
| 5 | Génération ISO via `bootc-image-builder` (`anaconda-iso`) + artefact CI téléchargeable | ISO Alpha 0.1 + SHA256 publié | ✅ **VALIDÉE** — run 45719798169 : ISO `install.iso`, SHA256 `10bda05f…` (4 fixes documentés : storage monté, pre-pull, `--rootfs xfs`, chemins) |
| 6 | Test VM documenté : boot de l'ISO en UEFI/OVMF (QEMU TCG) | Rapport de test + trace série | ✅ **VALIDÉE (amorçage)** — noyau 7.2.11-300.fc45 + systemd + Anaconda atteints ; preuve archivée `tests/reports/run45719798169/BOOT_PROOF.md` (l'installation complète sur disque = suite du plan) |
| 7 | Mesures initiales (RAM, boot) vs Fedora référence | `tests/reports/alpha01-perf` | ✅ **VALIDÉE (méthode + socle)** — run 45772086234 : installation 47 min, SELinux **enforcing** ✅, RAM 461 Mo en multi-user (sans bureau), boot 1min13 TCG ; limites + bugs de mesure documentés dans `tests/reports/run45772086234/INSTALL_PROOF.md` ; mesures matériel = Phase 5 |
| 8 | Retour d'expérience + correction + tag `v0.1.0-alpha` | Note de jalon + release | ✅ **VALIDÉE** — tag `v0.1.0-alpha` posé, note `docs/11` complétée avec les résultats d'installation, **validation client du jalon obtenue le 26/11/2026** |

## Critères de succès (tous obligatoires)

- [ ] ISO bootable en VM QEMU (UEFI/OVMF, Secure Boot activé dans la VM).
- [ ] Installation sur disque virtuel puis premier démarrage réussis.
- [ ] `bootc update` vers une image suivante puis **rollback** réussi.
- [ ] SELinux **enforcing** constaté après installation ET après rollback.
- [ ] Build entièrement reproductible depuis le dépôt (2 runs → mêmes digests
      de couches aux sources près, documentés).
- [ ] Aucune donnée simulée présentée comme fonctionnelle.

## Pré-requis côté client

1. **Validation de l'architecture** (docs 00→10).
2. Compte GitHub pour héberger le dépôt + Actions (existant ✅).
3. Décision sur la visibilité du dépôt : **public recommandé** (runners
   CI gratuits — recommandation ADR-002 ; un dépôt privé nécessiterait un
   abonnement ou un runner auto-hébergé).
4. Acceptation explicite : aucun accès à un ordinateur physique ne sera
   demandé avant la Phase 5 (dual boot réel), et seulement sur machines de
   test dédiées après sauvegarde complète.
