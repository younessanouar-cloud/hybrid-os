/*
 * HYBRID OS — Design System OPALE : tokens (Phase 2, doc 07 §3)
 * Source unique de vérité pour TOUTES les applications natives.
 * Usage : import org.hybridos.opale 1.0 → OpaleTheme.eclair…
 */
pragma Singleton
import QtQuick 2.15

QtObject {
    // Fonds « opale noire »
    readonly property color nuit:    "#0A1628"   // fond principal
    readonly property color nuit2:   "#0E1F3C"   // surfaces
    readonly property color nuit3:   "#132750"   // surfaces élevées / focus
    readonly property color nuit4:   "#193950"   // champs

    // Accents (chatoyement adaptatif — doc 07 §2)
    readonly property color eclair:  "#3D7BFF"   // Équilibré
    readonly property color flambee: "#8B5CF6"   // Gaming / Sécurité
    readonly property color brume:   "#2DD4BF"   // Économie ; succès
    readonly property color ambre:   "#F59E0B"   // avertissements
    readonly property color rouge:  "#E5484D"   // erreurs / critique

    // Texte
    readonly property color lumiere:  "#F1F5FB"  // principal (contraste AAA)
    readonly property color lumiere2: "#A8B3CC"  // secondaire
}
