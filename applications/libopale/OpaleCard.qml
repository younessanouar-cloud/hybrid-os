/*
 * HYBRID OS — Design System OPALE : carte « verre » (doc 07 §6)
 * Panneau de surface avec liseré d'accent. Sans effet de flou réel en
 * QML pur (le blur s'ajoutera dans les applications Plasma avec les
 * effets graphiques KWin) — la carte v0 est translucide sobre.
 */
import QtQuick 2.15
import org.hybridos.opale 1.0

Rectangle {
    id: root

    // Variantes d'accent : "eclair" (défaut) | "flambee" | "brume" | "ambre"
    property string accent: "eclair"

    radius: 14
    color: OpaleTheme.nuit2
    opacity: 0.97
    border.width: 1
    border.color: {
        if (accent === "flambee") return OpaleTheme.flambee
        if (accent === "brume")   return OpaleTheme.brume
        if (accent === "ambre")   return OpaleTheme.ambre
        return OpaleTheme.eclair
    }

    // Liseré spectral supérieur (signature OPALE)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        anchors.topMargin: 0
        height: 3
        radius: 2
        gradient: Gradient {
            GradientStop { position: 0; color: OpaleTheme.eclair }
            GradientStop { position: 1; color: OpaleTheme.flambee }
        }
    }

    default property alias contenu: zoneContenu.data

    Item {
        id: zoneContenu
        anchors.fill: parent
        anchors.margins: 16
    }
}
