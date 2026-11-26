/*
 * HYBRID OS — KSplash OPALE (Phase 2)
 * Moteur : KSplashQML (Engine=KSplashQML, Theme=com.hybridos.opale)
 *
 * API officielle KSplash : le moteur met à jour la propriété « stage »
 * (étapes réelles du démarrage) au fil de l'initialisation — la barre
 * spectrale progresse donc sur de VRAIS événements de démarrage.
 * Rendu à valider sur VM graphique / matériel (Phase 5) — présence et
 * câblage vérifiés par la CI (niveau 1).
 */
import QtQuick 2.15

Item {
    id: root

    // Étapes réelles du démarrage (mises à jour par le moteur KSplash)
    property int stage: 0
    onStageChanged: {
        progress.width = Math.min(stage / 7.0, 1.0) * bar.width
        if (stage >= 7) {
            fadeout.start()
        }
    }

    Rectangle {
        id: fond
        anchors.fill: parent
        color: "#0A1628"   // opale-nuit (doc 07 §3)
    }

    // La gemme OPALE (opale facettée, fond transparent)
    Image {
        id: gemme
        source: "images/opale.png"
        width: 340; height: 340
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70
        fillMode: Image.PreserveAspectFit
    }

    // Nom du système
    Text {
        text: "H Y B R I D   O S"
        color: "#F1F5FB"
        opacity: 0.85
        font.pointSize: 16
        font.letterSpacing: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gemme.bottom
        anchors.topMargin: 36
    }

    // Barre de progression spectrale (étapes réelles)
    Rectangle {
        id: bar
        width: 320; height: 6; radius: 3
        color: "#132750"    // opale-nuit-3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 120
    }
    Rectangle {
        id: progress
        width: 0; height: 6; radius: 3
        anchors.left: bar.left
        anchors.verticalCenter: bar.verticalCenter
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#3D7BFF" }   // éclair
            GradientStop { position: 1.0; color: "#8B5CF6" }  // flambée
        }
        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
    }

    // Fondu de sortie à la fin des étapes réelles
    SequentialAnimation {
        id: fadeout
        PauseAnimation { duration: 300 }
        NumberAnimation {
            target: fond; property: "opacity"; to: 0
            duration: 600; easing.type: Easing.InQuad
        }
    }
}
