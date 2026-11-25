# 06 — Sécurité (défense en profondeur)

> Priorité absolue du cahier des charges (§5). **Principe directeur** :
> intégrer, tester, documenter les limites. Ne jamais présenter un tableau
> de bord comme un antivirus. Ne jamais garantir une sécurité absolue.

## 1. Couches de défense

| Couche | Mécanismes v1 | État | Limites assumées |
|---|---|---|---|
| Amorçage | Secure Boot chaîne Fedora ; image atomique `/usr` read-only ; rollback natif | ✅ v1 | Confiance déléguée aux clés Fedora (v2 : clés propres, doc 04 §3) |
| Données au repos | LUKS2 sur / et /home ; TPM 2.0 (Clevis/systemd-cryptenroll) **+ passphrase de secours imprimée** | ✅ v1 | Cold boot attacks non contrecarrées par LUKS seul ; TPM ≠ prétexte à supprimer la secours |
| Contrôle d'accès | SELinux **enforcing** (policy targeted Fedora + tuning testé) ; comptes non privilégiés ; sudo/PKEXEC ponctuel et journalisé | ✅ v1 | SELinux reste activé même si un composant custom pose problème → on adapte la policy, on ne coupe jamais (règle §12) |
| Réseau | firewalld actif par défaut (zone publique : services minimaux) ; aucune écoute par défaut ; IPv6 idem | ✅ v1 | Le filtrage sortant reste un chantier v2 (doc 08, risque R-11) |
| Applications | Flatpak sandbox + permissions révisées ; Flathub vérifié ; pas d'exécution auto des téléchargements ; Wine isolé (prefixes séparés) | ✅ v1 | Sandbox Flatpak ≠ frontière absolue (évasions documentées) ; Wine = surface d'attaque assumée |
| Intégrité | Images OCI signées cosign ; `bootc` vérifie la signature/commit au pull ; fwupd/secureboot status exposés | ✅ v1 | Pas de « verrouillage » du firmware OEM ; `/-boot` et ESP : surfaces héritées (doc 04 §6) |
| Journalisation | journald persistant ; événements de sécurité structurés (logins sudo, échecs, mises à jour, policy denies) | ✅ v1 | Rotation + conservation définies (90 j défaut, configurable) |

## 2. Hybrid Security Center (exigence §5 du cahier des charges)

**Architecture** : application native Kirigami/QML (identité OPALE) qui
**agrège des sources système réelles** — chaque information affichée
provient d'un appel réel, aucune valeur simulée (règle §12) :

| Panneau | Source technique réelle |
|---|---|
| État Secure Boot / chaîne | `mokutil --sb-state`, `bootctl status`, fwupd |
| Chiffrement | `cryptsetup status`, lsblk, presence TPM (`/dev/tpmrm0`) |
| SELinux | `sestatus`/AVC récents via journald |
| Pare-feu | firewalld D-Bus |
| Mises à jour & vulnérabilités | `bootc status`, historique déploiements, liens advisories Fedora |
| Apps à permissions sensibles | Flatpak `--metadata` (portails : mic, caméra, localisation, fichiers) |
| Connexions réseau | ss/ss-llmnr résumé + firewalld (aucune télémétrie sortante) |
| Menaces détectées | **v1 : journal des événements de sécurité** — PAS un antivirus actif (aucune promesse de scan temps réel) |

**Honnêteté produit** (exigée) : le Security Center v1 est un **tableau de
bord d'état + pédagogie** (« que signifie SELinux ? que faire si BitLocker
demande une clé ? »). La détection active de menaces n'existe pas en v1 et
ne sera jamais présentée comme telle (règle : toute « détection » future
sera branchée sur une source technique réelle + limites documentées).

## 3. Règles de sécurité du projet (non négociables)

1. SELinux ne sera **jamais** désactivé pour faire passer un test (§12).
2. Toute élévation de privilèges est ponctuelle, motivée, journalisée.
3. Les secrets de signature vivent hors du dépôt (règle §10) — HSM ou
   support chiffré dédié, jamais dans Git.
4. Les CVE amont (Fedora) sont suivies ; notre fenêtre de test CI (doc 09)
   définit le délai maximal de re-diffusion d'une image corrigée.
5. Aucune télémétrie par défaut ; toute collecte optionnelle sera explicite,
  hors-ligne par défaut et documentée.
