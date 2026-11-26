/*
 * HYBRID OS — Security Center (Phase 3 ébauche, doc 06 §2)
 * Règle absolue (doc 06) : chaque rubrique affiche le résultat RÉEL d'une
 * commande système (SecurityBridge). En cas d'échec de la commande :
 * « non vérifiable » — JAMAIS de valeur simulée, JAMAIS de placeholder.
 * Les rubriques non câblées (chiffrement, mises à jour, journal) seront
 * ajoutées quand leurs sources seront branchées (Phase 3).
 */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import org.hybridos.opale 1.0

ApplicationWindow {
    id: root
    width: 720; height: 560
    visible: true
    title: qsTr("HYBRID Security Center")
    color: OpaleTheme.nuit

    // État reçu du pont (résultats réels)
    property var resultats: ({})
    property var reussis: ({})

    Connections {
        target: securityBridge
        function onReady(key, value, ok) {
            root.resultats[key] = value
            root.reussis[key] = ok
            root.resultatsChanged()
            root.reussisChanged()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // --- En-tête ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            Image {
                source: "file:///usr/share/icons/hicolor/48/apps/start-here.png"
                Layout.preferredWidth: 42; Layout.preferredHeight: 42
                fillMode: Image.PreserveAspectFit
            }
            ColumnLayout {
                spacing: 2
                Text {
                    text: qsTr("Centre de sécurité")
                    color: OpaleTheme.lumiere
                    font.pointSize: 20; font.bold: true
                }
                Text {
                    text: qsTr("État réel du système — chaque valeur provient d'une vérification en cours")
                    color: OpaleTheme.lumiere2
                    font.pointSize: 10
                }
            }
            Item { Layout.fillWidth: true }
        }

        // --- Rubriques REELLES (une par source câblée) ---
        Repeater {
            model: [
                { key: "release",    titre: qsTr("Système"),         accent: "eclair" },
                { key: "kernel",     titre: qsTr("Noyau"),           accent: "eclair" },
                { key: "image",      titre: qsTr("Image système"),  accent: "eclair" },
                { key: "selinux",    titre: qsTr("SELinux"),         accent: "flambee" },
                { key: "firewall",   titre: qsTr("Pare-feu"),        accent: "flambee" },
                { key: "secureboot", titre: qsTr("Secure Boot"),   accent: "flambee" },
                { key: "chiffrement", titre: qsTr("Chiffrement"),   accent: "brume" },
                { key: "journal",    titre: qsTr("Journal système"), accent: "brume" }
            ]
            OpaleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 74
                accent: modelData.accent

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: modelData.titre
                            color: OpaleTheme.lumiere2
                            font.pointSize: 9
                            font.letterSpacing: 1
                        }
                        Text {
                            text: {
                                if (!(modelData.key in root.resultats))
                                    return qsTr("vérification…")
                                return root.reussis[modelData.key]
                                       ? root.resultats[modelData.key]
                                       : qsTr("non vérifiable")
                            }
                            color: (modelData.key in root.resultats)
                                   ? (root.reussis[modelData.key]
                                      ? OpaleTheme.lumiere
                                      : OpaleTheme.ambre)
                                   : OpaleTheme.lumiere2
                            font.pointSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Pastille d'état (basée sur le résultat réel)
                    Rectangle {
                        width: 14; height: 14; radius: 7
                        color: {
                            if (!(modelData.key in root.resultats))
                                return OpaleTheme.nuit3
                            return root.reussis[modelData.key]
                                   ? OpaleTheme.brume
                                   : OpaleTheme.ambre
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // --- Pied honnête (doc 06 : pas un antivirus) ---
        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: OpaleTheme.lumiere2
            opacity: 0.7
            font.pointSize: 8
            text: qsTr("Tableau de bord d'état du système — ce n'est PAS un antivirus temps réel. " +
                       "Chaque valeur est le résultat d'une vérification réelle au moment de " +
                       "l'ouverture (échec de vérification = « non vérifiable »).")
        }
    }
}
