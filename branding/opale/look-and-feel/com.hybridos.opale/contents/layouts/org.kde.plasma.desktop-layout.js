// =====================================================================
// HYBRID OS — disposition par défaut du bureau (Phase 2, doc 07 §6)
// Mécanisme standard Plasma : ce script est exécuté lors de la première
// création de la session pour poser la disposition HYBRID OS.
// API : new Panel(), panel.addWidget(), writeConfig() (documentée KDE).
// =====================================================================

// --- Dock HYBRID en bas de l'écran ---
var panel = new Panel("dock");
panel.location = "bottom";
panel.height = 52;
panel.hiding = "none";

// --- Lanceur universel (Kicker) ---
var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "start-here");
kickoff.writeConfig("favoritesPortedToMetadata", "true");

// --- Séparateur de marges ---
panel.addWidget("org.kde.plasma.marginsseparator");

// --- Espace extensible (pousse les tâches au centre) ---
panel.addWidget("org.kde.plasma.panelspacer");

// --- Barre des tâches par icônes (centrée) ---
var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "preferred://filemanager,preferred://browser");
tasks.writeConfig("separateLaunchers", "true");

// --- Espace extensible (équilibre le centre) ---
panel.addWidget("org.kde.plasma.panelspacer");

// --- Zone système (droite) : tray + horloge ---
panel.addWidget("org.kde.plasma.systemtray");
var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showSeconds", "false");
clock.writeConfig("showDate", "true");
clock.writeConfig("use24hFormat", "true");
