/* BruceOS Calamares Slideshow */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    property color bgColor: "#1d1d20"
    property color accentColor: "#10b981"
    property color textColor: "#a1a1a5"
    property string fontFamily: "Red Hat Text"
    property string headingFont: "Red Hat Display"

    // Fill the entire widget with dark background
    Rectangle {
        anchors.fill: parent
        color: bgColor
        z: -1
    }

    Timer {
        interval: 8000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgColor
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Setting up BruceOS..."
                    font.family: headingFont
                    font.pixelSize: 28
                    font.bold: true
                    color: accentColor
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "They call me Bruce."
                    font.family: fontFamily
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
                    font.family: fontFamily
                    font.pixelSize: 14
                    color: textColor
                    lineHeight: 1.6
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgColor
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Your Terminal, Upgraded"
                    font.family: headingFont
                    font.pixelSize: 28
                    font.bold: true
                    color: accentColor
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Ghostty — GPU-accelerated, fast as light\nFish — smart autocomplete, zero config\nStarship — beautiful prompt\nZellij — split panes, sessions"
                    font.family: fontFamily
                    font.pixelSize: 14
                    color: textColor
                    lineHeight: 1.8
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgColor
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Create & Play"
                    font.family: headingFont
                    font.pixelSize: 28
                    font.bold: true
                    color: accentColor
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Steam + Proton — your games, native speed\nBlender, GIMP, Krita — create anything\nDaVinci Resolve — professional video\nAll pre-configured and ready to go"
                    font.family: fontFamily
                    font.pixelSize: 14
                    color: textColor
                    lineHeight: 1.8
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgColor
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "AI That Respects You"
                    font.family: headingFont
                    font.pixelSize: 28
                    font.bold: true
                    color: accentColor
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Pi coding agent in your terminal\nLocal AI via Ollama\nYour data stays on your machine\nNo cloud required"
                    font.family: fontFamily
                    font.pixelSize: 14
                    color: textColor
                    lineHeight: 1.8
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgColor
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.7
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Almost there..."
                    font.family: headingFont
                    font.pixelSize: 28
                    font.bold: true
                    color: accentColor
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "BruceOS is being installed to your drive.\nThis usually takes a few minutes.\nGrab a coffee — we've got this."
                    font.family: fontFamily
                    font.pixelSize: 14
                    color: textColor
                    lineHeight: 1.8
                }
            }
        }
    }

    // Calamares slideshow API 2 callbacks
    function onActivate() { presentation.activatedInCalamares = true; }
    function onLeave() { presentation.activatedInCalamares = false; }
}
