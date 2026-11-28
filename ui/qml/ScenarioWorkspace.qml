import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtQuick.Layouts
import AeroRadar

Rectangle {
    id: page
    required property var simulator
    color: AeroTheme.bgPanel
    border.color: AeroTheme.borderDim
    radius: 4

    FileDialog {
        id: scenarioDialog
        title: qsTr("Open synthetic scenario")
        nameFilters: [qsTr("JSON scenario files (*.json)")]
        onAccepted: page.simulator.loadScenario(selectedFile)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        Text {
            text: qsTr("Scenarios")
            color: AeroTheme.textPrime
            font.pixelSize: 24
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            textFormat: Text.PlainText
            text: qsTr("Active scenario: %1 (%2 synthetic tracks)")
                .arg(page.simulator.scenarioName).arg(page.simulator.trackCount)
            color: AeroTheme.textPrime
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("Open a version 1 or 2 JSON scenario to start a new simulation in the paused state.")
            color: AeroTheme.textDim
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Button {
                objectName: "scenario-open"
                text: qsTr("Open JSON file…")
                onClicked: scenarioDialog.open()
            }
            Button {
                objectName: "scenario-builtin"
                text: qsTr("Load built-in scenario")
                onClicked: page.simulator.loadBuiltinScenario()
            }
        }

        Text {
            Layout.fillWidth: true
            objectName: "scenario-load-error"
            visible: text !== ""
            text: page.simulator.scenarioError
            color: AeroTheme.accentAmber
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }
    }
}
