import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: sideBar
    color: "#222226"
    width: 220

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 2

        Image {
            source: "file:/" + Branding.imagePath(Branding.ProductLogo)
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            Layout.bottomMargin: 20
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Repeater {
            model: ViewManager
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: ViewManager.currentStepIndex === index ? "#2e2e32" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: display
                    color: ViewManager.currentStepIndex === index ? "#ffffff" : "#8a8a8e"
                    font.family: "Red Hat Text"
                    font.pixelSize: 13
                    font.weight: ViewManager.currentStepIndex === index ? Font.DemiBold : Font.Normal
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 8
            text: "BruceOS " + Branding.string(Branding.Version)
            color: "#4a4a4e"
            font.family: "Red Hat Text"
            font.pixelSize: 11
        }
    }
}
