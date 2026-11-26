# PREUVE D'AMORÇAGE — Alpha 0.1 (run CI 45719798169, 26/11/2026)

> Ce document consigne les **preuves réelles** du premier amorçage de HYBRID OS
> en machine virtuelle. Source : artefact `smoke-boot-trace` du run GitHub
> Actions 45719798169 (conclusion `success`), archivé ici car la rétention
> des artefacts CI est limitée à 90 jours.

## Contexte du run

| Élément | Valeur |
|---|---|
| Commit | `c7cd79d` (main) |
| Chaîne CI complète | matrix base+desktop → publish+sign → ISO → **smoke boot VM** : tous verts |
| Image de base (figée) | `quay.io/fedora/fedora-kinoite:45` @ `sha256:79f701ea…` |
| Image signée (GHCR) | `ghcr.io/younessanouar-cloud/hybridos:desktop-0.1.0-alpha.1` (cosign keyless, vérifiée dans le run) |
| ISO testée | `output/bootiso/install.iso` — **SHA256 : `10bda05f6626a5c93ed0416cf24fdf15685d473e78732a4d297bdabafa99a3e4`** |
| VM | QEMU TCG (émulation logicielle, sans KVM), machine q35, firmware UEFI **OVMF 4M** en mode pflash (CODE + VARS), 4096 Mo RAM, ISO attachée en cdrom, **aucun disque** ( Anaconda démarre sans rien écrire) |
| Durée | 36m39s (boot TCG long, timeout 1800 s atteint APRÈS validation des marqueurs) |

## Marqueurs constatés dans la trace série (smoke-boot-serial.log)

1. **Noyau de l'ISO démarré** :
   `[    0.000000] Linux version 7.2.11-300.fc45.x86_64 …`
2. **systemd initialisé** :
   `[   21.602414] systemd[1]: Reached target slices.target - Slice Units.`
3. **Chargeur d'installation Anaconda lancé** :
   `[ OK ] Created slice system-anaconda-tmx-slice - Slice /system/anaconda-tmux.`
   (Anaconda en mode texte/tmux — l'ISO embarque `osbuild.ks`, installation
   automatique par conception ; sans disque attaché, rien n'est écrit.)

## Ce que cela prouve

- L'ISO HYBRID OS **amorce en UEFI** (chaîne OVMF → noyau de l'ISO →
  initrd → stage2 Anaconda).
- La chaîne de build **CI → image signée → ISO → VM** est **fonctionnelle de
  bout en bout et reproductible**.

## Ce que cela NE prouve PAS (honnêteté, doc 09)

- Le menu GRUB complet (le smoke test utilise le direct kernel boot, qui
  saute GRUB).
- L'installation complète sur disque (l'étape suivante : kickstart + disque
  virtuel + redémarrage sur le système installé).
- Le mode graphique, le dual boot, les performances (phases suivantes).

## Fichiers joints (ce dossier)

- `smoke-boot-serial.log` — trace série complète du boot (107 855 caractères)
- `qemu-stderr.log` — fin par timeout SIGTERM prévu (code 124), après les marqueurs
