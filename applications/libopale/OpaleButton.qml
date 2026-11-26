/*
 * HYBRID OS — Design System OPALE : bouton « gemme » (doc 07 §6)
 * Bouton spectral éclair→flambée, états hover/focus visibles au clavier
 * (accessibilité doc 07 §7 : le focus ne porte jamais seul l'info).
 */
import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.hybridos.opale 1.0

Controls.Button {
    id: root

    property bool accentBrume: false   // variante « Économie »

    implicitHeight: 38
    font.pointSize: 11

    background: Rectangle {
        radius: 8
        border.width: root.activeFocus ? 2 : 0
        border.color: OpaleTheme.brume   // focus visible (accessibilité)
        gradient: Gradient {
            GradientStop {
                position: 0
                color: root.accentBrume
                       ? (root.hovered ? "#41e2d0" : OpaleTheme.brume)
                       : (root.hovered ? "#4d84ff" : OpaleTheme.eclair)
            }
            GradientStop {
                position: 1
                color: root.accentBrume
                       ? (root.hovered ? "#2ba99c" : "#20b2a6")
                       : (root.hovered ? "#9a6ef8" : OpaleTheme.flambee)
            }
        }
    }

    contentItem: Text {
        text: root.text
        color: "white"
        font: root.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
