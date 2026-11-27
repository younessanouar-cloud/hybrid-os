# Protocole de gestion des tokens — HYBRID OS

> Contrat entre le client et l'IA : le client choisit le modèle de la session,
> l'IA **signale à la fin de chaque réponse** le niveau requis pour la suite.
> Tags : `[FLASH-OK]` (continuer en économe) · `[RAISONNEMENT-REQUIS]` (bascule
> GLM 5.3 pour l'étape suivante) · `[STOP-AND-RAISONNEMENT]` (bascule
> immédiate — le diagnostic ne converge pas).

## Tâches FLASH (économe — hy4 flash)

1. Vérifier un run, télécharger un artefact, analyser des captures (PIL + stats)
2. Commit / push / dispatch workflow / surveillance CI
3. Générer des assets scriptés (PIL : wallpapers, logos, icônes — déterministe)
4. Docs de progression, README, ARBORESCENCE, mise à jour mémoire
5. **Appliquer un fix dont le log donne la cause explicite** (ex. les 10 fixes
   de la saga : *unit missing*, *manifest unknown*, *QHash incomplete*…)

## Tâches GLM 5.3 (raisonnement)

1. **Diagnostic qui ne converge pas après 2 tentatives du flash** — ou une
   contradiction entre observations multi-couches (ex. : *absent du système
   installé mais présent dans l'image*)
2. **Conception** : ADR, LUKS2+TPM dans le kickstart, policies SELinux custom
3. **Phase 5 — installateur dual boot custom** (zone à plus haut risque du
   cahier des charges)
4. Arbitrages de release / bêta (critères de publication)

## Règle de bascule automatique (contrat)

- **Si le modèle économe tourne en rond sur un échec après 2 correctifs** →
  remettre GLM 5.3 (signal `[STOP-AND-RAISONNEMENT]`).
- **À l'entrée en Phase 5** → GLM 5.3.
- **Retour en économe** dès que le diagnostic converge à nouveau.

## Mise en œuvre OpenCode

- Session économe = session de routine (lectures, artefacts, commits).
- Session raisonnement = session pour les points listés ci-dessus.
- La mémoire partagée (`AGENTS.md` + `LEARNINGS.md`) garantit qu'aucun des
  deux modes ne perd l'état du projet — le transfert inter-modèle est
  conçu par construction.

## Réduction du coût par tour (déjà active)

- Réponses courtes, pas de récital intermédiaire : la mémoire porte l'état.
- Tool calls groupés par tour.
- Le gros calcul reste sur GitHub Actions (0 token — ADR-002).
