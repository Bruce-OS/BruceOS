/* SPDX-FileCopyrightText: no */
/* SPDX-License-Identifier: CC0-1.0 */

/*
 * BruceOS Calamares Slideshow
 * "They call me Bruce."
 *
 * Slideshow API 2 — auto-advances every 10 seconds.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Presentation {
    id: presentation

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#0a0a0a"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24
                width: parent.width * 0.75

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Welcome to BruceOS"
                    font.pixelSize: 32
                    font.family: "Red Hat Display"
                    font.bold: true
                    color: "#10b981"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "They call me Bruce."
                    font.pixelSize: 18
                    font.family: "Red Hat Text"
                    font.italic: true
                    color: "#9ca3af"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "A Linux distro for kids, artists and gamers.\nBuilt on Fedora. No nonsense. Just works."
                    font.pixelSize: 16
                    font.family: "Red Hat Text"
                    color: "#e5e5e5"
                    lineHeight: 1.4
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#0a0a0a"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24
                width: parent.width * 0.75

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Terminal, Reimagined"
                    font.pixelSize: 28
                    font.family: "Red Hat Display"
                    font.bold: true
                    color: "#10b981"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Ghostty GPU-accelerated terminal\nFish shell with smart autocomplete\nStarship prompt + Zellij multiplexer\nAll configured out of the box."
                    font.pixelSize: 16
                    font.family: "Red Hat Text"
                    color: "#e5e5e5"
                    lineHeight: 1.6
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#0a0a0a"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24
                width: parent.width * 0.75

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Create & Play"
                    font.pixelSize: 28
                    font.family: "Red Hat Display"
                    font.bold: true
                    color: "#10b981"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Steam, Proton and MangoHud for gaming.\nBlender, GIMP and Krita for artists.\nDaVinci Resolve for video.\nAdobe Photoshop via Wine."
                    font.pixelSize: 16
                    font.family: "Red Hat Text"
                    color: "#e5e5e5"
                    lineHeight: 1.6
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#0a0a0a"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24
                width: parent.width * 0.75

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "AI Built In"
                    font.pixelSize: 28
                    font.family: "Red Hat Display"
                    font.bold: true
                    color: "#10b981"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Local AI via Ollama — your data stays yours.\nGTK4 chat interface.\nMCP servers for filesystem, terminal and git.\nNo cloud required."
                    font.pixelSize: 16
                    font.family: "Red Hat Text"
                    color: "#e5e5e5"
                    lineHeight: 1.6
                }
            }
        }
    }
}
