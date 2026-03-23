/* BruceOS Calamares Sidebar — Horizontal bottom progress bar */
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: sideBar
    color: "#0a0a0a"
    height: 42
    width: parent.width

    RowLayout {
        anchors.fill: parent
        spacing: 4

        Image {
            Layout.leftMargin: 16
            Layout.rightMargin: 8
            Layout.alignment: Qt.AlignCenter
            width: 28
            height: 28
            source: "file:/" + Branding.imagePath(Branding.ProductLogo)
            sourceSize.width: width
            sourceSize.height: height
        }

        Repeater {
            model: ViewManager
            Rectangle {
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                height: 32
                radius: 6
                color: index == ViewManager.currentStepIndex ? "#10b981" : "transparent"

                Text {
                    anchors.centerIn: parent
                    color: index == ViewManager.currentStepIndex ? "#0a0a0a" : "#a1a1a1"
                    text: display
                    font.weight: index == ViewManager.currentStepIndex ? Font.Bold : Font.Normal
                    font.pointSize: index == ViewManager.currentStepIndex ? 10 : 9
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
