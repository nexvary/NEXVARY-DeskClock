import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

// Right-side control panel: simulation state indicator, full-size PLAY /
// PAUSE / RESET buttons, active track list and synthetic-data disclaimer.
Rectangle {
    id: ctrlPanel
    color: AeroTheme.bgPanel
    border.color: AeroTheme.borderDim
    border.width: 1

    // ── Public interface ─────────────────────────────────────────────────
    property var simulator: null

    // ── Layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: "CONTROLS"
            font.pixelSize: 10; font.bold: true
            color: AeroTheme.textLabel; font.family: AeroTheme.monoFont
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: AeroTheme.borderDim }

        // Running / Paused indicator
        RowLayout {
            spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                color: ctrlPanel.simulator && !ctrlPanel.simulator.paused
                       ? AeroTheme.accentGreen : AeroTheme.accentAmber
            }
            Text {
                text: ctrlPanel.simulator && !ctrlPanel.simulator.paused ? "RUNNING" : "PAUSED"
                font.pixelSize: 11; font.bold: true
                color: ctrlPanel.simulator && !ctrlPanel.simulator.paused
                       ? AeroTheme.accentGreen : AeroTheme.accentAmber
                font.family: AeroTheme.monoFont
            }
        }

        // Full-size playback buttons
        ColumnLayout {
            Layout.fillWidth: true; spacing: 6
            Repeater {
                model: [
                    {lbl:"PLAY",  sub:"Resume simulation"},
                    {lbl:"PAUSE", sub:"Freeze simulation"},
                    {lbl:"RESET", sub:"Restore to T=0"}
                ]
                delegate: Button {
                    id: playback
                    required property var modelData
                    readonly property color actionColor: modelData.lbl === "PLAY"
                        ? AeroTheme.accentBlue : modelData.lbl === "PAUSE"
                        ? AeroTheme.accentAmber : AeroTheme.textDim
                    objectName: "simulation-" + modelData.lbl.toLowerCase()
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: modelData.lbl
                    enabled: ctrlPanel.simulator !== null
                    Accessible.description: modelData.sub
                    onClicked: {
                        if (modelData.lbl === "PLAY")
                            ctrlPanel.simulator.play()
                        else if (modelData.lbl === "PAUSE")
                            ctrlPanel.simulator.pause()
                        else
                            ctrlPanel.simulator.reset()
                    }

                    background: Rectangle {
                        radius: 3
                        color: playback.hovered ? AeroTheme.bgRaised : AeroTheme.bgCard
                        border.color: playback.activeFocus ? AeroTheme.textPrime : playback.actionColor
                        border.width: playback.activeFocus ? 2 : 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 2
                        Text {
                            text: playback.text
                            font.pixelSize: 11
                            font.bold: true
                            color: playback.actionColor
                            font.family: AeroTheme.monoFont
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: playback.modelData.sub
                            font.pixelSize: 10
                            color: AeroTheme.textDim
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Button {
                objectName: "simulation-step"
                text: qsTr("Step")
                enabled: ctrlPanel.simulator !== null && ctrlPanel.simulator.paused
                Accessible.description: qsTr("Advance the paused simulation by 0.1 seconds")
                onClicked: ctrlPanel.simulator.stepOnce()
            }

            ComboBox {
                objectName: "simulation-time-scale"
                Layout.fillWidth: true
                model: [
                    { label: "¼×", rate: 0.25 },
                    { label: "½×", rate: 0.5 },
                    { label: "1×", rate: 1.0 },
                    { label: "2×", rate: 2.0 },
                    { label: "4×", rate: 4.0 }
                ]
                textRole: "label"
                valueRole: "rate"
                currentIndex: model.findIndex(option =>
                    option.rate === (ctrlPanel.simulator ? ctrlPanel.simulator.timeScale : 1.0))
                enabled: ctrlPanel.simulator !== null
                Accessible.name: qsTr("Simulation playback speed")
                onActivated: function(index) { ctrlPanel.simulator.setTimeScale(model[index].rate) }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: AeroTheme.borderDim }

        Text {
            text: "ACTIVE TRACKS"
            font.pixelSize: 9; font.bold: true
            color: AeroTheme.textLabel; font.family: AeroTheme.monoFont
        }

        TrackList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            simulator: ctrlPanel.simulator
        }

        // Synthetic-data disclaimer
        Rectangle {
            Layout.fillWidth: true; height: 50; radius: 3
            color: AeroTheme.warningBg; border.color: AeroTheme.accentAmber; border.width: 1
            Text {
                anchors.centerIn: parent
                text: "DATA: SYNTHETIC\nNot for navigation"
                font.pixelSize: 8; color: AeroTheme.accentAmber
                horizontalAlignment: Text.AlignHCenter; font.family: AeroTheme.monoFont
            }
        }
    }
}
