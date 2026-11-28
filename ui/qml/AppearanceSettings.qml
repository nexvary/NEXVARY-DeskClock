import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

Rectangle {
    color: AeroTheme.bgPanel
    border.color: AeroTheme.borderDim
    radius: 4

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        Text {
            text: qsTr("Appearance")
            color: AeroTheme.textPrime
            font.pixelSize: 24
            font.bold: true
        }

        Switch {
            id: lightSwitch
            objectName: "appearance-light"
            text: qsTr("Light mode")
            checked: AeroTheme.lightMode
            onToggled: AeroTheme.setLightMode(checked)

            contentItem: Text {
                text: lightSwitch.text
                leftPadding: lightSwitch.indicator.width + lightSwitch.spacing
                verticalAlignment: Text.AlignVCenter
                color: AeroTheme.textPrime
                font.pixelSize: 14
            }
        }

        Item { Layout.fillHeight: true }
    }
}
