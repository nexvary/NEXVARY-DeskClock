import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

// Right-side control panel: simulation state indicator, full-size PLAY /
// PAUSE / RESET buttons, active track list and synthetic-data disclaimer.
Rectangle {
    id: ctrlPanel
    color: "#07101e"
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
                    {lbl:"PLAY",  sub:"Resume simulation", col:"#00CFFF"},
                    {lbl:"PAUSE", sub:"Freeze simulation",  col:"#f0b040"},
                    {lbl:"RESET", sub:"Restore to T=0",     col:"#5a7890"}
                ]
                delegate: Button {
                    id: playback
                    required property var modelData
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
                        color: playback.hovered ? "#14334f" : "#0d1e30"
                        border.color: playback.activeFocus ? AeroTheme.textPrime : playback.modelData.col
                        border.width: playback.activeFocus ? 2 : 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 2
                        Text {
                            text: playback.text
                            font.pixelSize: 11
                            font.bold: true
                            color: playback.modelData.col
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

        Rectangle { Layout.fillWidth: true; height: 1; color: AeroTheme.borderDim }

        Text {
            text: "ACTIVE TRACKS"
            font.pixelSize: 9; font.bold: true
            color: AeroTheme.textLabel; font.family: AeroTheme.monoFont
        }

        TrackList {
            Layout.fillWidth: true
            simulator: ctrlPanel.simulator
        }

        Item { Layout.fillHeight: true }

        // Synthetic-data disclaimer
        Rectangle {
            Layout.fillWidth: true; height: 50; radius: 3
            color: "#1a1000"; border.color: AeroTheme.accentAmber; border.width: 1
            Text {
                anchors.centerIn: parent
                text: "DATA: SYNTHETIC\nNot for navigation"
                font.pixelSize: 8; color: AeroTheme.accentAmber
                horizontalAlignment: Text.AlignHCenter; font.family: AeroTheme.monoFont
            }
        }
    }
}
