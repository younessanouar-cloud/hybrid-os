# 09 — Plan de tests

> Règle absolue (cahier des charges §12, §15) : **aucun test ne sera déclaré
> réussi sans exécution réelle**. Tout résultat est archivé (logs CI,
> captures, mesures) dans le dépôt.

## 1. Pyramide de tests

```
Niveau 3 — HARDWARE (Phase 5+, machines de test dédiées uniquement)
   dual boot réel, BitLocker réel, GPU NVIDIA/AMD/Intel réels, autonomie
Niveau 2 — VM (CI + local smoke) : QEMU/KVM
   boot ISO → install → premier démarrage → rollback → dual boot simulé
   (2 disques virtuels : Windows factice + HYBRID)
Niveau 1 — CI (à chaque commit) :
   lint (shell/python/qml), build image, signature cosign,
   bootc-image-builder ISO, test conteneur (lancer les apps en headless),
   tests des scripts (preflight, repair, mesure)
```

## 2. Tests CI bloquants (pipeline de publication)

1. L'image OCI se construit et passe `bootc status` en conteneur.
2. L'ISO générée démarre en VM QEMU (sérial + capture) jusqu'à SDDM.
3. Installation sur disque virtuel : partitionnement auto → redémarrage →
   session affichée.
4. **SELinux enforcing après install + après update** (critère §12).
5. **Rollback testé** : update → rollback → boot sur déploiement précédent.
6. Script `preflight` : testé sur disques virtuels avec/sans Windows factice,
   BitLocker simulé, espace insuffisant, ESP plein → bons refus.
7. **Windows factice reste amorçable** après installation HYBRID (test
   automatique VM — critère bloquant).
8. Mesures de performance enregistrées (voir §4) — comparaison à la
   référence Fedora Kinoite.

## 3. Machines de référence (à figer avant toute mesure comparative)

| Rôle | Configuration | Usage |
|---|---|---|
| Référence VM | QEMU : 4 vCPU, 8 Go, disque virtuel NVMe simulé, UEFI OVMF | Mesures reproductibles CI/local |
| Machine de test n°1 (Phase 5) | PC UEFI « sacrifice », Windows 11 + BitLocker, GPU Intel — **fourni/dédié par le client, sauvegardé image complet avant tout test** | Dual boot réel |
| Machine de test n°2 (Phase 5) | Portable + GPU NVIDIA | Pilotes, autonomie, thermique |
| Machine de test n°3 (Phase 5) | Matériel modeste (proche du minimum 4 Go) | Validation prérequis bas |

**Interdits** (règle §13 du cahier des charges) : jamais de test
partitionnement sur la machine principale de qui que ce soit ; toujours
sauvegarde image complète avant Phase 5 sur machines réelles.

## 4. Mesures de performance (objectifs = cibles, pas des promesses)

| Indicateur | Cible (cahier des charges §7) | Méthode reproductible |
|---|---|---|
| RAM au repos | ≤ 1,8 Go | mesure après 5 min idle (script `hybrid-perf` : smem-like via /proc) |
| Démarrage | ≤ 20 s jusqu'au bureau | `systemd-analyze` + seuil SDDM, 5 runs, médiane |
| Fluidité | 60 FPS visés | counters FPS KWin + test de charge standard |
| Autonomie | mesurée vs Fedora référence | powertop snapshot, scénario navigation 60 min |
| Taille image | mesurée | rapport CI |

Chaque mesure est archivée avec : version de l'image, digest, config
matériel, date, commande exacte → **reproductible et auditable**.

## 5. Tests de sécurité (Phase 3)

- SELinux : audit des AVC de tout le parcours utilisateur standard ; aucune
  policy permissive ajoutée sans revue (règle : adapter, jamais couper).
- Chiffrement : LUKS2 + TPM2 : kill du disque, redémarrage, récupération
  par passphrase de secours — scénario TPM effacé (mise à jour firmware).
- Mises à jour : signature cosign invalide → refus testé ; image précédente
  toujours amorçable.
- Journalisation : événements attendus présents (sudo, échecs, déploiements).
- Réseau : scan du système au repos (aucun port ouvert inattendu).
- Security Center : chaque panneau branché sur sa vraie source — test
  automatisé de non-régression (aucune valeur codée en dur tolérée).

## 6. Traçabilité

- Chaque campagne de tests produit un rapport horodaté archivé dans
  `tests/reports/` (créé en Phase 2).
- Un test ne passe que s'il est **exécuté** : les rapports contiennent
  commandes + sorties brutes.
