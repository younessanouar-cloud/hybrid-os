# 08 — Registre des risques

> Évalués le 25/11/2026. Probabilité (P) et Impact (I) : Faible/Moyen/Élevé.
> Chaque risque a une mitigation et un critère de suivi. Aucun risque n'est
> caché — règle du cahier des charges §15.

## Risques techniques

| ID | Risque | P | I | Mitigation |
|---|---|---|---|---|
| R-01 | Machine de dév. locale insuffisante (8 Go, CPU faible) bloque build/VM | Élevé | Moyen | ADR-002 : build 100 % CI (GitHub Actions publics) ; VM locales = smoke tests ; machines de test dédiées pour le hardware (Phase 5) |
| R-02 | Transition amont « Image Mode Phase 2 » : les outillages bootc évoluent vite | Moyen | Moyen | Base dès v1 sur la cible (bootc), pas sur rpm-ostree legacy ; manifeste figé + fenêtre de test à chaque rebase |
| R-03 | Anaconda + images bootc : intégration à re-valider à chaque montée de version | Moyen | Élevé | ISO `anaconda-iso` = voie documentée officiellement ; tests CI bloquants ; assistant v1.5 découplé (survit aux changements) |
| R-04 | Secure Boot clés propres (v2) : enrollment fragile selon firmwares OEM | Moyen | Moyen | v1 = chaîne Fedora (aucun enrollment requis) ; v2 = enrollment assisté réversible + procédure de désinscription documentée |
| R-05 | Dual boot + BitLocker : demande de clé de récupération selon OEM | Moyen | Élevé | Détection + écran de blocage tant que l'utilisateur n'a pas confirmé détenir sa clé ; doc pédagogique ; jamais de modification silencieuse |
| R-06 | GRUB/os-prober manque une installation Windows exotique | Faible | Élevé | Liste détectée affichée pour validation manuelle avant écriture ; test automatique « Windows démarre » en VM avant publication |
| R-07 | Pilote NVIDIA sur Atomic : layering + SELinux + Wayland | Moyen | Moyen | Module optionnel isolé, testé à part (matrice doc 09) ; en cas d'échec → message honnête (driver libre fallback) |
| R-08 | Perf < objectifs (≤1,8 Go repos, ≤20 s boot) | Moyen | Moyen | Mesures dès Alpha (doc 09) ; Plasma tunable ; objectifs = cibles de dev, pas des promesses (cahier des charges §7) |
| R-09 | SELinux enforcing vs apps custom → AVC bloquants | Moyen | Moyen | Policies testées en CI ; règle absolue : adapter la policy, JAMAIS couper SELinux |
| R-10 | Compatibilité Wine/Proton aléatoire par logiciel | Élevé | Faible | Niveaux de compatibilité affichés par profil (exigence §6) ; jamais de promesse universelle |
| R-11 | Filtrage réseau sortant (v2) complexe à concilier avec ergonomie | Moyen | Faible | v1 : pare-feu entrant strict ; sortie documentée comme chantier v2 |

## Risques projet / organisation

| ID | Risque | P | I | Mitigation |
|---|---|---|---|---|
| R-12 | Charge de travail : projet très ambitieux pour une petite équipe | Élevé | Élevé | Jalons courts validés (Alpha 0.1 = ISO VM) ; périmètre v1 sans installer custom ; tout ce qui n'est pas indispensable attend v1.5+ |
| R-13 | Collision de marque (« Aurora » déjà pris — écarté ; vérifs continues) | Résolu | — | ADR-007 : OPALE ; vérification finale à faire avant toute diffusion publique |
| R-14 | Clés de signature compromises/perdues | Faible | Élevé | Hors dépôt (règle §10) ; procédure de rotation cosign documentée dès v1 |
| R-15 | Attentes utilisateur surélevées par les maquettes | Moyen | Moyen | Étiquette « concept illustratif » sur toute maquette (règle §12) ; état réel toujours indiqué dans l'à-propos |
| R-16 | Dérive du projet vers « personnalisation cosmétique » | Moyen | Élevé | Le Cahier des charges l'interdit ; la feuille de route garde les jalons « vraie image, vrais tests » bloquants |

## Les trois risques qui décident du calendrier

1. **R-12 (charge)** → la v1 du cahier des charges suppose une équipe ; en
   pratique, chaque jalon sera validé avant d'engager le suivant, et le
   planning (6 phases, 24 semaines indicatives) sera réévalué à chaque jalon.
2. **R-03/R-06 (installateur + dual boot)** → chantier le plus long ;
   commencée dès la Phase 2 en parallèle (préparatifs préflight scripts),
   prouvée en Phase 5.
3. **R-01 (moyens)** → sans CI publique gratuite, le projet serait bloqué :
   la viabilité repose sur ce choix d'architecture, assumé et documenté.
