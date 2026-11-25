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
| 1 | Initialiser le dépôt technique (structure cahier des charges §10 : build/, system/, desktop/… + CI vierge) | Dépôt + workflow CI qui build l'image de base sans modification | CI verte |
| 2 | Manifeste des versions (base figée) + `Containerfile` HYBRID v0 | Image OCI `hybridos/base` | `bootc status` OK en conteneur CI |
| 3 | Couche KDE + branding OPALE v0 (fond, couleurs, KSplash, paquets de base FR) | Image `hybridos/desktop` | Build CI vert + tests headless d'apps |
| 4 | Signature cosign (clé de test, hors dépôt) + publication registre GHCR | Image signée | Vérification `cosign verify` en CI |
| 5 | Génération ISO via `bootc-image-builder` (`anaconda-iso`) + artefact CI téléchargeable | ISO Alpha 0.1 | Artefact présent + hash SHA256 publié |
| 6 | Test VM documenté (local : smoke ; CI : scripts sériels) : boot → install → reboot | Rapport de test n°1 (commandes + sorties) | Tous les critères §7 du doc 09 |
| 7 | Mesures initiales (RAM, boot) vs Fedora référence | `tests/reports/alpha01-perf` | Méthode du doc 09 respectée |
| 8 | Retour d'expérience + correction + tag `v0.1.0-alpha` | Note de jalon + release | **Validation client du jalon** |

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
