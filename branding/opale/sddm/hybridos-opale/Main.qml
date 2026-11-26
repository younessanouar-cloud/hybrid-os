/*
 * HYBRID OS — SDDM OPALE (Phase 2, doc 07 §6)
 * Écran de connexion minimal : fond bleu nuit, gemme, horloge, saisie
 * utilisateur/mot de passe. API officielle SDDM (contexte « sddm » :
 * sddm.login(user, password, sessionIndex), signal loginFailed).
 * Rendu à valider sur VM graphique / matériel (Phase 5) — présence et
 * câblage vérifiés par la CI (niveau 1).
 */
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    anchors.fill: parent
    color: "#0A1628"   // opale-nuit

    Image {
        id: gemme
        source: "images/opale.png"
        width: 200; height: 200
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.14
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: nomSysteme
        text: "H Y B R I D   O S"
        color: "#F1F5FB"
        opacity: 0.9
        font.pointSize: 14
        font.letterSpacing: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gemme.bottom
        anchors.topMargin: 24
    }

    // Horloge discrète en haut à droite
    Text {
        id: clock
        color: "#A8B3CC"
        font.pointSize: 12
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "dddd dd MMMM  hh:mm")
        }
    }

    // Carte de connexion « verre »
    Rectangle {
        id: carte
        width: 360; height: 230; radius: 14
        color: "#0E1F3C"
        opacity: 0.96
        border.color: "#3D7BFF"; border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 14

            TextField {
                id: champUtilisateur
                width: parent.width
                placeholderText: qsTr("Utilisateur")
                color: "#F1F5FB"
                font.pointSize: 11
                background: Rectangle {
                    radius: 8; color: "#132750"; border.color: champUtilisateur.activeFocus ? "#3D7BFF" : "#193950"
                }
                onAccepted: champMotDePasse.forceActiveFocus()
            }

            TextField {
                id: champMotDePasse
                width: parent.width
                placeholderText: qsTr("Mot de passe")
                echoMode: TextInput.Password
                color: "#F1F5FB"
                font.pointSize: 11
                background: Rectangle {
                    radius: 8; color: "#132750"; border.color: champMotDePasse.activeFocus ? "#3D7BFF" : "#193950"
                }
                onAccepted: boutonConnexion.clicked()
            }

            Button {
                id: boutonConnexion
                width: parent.width
                height: 38
                text: qsTr("Se connecter")

                background: Rectangle {
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0; color: boutonConnexion.hovered ? "#4d84ff" : "#3D7BFF" }
                        GradientStop { position: 1; color: boutonConnexion.hovered ? "#9a6ef8" : "#8B5CF6" }
                    }
                }
                contentItem: Text {
                    text: boutonConnexion.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: sddm.login(champUtilisateur.text, champMotDePasse.text, 0)
            }

            Text {
                id: messageErreur
                text: ""
                color: "#F59E0B"   // opale-ambre
                font.pointSize: 9
                visible: text !== ""
            }
        }
    }

    // Échec de connexion (signal réel de SDDM)
    Connections {
        target: sddm
        function onLoginFailed() {
            messageErreur.text = qsTr("Identifiant ou mot de passe incorrect.")
            champMotDePasse.text = ""
        }
    }

    // Pied discret
    Text {
        text: "HYBRID OS — Alpha"
        color: "#A8B3CC"
        opacity: 0.5
        font.pointSize: 9
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 18
    }
}
