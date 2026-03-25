import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: navigationBar
    color: "#1d1d20"
    height: 64
    width: parent.width

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 12

        Item { Layout.fillWidth: true }

        Rectangle {
            id: backBtn
            width: 100; height: 38
            radius: 8
            color: backMouse.containsMouse ? "#2e2e32" : "transparent"
            visible: ViewManager.backAndNextVisible
            enabled: ViewManager.backEnabled
            opacity: enabled ? 1.0 : 0.4

            Text {
                anchors.centerIn: parent
                text: qsTr("Back")
                color: "#a1a1a5"
                font.family: "Red Hat Text"
                font.pixelSize: 13
            }
            MouseArea {
                id: backMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ViewManager.back()
            }
        }

        Rectangle {
            id: nextBtn
            width: 100; height: 38
            radius: 8
            color: nextMouse.containsMouse ? "#34d399" : "#10b981"
            visible: ViewManager.backAndNextVisible
            enabled: ViewManager.nextEnabled
            opacity: enabled ? 1.0 : 0.4

            Text {
                anchors.centerIn: parent
                text: qsTr("Next")
                color: "#022c22"
                font.family: "Red Hat Text"
                font.pixelSize: 13
                font.weight: Font.Bold
            }
            MouseArea {
                id: nextMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ViewManager.next()
            }
        }

        Rectangle {
            id: cancelBtn
            width: 100; height: 38
            radius: 8
            color: cancelMouse.containsMouse ? "#dc2626" : "transparent"
            visible: ViewManager.quitVisible
            enabled: ViewManager.quitEnabled

            Text {
                anchors.centerIn: parent
                text: qsTr("Cancel")
                color: cancelMouse.containsMouse ? "#ffffff" : "#a1a1a5"
                font.family: "Red Hat Text"
                font.pixelSize: 13
            }
            MouseArea {
                id: cancelMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ViewManager.quit()
            }
        }
    }
}
