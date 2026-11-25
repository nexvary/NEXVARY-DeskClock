import QtQuick
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
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 3
                    color: bigMa.containsMouse ? Qt.lighter(modelData.col, 1.4) : "#0d1e30"
                    border.color: modelData.col; border.width: 1
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 2
                        Text {
                            text: modelData.lbl; font.pixelSize: 11; font.bold: true
                            color: bigMa.containsMouse ? "#000" : modelData.col
                            font.family: AeroTheme.monoFont; Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: modelData.sub; font.pixelSize: 8
                            color: bigMa.containsMouse ? "#333" : AeroTheme.textDim
                            font.family: AeroTheme.monoFont; Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    MouseArea {
                        id: bigMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (!ctrlPanel.simulator) return;
                            if      (modelData.lbl === "PLAY")  ctrlPanel.simulator.play();
                            else if (modelData.lbl === "PAUSE") ctrlPanel.simulator.pause();
                            else                                 ctrlPanel.simulator.reset();
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

        // Track list
        ColumnLayout {
            Layout.fillWidth: true; spacing: 2
            Repeater {
                model: ctrlPanel.simulator ? ctrlPanel.simulator.tracks : []
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 38; radius: 2
                    color: modelData.selected ? "#0a2038" : "transparent"
                    border.color: modelData.selected ? AeroTheme.accentBlue : AeroTheme.borderDim
                    border.width: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8; anchors.rightMargin: 6; spacing: 6
                        Rectangle {
                            width: 7; height: 7; radius: 1
                            color: modelData.type === "UAS" ? AeroTheme.accentGreen : AeroTheme.accentBlue
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: modelData.label
                                font.pixelSize: 10; font.bold: true
                                color: AeroTheme.textPrime; font.family: AeroTheme.monoFont
                            }
                            Text {
                                text: modelData.type + "  " +
                                      modelData.speed_kt.toFixed(0) + "kt  " +
                                      modelData.altitude_m.toFixed(0) + "m"
                                font.pixelSize: 8; color: AeroTheme.textDim
                                font.family: AeroTheme.monoFont
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: ctrlPanel.simulator.selectTrack(modelData.id)
                    }
                }
            }
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
