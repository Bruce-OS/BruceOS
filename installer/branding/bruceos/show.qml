/* BruceOS Calamares Slideshow */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    background: Rectangle { color: "#0a0a0a" }

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
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Welcome to BruceOS"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "They call me Bruce."
                    font.pixelSize: 18
                    font.italic: true
                    color: "#9ca3af"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "An operating system for you.\nAll your favourite apps, gaming that works,\nbuilt-in agents, and a terminal for nerds."
                    font.pixelSize: 16
                    color: "#e5e5e5"
                    lineHeight: 1.5
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
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Terminal, Reimagined"
                    font.pixelSize: 28
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
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Create & Play"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Steam, Proton and MangoHud for gaming.\nBlender, GIMP and Krita for artists.\nDaVinci Resolve for video.\nAll pre-configured."
                    font.pixelSize: 16
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
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "AI Built In"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Pi coding agent in your terminal.\nLocal AI via Ollama — your data stays yours.\nNo cloud. No subscription.\nJust works."
                    font.pixelSize: 16
                    color: "#e5e5e5"
                    lineHeight: 1.6
                }
            }
        }
    }
}
