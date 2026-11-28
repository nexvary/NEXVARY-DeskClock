import QtQuick
import QtQuick.Layouts
import AeroRadar

Rectangle {
    id: panel
    required property string heading
    required property var details
    color: AeroTheme.bgPanel
    border.color: AeroTheme.borderDim
    radius: 4

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        Text {
            text: panel.heading
            color: AeroTheme.textPrime
            font.pixelSize: 24
            font.bold: true
        }

        Repeater {
            model: panel.details
            delegate: Text {
                required property string modelData
                Layout.fillWidth: true
                text: modelData
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: AeroTheme.textPrime
                font.pixelSize: 14
            }
        }

        Item { Layout.fillHeight: true }
    }
}
