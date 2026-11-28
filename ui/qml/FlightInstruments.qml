import QtQuick
import QtQuick.Layouts
import AeroRadar

// Horizontal instrument strip: five data fields for the selected track, plus
// the simulated-time clock.
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
                {lbl:"ALTITUDE", val: instruments.simulator.selected.altitude_m.toFixed(0), unit:"m"},
                {lbl:"SPEED",    val: instruments.simulator.selected.speed_kt.toFixed(1),   unit:"kt"},
                {lbl:"HEADING",  val: instruments.simulator.selected.heading_deg.toFixed(0),unit:"° (CW/N)"},
                {lbl:"RANGE",    val: instruments.simulator.selected.range_km.toFixed(2),   unit:"km"},
                {lbl:"TRACK ID", val: instruments.simulator.selected.label,                 unit:instruments.simulator.selected.type}
            ] : [
                {lbl:"ALTITUDE", val:"--", unit:"m"},
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

            Text {
                text: qsTr("SIMULATION TIME")
                font.pixelSize: 10
                color: AeroTheme.textDim
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
