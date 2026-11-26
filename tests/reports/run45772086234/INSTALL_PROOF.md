# PREUVE D'INSTALLATION COMPLÈTE — Alpha 0.1 étape 7 (run 45772086234, 26/11/2026)

> Premier système HYBRID OS **installé (kickstart) et démarré depuis son propre
> disque**, mesuré à distance. Source : artefact `install-measure-reports` du run
> GitHub Actions 45772086234 (conclusion `success`), archivé ici.

## Résultats réels

| Élément | Valeur constatée |
|---|---|
| Installation Anaconda par kickstart (TCG) | **2821 s (~47 min)** — image 7,46 Go déployée sur disque virtuel vierge 40 Go |
| Noyau du système installé | **`7.3.4-300.fc45.x86_64`** (image desktop — distinct du noyau 7.2.11 de l'installateur) |
| Release | Fedora release 45 (Forty Five) |
| **SELinux après installation** | **`Current mode: enforcing`** ✅ — critère bloquant doc 09 |
| RAM au repos (`free -m`) | **461 Mo utilisés** / 3891 Mo — en `multi-user.target` (SANS bureau graphique) |
| Boot (`systemd-analyze`) | 1 min 13,131 s = kernel 6,028 s + initrd 21,804 s + userspace 45,297 s (**TCG**) |
| multi-user.target atteint | après 44,663 s en userspace (TCG) |
| ISO source | artefact du même run (rebase digest `72c24fe7…`) |

## Honnêteté — ce que ces mesures prouvent et ne prouvent PAS

1. **Prouvé** : la chaîne complète *ISO → installation kickstart automatisée →
   redémarrage sur le système installé → accès SSH → SELinux enforcing*.
   C'est le mécanisme de déploiement d'HYBRID OS, fonctionnel de bout en bout.
2. **Non représentatif du matériel réel** : QEMU TCG = émulation logicielle.
   Les objectifs du cahier des charges (RAM ≤ 1,8 Go **avec bureau**,
   boot ≤ 20 s) exigent la machine de référence (doc 09 §3) — Phase 5/6.
3. **RAM 461 Mo = sans bureau graphique** : mesuré en `multi-user.target`,
   avant toute session Plasma/SDDM. Sobre par construction, mais ce n'est
   PAS la métrique de la cible.
4. **Bug de mesure documenté** (à corriger dans `install_vm.sh`) : le
   « temps jusqu'à SSH » affiché (0 s) mesure l'ouverture du port `hostfwd`
   par QEMU (ouvert dès le lancement de la VM), **pas** la disponibilité de
   sshd — la vraie métrique de boot est celle de `systemd-analyze` (utilisée
   ci-dessus). Correction future : attendre la bannière SSH ou la première
   commande réussie.
5. **bootc status : non affiché** — la commande requiert des droits
   supérieurs à l'utilisateur SSH de test ; à mesurer en root plus tard
   (aucune conclusion tirée de cette absence).

## Fichiers joints (ce dossier)

- `install-measure-report.txt` — rapport brut des mesures
- `install-serial.log` — trace série de l'installation complète (196 920 car.)
- `boot-installed-serial.log` — trace série du boot du système installé
