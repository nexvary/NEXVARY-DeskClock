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
    property string statusMessage: ""

    Component.onCompleted: editor.text = simulator.scenarioText
    Connections {
        target: page.simulator
        function onScenarioChanged() {
            editor.text = page.simulator.scenarioText
            page.statusMessage = ""
        }
    }

    FileDialog {
        id: scenarioDialog
        title: qsTr("Open synthetic scenario")
        nameFilters: [qsTr("JSON scenario files (*.json)")]
        onAccepted: {
            page.statusMessage = ""
            page.simulator.loadScenario(selectedFile)
        }
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save synthetic scenario")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "json"
        nameFilters: [qsTr("JSON scenario files (*.json)")]
        onAccepted: {
            page.statusMessage = page.simulator.saveScenarioText(selectedFile, editor.text)
                ? qsTr("Scenario saved.") : ""
        }
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
            text: qsTr("Edit version 1 or 2 JSON. Apply starts the edited scenario paused. Save writes the draft to a file.")
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
            Button {
                objectName: "scenario-apply"
                text: qsTr("Apply draft")
                onClicked: {
                    page.statusMessage = page.simulator.applyScenarioText(editor.text)
                        ? qsTr("Edited scenario applied.") : ""
                }
            }
            Button {
                objectName: "scenario-save"
                text: qsTr("Save draft…")
                onClicked: saveDialog.open()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                id: editor
                objectName: "scenario-editor"
                Accessible.name: qsTr("Synthetic scenario JSON")
                textFormat: TextEdit.PlainText
                font.family: AeroTheme.monoFont
                wrapMode: TextEdit.NoWrap
                selectByMouse: true
                background: Rectangle {
                    color: AeroTheme.bgCard
                    border.color: AeroTheme.borderDim
                }
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

        Text {
            Layout.fillWidth: true
            visible: page.statusMessage !== ""
            text: page.statusMessage
            color: AeroTheme.accentGreen
        }
    }
}
