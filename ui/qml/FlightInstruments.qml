import QtQuick
import QtQuick.Layouts
import AeroRadar

// Horizontal instrument strip: five data fields for the selected track, plus
// the simulated-time clock and mini PLAY / PAUSE / RESET controls.
// Shows placeholder dashes when no track is selected.
Rectangle {
    id: instruments
    height: 86
    color: AeroTheme.bgPanel
    border.color: AeroTheme.borderDim
    border.width: 1
    radius: 4
    clip: true

    // ── Public interface ─────────────────────────────────────────────────
    property var simulator: null

    // ── Layout ───────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        // Five instrument readouts
        Repeater {
            model: (instruments.simulator &&
                    instruments.simulator.selected &&
                    instruments.simulator.selected.id !== undefined) ? [
                {lbl:"ALTITUDE", val: instruments.simulator.selected.altitude_m.toFixed(0), unit:"m MSL"},
                {lbl:"SPEED",    val: instruments.simulator.selected.speed_kt.toFixed(1),   unit:"kt"},
                {lbl:"HEADING",  val: instruments.simulator.selected.heading_deg.toFixed(0),unit:"° (CW/N)"},
                {lbl:"RANGE",    val: instruments.simulator.selected.range_km.toFixed(2),   unit:"km"},
                {lbl:"TRACK ID", val: instruments.simulator.selected.label,                 unit:instruments.simulator.selected.type}
            ] : [
                {lbl:"ALTITUDE", val:"--", unit:"m MSL"},
                {lbl:"SPEED",    val:"--", unit:"kt"},
                {lbl:"HEADING",  val:"--", unit:"°"},
                {lbl:"RANGE",    val:"--", unit:"km"},
                {lbl:"TRACK ID", val:"--", unit:"Select track"}
            ]
            delegate: RowLayout {
                spacing: 0
                Rectangle { width: 1; height: 50; color: AeroTheme.borderDim; visible: index > 0 }
                ColumnLayout {
                    spacing: 2; Layout.leftMargin: 20; Layout.rightMargin: 20
                    Text {
                        text: modelData.lbl
                        font.pixelSize: 9; color: AeroTheme.textLabel
                        font.family: AeroTheme.monoFont; font.bold: true
                    }
                    Text {
                        text: modelData.val
                        font.pixelSize: 20; font.bold: true
                        color: AeroTheme.accentBlue; font.family: AeroTheme.monoFont
                    }
                    Text {
                        text: modelData.unit
                        font.pixelSize: 9; color: AeroTheme.textDim
                        font.family: AeroTheme.monoFont
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Sim clock + mini playback buttons
        ColumnLayout {
            spacing: 4; Layout.rightMargin: 8

            Text {
                text: instruments.simulator ? instruments.simulator.simTimeDisplay : "--:--:--"
                font.pixelSize: 22; font.bold: true; color: AeroTheme.textPrime
                font.family: AeroTheme.monoFont; Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                spacing: 6; Layout.alignment: Qt.AlignHCenter
                Repeater {
                    model: [
                        {lbl:"PLAY",  col:"#00CFFF"},
                        {lbl:"PAUSE", col:"#f0b040"},
                        {lbl:"RESET", col:"#5a7890"}
                    ]
                    delegate: Rectangle {
                        width: 54; height: 22; radius: 2
                        color: ctlMa.containsMouse ? Qt.lighter(modelData.col, 1.3) : "transparent"
                        border.color: modelData.col; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData.lbl; font.pixelSize: 9; font.bold: true
                            color: ctlMa.containsMouse ? "#000" : modelData.col
                            font.family: AeroTheme.monoFont
                        }
                        MouseArea {
                            id: ctlMa; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                if (!instruments.simulator) return;
                                if      (modelData.lbl === "PLAY")  instruments.simulator.play();
                                else if (modelData.lbl === "PAUSE") instruments.simulator.pause();
                                else                                 instruments.simulator.reset();
                            }
                        }
                    }
                }
            }
        }
    }
}
