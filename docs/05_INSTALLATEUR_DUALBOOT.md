# 05 — Installateur et parcours dual boot

> Le chantier le plus risqué du projet (cahier des charges §8). Stratégie en
> deux temps : éprouver l'installation via l'outillage amont PUIS construire
> l'assistant HYBRID.

## 1. Options comparées

| Option | État (nov. 2026) | Verdict |
|---|---|---|
| **Anaconda** (ISO type `anaconda-iso` de bootc-image-builder) | Le chemin utilisé par Fedora Kinoite et les grandes dérivées ; kickstart ; partitionnement auto avec resize ; branding personnalisable | ✅ **v1** (ADR-005) |
| **Calamares** | Excellent pour distros classiques ; pas de support standard des images bootc/ostree — intégration expérimentale à réévaluer | ❌ v1 (réévaluation possible en Phase 5) |
| **`bootc install to-disk`** | CLI officiel ; robuste mais technique (pas grand public) | ✅ moteur interne de la v1.5 |
| **Installateur graphique from scratch** | Coût maximal, risque maximal | ❌ hors périmatoire v1 |

**Décision** : v1 = Anaconda + kickstart + branding HYBRID (éprouvé) ;
v1.5 = **Hybrid Setup Assistant** (QML/Kirigami) qui prépare le disque et
délègue l'écriture à `bootc install` ; le même assistant deviendra la
porte d'entrée unique (mode automatique + mode expert).

## 2. Parcours utilisateur cible (mapping exigences §8 → implémentation)

| # Exigence | Implémentation v1 | Implémentation v1.5+ |
|---|---|---|
| 1. Détection Windows/disques/UEFI/GPT/ESP/BitLocker/espace | Anaconda détecte les disques/partitions ; **nos vérifications pré-install** (script de validation d'état) complètent : BitLocker, fast startup, santé disque | Assistant graphique dédié avec résumé clair |
| 2. Analyse de l'état du disque | Script `hybrid-preflight` : SMART, fsync test, espace réellement libre, fragmentation, errefs | Idem + affichage pédagogique |
| 3. Choix : Live / à côté de Windows / manuel | Anaconda : « automatic partitioning » (resize) ou manuel | Écran de choix à 3 voies avec explications |
| 4. Plan des modifications affiché | Récapitulatif Anaconda avant écriture | Plan détaillé par partition, avant/après |
| 5. Confirmation explicite | Oui (native Anaconda) + notre écran de risque BitLocker | Idem + saisie « HYBRID » pour confirmer |
| 6. Installation sans toucher Windows/Recovery | Partitionnement auto : resize NTFS (depuis la fin), nouvelles partitions HYBRID ; ESP **réutilisée** | Idem, vérifié par le script de post-contrôle |
| 7. Menu de démarrage + Windows amorçable | GRUB + os-prober (vérification en post-install automatique) | Idem + test réel d'amorçage Windows |
| 8. Procédure de récupération | Doc + Live USB avec `hybrid-repair-boot` | Idem + entrée « réparer HYBRID » dans GRUB |

## 3. Partitionnement cible (UEFI/GPT)

```
ESP existante (fat32, 200-500 Mo, NON FORMATÉE)  ← GRUB ajouté, Windows intact
  +
Partition racine HYBRID (ext4/btrfs, LUKS2) : / + /home (séparés si espace)
Option : /var séparé (données découplées du système, doc 02 §5)
```

- LUKS2 proposé par défaut, **TPM2 auto-enroll avec passphrase de secours**
  imprimée (doc 06) — jamais TPM seul.
- Taille minimale recommandée : 60 Go (affichée et contrôlée).

## 4. Scénarios d'échec — tests exigés avant toute diffusion

(Testés en CI/VM avec disques virtuels, doc 09 ; matériel réel en Phase 5
uniquement, sur machines de test dédiées, après sauvegarde.)

1. Espace insuffisant → refus propre, aucune écriture.
2. Disque endommagé (SMART KO) → interruption explicite.
3. BitLocker actif sans clé confirmée → blocage jusqu'à confirmation.
4. Coupure électrique en cours → état réanalysé au relancement, reprise ou
   annulation propre ; l'ESP sauvegardé est restaurable.
5. ESP plein → nettoyage proposé (uniquement d'anciennes entrées HYBRID),
   jamais de suppression d'entrées tierces automatique.
6. Windows non détecté alors qu'il existe → vérification manuelle imposée
   avant d'écrire (jamais d'os-prober aveugle accepté comme vérité).
7. Post-install : Windows démarre toujours (test automatique en VM avec
   disque Windows factice) — critère bloquant de publication.

## 5. Ce que v1 ne possède pas (honnêteté)

- L'assistant graphique custom n'existe pas en v1 : la Phase 5 du cahier
  des charges le construira et le prouvera sur machines de test.
- Le redimensionnement de partitions BitLocker **chiffrées** : détecté,
  refusé en automatique (risque) — mode expert documenté avec avertissement
  renforcé (suspendre BitLocker depuis Windows d'abord).
- MBR/Legacy BIOS : hors périmètre v1 (cahier des charges : UEFI/GPT) —
  message explicite dans l'installateur pour les machines legacy.
