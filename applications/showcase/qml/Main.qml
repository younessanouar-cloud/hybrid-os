/*
 * HYBRID OS — OPALE Showcase : galerie du design system (Phase 2)
 * Palette complète + composants libopale. Usage : vérification visuelle
 * du design system sur un écran réel (Phase 5).
 */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import org.hybridos.opale 1.0

ApplicationWindow {
    id: root
    width: 640; height: 720
    visible: true
    title: qsTr("OPALE — Galerie du design system")
    color: OpaleTheme.nuit

    Flickable {
        anchors.fill: parent
        contentHeight: colonne.height + 48
        clip: true

        ColumnLayout {
            id: colonne
            width: root.width - 48
            x: 24
            y: 24
            spacing: 18

            // --- En-tête ---
            Text {
                text: qsTr("H Y B R I D   O S")
                color: OpaleTheme.lumiere
                font.pointSize: 18; font.letterSpacing: 3
            }
            Text {
                text: qsTr("OPALE — design system · composants et palette")
                color: OpaleTheme.lumiere2
                font.pointSize: 10
            }

            // --- Palette : les 10 tokens, chaque pastille avec son nom ---
            OpaleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                accent: "flambee"

                GridLayout {
                    anchors.fill: parent
                    columns: 5
                    spacing: 12

                    Repeater {
                        model: [
                            { nom: "nuit",     col: OpaleTheme.nuit },
                            { nom: "nuit2",    col: OpaleTheme.nuit2 },
                            { nom: "nuit3",    col: OpaleTheme.nuit3 },
                            { nom: "eclair",   col: OpaleTheme.eclair },
                            { nom: "flambee",  col: OpaleTheme.flambee },
                            { nom: "brume",    col: OpaleTheme.brume },
                            { nom: "ambre",    col: OpaleTheme.ambre },
                            { nom: "rouge",    col: OpaleTheme.rouge },
                            { nom: "lumiere",  col: OpaleTheme.lumiere },
                            { nom: "lumiere2", col: OpaleTheme.lumiere2 }
                        ]
                        ColumnLayout {
                            spacing: 4
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 60; height: 60; radius: 8
                                color: modelData.col
                                border.color: OpaleTheme.lumiere2; border.width: 1
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.nom
                                color: OpaleTheme.lumiere2
                                font.pointSize: 8
                            }
                        }
                    }
                }
            }

            // --- OpaleButton : les 3 variantes ---
            OpaleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                accent: "eclair"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    Text {
                        text: qsTr("OpaleButton")
                        color: OpaleTheme.lumiere2; font.pointSize: 9
                    }
                    RowLayout {
                        spacing: 14
                        OpaleButton { text: qsTr("Équilibré"); implicitWidth: 140 }
                        OpaleButton { text: qsTr("Gaming"); implicitWidth: 140 }   // accent flambee par défaut du bouton
                        OpaleButton { text: qsTr("Économie"); accentBrume: true; implicitWidth: 140 }
                    }
                }
            }

            // --- OpaleCard : les 4 accents ---
            RowLayout {
                spacing: 12
                Layout.fillWidth: true
                OpaleCard { Layout.fillWidth: true; Layout.preferredHeight: 90; accent: "eclair" }
                OpaleCard { Layout.fillWidth: true; Layout.preferredHeight: 90; accent: "flambee" }
                OpaleCard { Layout.fillWidth: true; Layout.preferredHeight: 90; accent: "brume" }
                OpaleCard { Layout.fillWidth: true; Layout.preferredHeight: 90; accent: "ambre" }
            }
        }
    }
}
