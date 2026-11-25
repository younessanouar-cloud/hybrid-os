# 01 — Analyse de faisabilité

> Vérifications du 25 novembre 2026. Chaque affirmation majeure est sourcée.
> Distinction systématique : ✅ vérifié · ⚠️ à re-vérifier au build · ❓ inconnu.

## 1. Verdict global

**FAISABLE, à condition de rester honnête sur la définition d'« indépendance ».**

Construire « une distribution Linux indépendante » ne signifie pas recompiler
30 000 paquets ni écrire un noyau : cela signifie **maîtriser l'image système,
sa construction, son identité, ses mises à jour signées et son cycle de vie**,
tout en dérivant d'une base maintenue (Fedora). C'est exactement le modèle
prouvé par des distributions dérivées d'Atomic Desktops qui existent
aujourd'hui avec leur propre marque, installateur et dépôts.

## 2. Preuves d'existence (le modèle est déjà industrialisé)

| Preuve | Faits vérifiés (nov. 2026) | Ce que ça prouve pour HYBRID OS |
|---|---|---|
| **Fedora Image Mode Phase 2** (initiative officielle 2026) | Fedora unifie son écosystème immuable autour de **bootc** ; images OCI bootables officielles (`quay.io/fedora/fedora-bootc`) ; Fedora Magazine publie « Building your own Atomic (bootc) Desktop » | La personnalisation d'image est un chemin **officiel et documenté**, pas un hack |
| **Universal Blue** (Bluefin, **Bazzite**, Aurora) | Distributions indépendantes dérivées de Fedora Atomic GNOME/KDE : branding propre, images OCI signées (cosign/Sigstore), installateur custom, mises à jour OTA, enrollment de clés Secure Boot personnalisées (`ujust enroll-secure-boot-key`) | La totalité du modèle cible de HYBRID OS existe en production : identité, sécurité, mises à jour atomiques, installateur |
| **bootc-image-builder** (osbuild) | Génère images disque et **ISO type `anaconda-iso`** embarquant l'image conteneur → installation sans réseau possible ; documenté dans « Installing Fedora/CentOS bootc on Bare Metal » | La chaîne Containerfile → image → ISO installable est outillée et maintenue |
| **« Sealed Atomic Desktop » test images** (Fedora Magazine, avr. 2026, T. Ravier) | Images de test avec **systemd-boot + UKI signés Secure Boot** | La cible v2 (amorçage moderne signé) est en cours de stabilisation amont — à suivre, pas à improviser |

**Contre-exemples assumés** : une issue ouverte chez une dérivée majeure
(Bazzite #3418) documente que les méthodes d'installation « brutes »
(kickstart/bootc install non assistés) peuvent produire des systèmes non
utilisables sur leurs images custom. **Conséquence** : l'installateur est un
vrai chantier d'ingénierie (doc 05), pas une case à cocher.

## 3. Faisabilité par sous-projet

| Sous-projet | Faisabilité | Commentaire honnête |
|---|---|---|
| Image système atomique custom | ✅ Élevée | Containerfile + CI ; outillage officiel mature |
| Identité graphique complète (OPALE) | ✅ Élevée | Thèmes Plasma 6 (QML) puissants ; effort design conséquent mais maîtrisé |
| Sécurité (SELinux, LUKS2+TPM, pare-feu, audit) | ✅ Élevée | Tous hérités/activés par la base Fedora ; le travail = les garder ENFORCING sous la personnalisation + le Security Center |
| Secure Boot sans enrollment utilisateur | ✅ Élevée (v1) | Chaîne Fedora conservée ; **limites** : confiance déléguée aux clés Fedora |
| Secure Boot avec clés propres | ⚠️ Moyenne (v2) | Enrollment post-install prouvé par les dérivées ; « shim-review » signé Microsoft = hors de portée v1 |
| Hybrid Store (découverte + Flatpak) | ✅ Élevée | Frontal au-dessus de Flatpak/Flathub ; pas de réinvention du packaging |
| Wine/Proton optionnel | ✅ Moyenne-élevée | Steam Flatpak + Proton éprouvés ; compatibilité **non garantie** par logiciel (documentée par profils) |
| Installateur graphique dual boot robuste | ⚠️ Moyenne | Le plus gros chantier v1 ; parcours critique (doc 05) ; v1 s'appuie sur Anaconda, l'assistant custom vient ensuite |
| Noyau maison | ❌ Non retenu | Aucune justification technique au coût ; cahier des charges §3 |
| Compatibilité applications macOS | ❌ Hors périmètre v1 | Confirmé par le cahier des charges |

## 4. Contrainte majeure identifiée : l'environnement de développement

Le cahier des charges (§13) recommande i5/i7-Ryzen, 32 Go, NVMe 1 To pour
build + virtualisation. **La machine de développement disponible ne remplit
pas ces critères** (CPU basse consommation, 8 Go RAM, pas de GPU dédié).

### Mesure de réduction (décision ADR-002)

1. **Build 100 % cloud** : GitHub Actions (dépôt public → runners Linux
   gratuits : 4 cœurs/16 Go) exécutent `podman build` + `bootc-image-builder`.
   C'est la méthode utilisée par les dérivées existantes. Aucune ressource
   locale requise au-delà de l'édition du code.
2. **Tests VM locaux = smoke tests seulement** : QEMU possible localement
   mais lent ; les campagnes complètes (boot, install, rollback, dual boot
   simulé) tourneront aussi en CI ou sur machine dédiée à définir.
3. **Machines de test physiques** : nécessaires pour le dual boot réel
   (Phase 5) — jamais la machine principale (règle cahier des charges §13).
   À définir avec l'utilisateur (un PC UEFI « sacrifice » avec sauvegarde).

## 5. Définition honnête de l'« indépendance » (v1 → v3)

| Niveau | Contenu | Statut |
|---|---|---|
| Indépendance d'identité | Marque, design system OPALE, bureau, applications natives, installateur, store, security center | ✅ v1 |
| Indépendance de construction | Nos Containerfiles, notre CI, images signées par nos clés (cosign), manifeste figé des versions | ✅ v1 |
| Indépendance de cycle de vie | Politique de mises à jour, dépôts d'applications, fenêtres de test avant rebase Fedora | ✅ v1 (rebase suit Fedora avec délai de validation) |
| Indépendance d'amorçage | Chaîne Secure Boot 100 % HYBRID (nos clés, nos shim/GRUB ou UKI) | ⚠️ v2+ (enrollment assisté), éventuellement shim-review plus tard |
| Indépendance de base logicielle | Fork complet des paquets Fedora | ❌ Non visé v1 (coût sans bénéfice utilisateur) |

**Ce que cela implique** (transparence exigée par le cahier des charges) :
- HYBRID OS v1 **dérive de Fedora** et le dit clairement dans sa documentation
  et son à-propos. Mentions et licences Fedora respectées (GPL, etc.).
- Les mises à jour système suivent le rythme Fedora (≈ 2 bases/an) ; notre
  valeur ajoutée = fenêtre de test, image signée, intégration, pas un fork figé.

## 6. Conditions de réussite (pré-requis au feu vert Alpha 0.1)

1. Validation par le client de l'architecture (ce dossier).
2. Compte GitHub disponible pour le dépôt + Actions (✅ l'utilisateur en possède un).
3. Acceptation du principe « build en CI, test local minimal » (ADR-002).
4. Acceptation que le jalon Alpha 0.1 soit une ISO **amorçable en VM**, sans
   installateur custom, sans store, sans Secure Boot personnalisé.
5. Aucune machine physique touchée sans autorisation explicite ultérieure.
