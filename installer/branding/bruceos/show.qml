/* BruceOS Calamares Slideshow */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1d1d20"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Setting up BruceOS..."
                    font.family: "Red Hat Display"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "They call me Bruce."
                    font.family: "Red Hat Text"
                    font.pixelSize: 16
                    font.italic: true
                    color: "#6a6a6e"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "An operating system that just works.\nAll your favourite apps, gaming, creative tools,\nbuilt-in AI agents, and a terminal for the curious."
                    font.family: "Red Hat Text"
                    font.pixelSize: 14
                    color: "#a1a1a5"
                    lineHeight: 1.6
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1d1d20"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Your Terminal, Upgraded"
                    font.family: "Red Hat Display"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Ghostty — GPU-accelerated, fast as light\nFish — smart autocomplete, zero config\nStarship — beautiful prompt\nZellij — split panes, sessions"
                    font.family: "Red Hat Text"
                    font.pixelSize: 14
                    color: "#a1a1a5"
                    lineHeight: 1.8
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1d1d20"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Create & Play"
                    font.family: "Red Hat Display"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Steam + Proton — your games, native speed\nBlender, GIMP, Krita — create anything\nDaVinci Resolve — professional video\nAll pre-configured and ready to go"
                    font.family: "Red Hat Text"
                    font.pixelSize: 14
                    color: "#a1a1a5"
                    lineHeight: 1.8
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1d1d20"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "AI That Respects You"
                    font.family: "Red Hat Display"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Pi coding agent in your terminal\nLocal AI via Ollama\nYour data stays on your machine\nNo cloud required"
                    font.family: "Red Hat Text"
                    font.pixelSize: 14
                    color: "#a1a1a5"
                    lineHeight: 1.8
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1d1d20"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Almost there..."
                    font.family: "Red Hat Display"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#10b981"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "BruceOS is being installed to your drive.\nThis usually takes a few minutes.\nGrab a coffee — we've got this."
                    font.family: "Red Hat Text"
                    font.pixelSize: 14
                    color: "#a1a1a5"
                    lineHeight: 1.8
                }
            }
        }
    }
}
