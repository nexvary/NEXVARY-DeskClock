import QtQuick
import QtQuick.Layouts
import AeroRadar

// Application header: title bar, simulation-only warning badge, run/pause
// status pill, and the multi-field status data row.
Rectangle {
    id: strip
    color: "#080f1c"
    height: 90
    border.color: AeroTheme.borderDim
    border.width: 1

    // ── Public interface ─────────────────────────────────────────────────
    property var    simulator:    null
    property string utcWallClock: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Title row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.leftMargin: 16; Layout.rightMargin: 16
            spacing: 12

            Text {
                text: "NEXVARY AeroRadar"
                font.pixelSize: 20; font.bold: true; color: AeroTheme.textPrime
            }
            Text {
                text: "CIVIL AVIATION RESEARCH  |  SIMULATION LAB"
                font.pixelSize: 10; color: AeroTheme.textDim; font.letterSpacing: 2
            }
            Item { Layout.fillWidth: true }

            // Simulation-only warning badge
            Rectangle {
                height: 28; radius: 4
                width: warnText.implicitWidth + 24
                color: "#2a1800"
                border.color: AeroTheme.accentAmber; border.width: 1
                Row {
                    anchors.centerIn: parent; spacing: 6
                    Text {
                        text: "WARNING"
                        font.pixelSize: 10; font.bold: true; color: AeroTheme.accentAmber
                    }
                    Text {
                        id: warnText
                        text: "SIMULATION ONLY  |  NO LIVE DATA"
                        font.pixelSize: 11; font.bold: true; color: AeroTheme.accentAmber
                    }
                }
            }

            // Run / Paused status pill
            Rectangle {
                height: 28; radius: 4
                width: runLabel.implicitWidth + 28
                color: strip.simulator && !strip.simulator.paused ? "#0a2a10" : "#1a1a0a"
                border.color: strip.simulator && !strip.simulator.paused
                              ? AeroTheme.accentGreen : AeroTheme.accentAmber
                border.width: 1
                Row {
                    anchors.centerIn: parent; spacing: 6
                    Rectangle {
                        width: 7; height: 7; radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: strip.simulator && !strip.simulator.paused
                               ? AeroTheme.accentGreen : AeroTheme.accentAmber
                        SequentialAnimation on opacity {
                            running: strip.simulator && !strip.simulator.paused
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.2; duration: 600 }
                            NumberAnimation { to: 1.0; duration: 400 }
                        }
                    }
                    Text {
                        id: runLabel
                        text: strip.simulator && !strip.simulator.paused
                              ? "SIMULATION RUNNING" : "SIMULATION PAUSED"
                        font.pixelSize: 11; font.bold: true
                        color: strip.simulator && !strip.simulator.paused
                               ? AeroTheme.accentGreen : AeroTheme.accentAmber
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: AeroTheme.borderDim }

        // Status data row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 43
            Layout.leftMargin: 16; Layout.rightMargin: 16
            spacing: 0

            Repeater {
                model: [
                    {lbl:"TRACKS",         val: strip.simulator ? String(strip.simulator.trackCount) : "--",        unit:"(Simulated)"},
                    {lbl:"SCENARIO",       val: "Research-01",                                                       unit:"Multi-Platform Test"},
                    {lbl:"UTC WALL CLOCK", val: strip.utcWallClock,                                                   unit:""},
                    {lbl:"ELAPSED",        val: strip.simulator ? strip.simulator.simTimeDisplay : "00:00:00",        unit:""},
                    {lbl:"WEATHER (SIM)",  val: "Clear  18 C",                                                       unit:"Wind 12kt NW(310)"},
                    {lbl:"ENVIRONMENT",    val: "Coastal / Mountain",                                                 unit:""},
                ]
                delegate: RowLayout {
                    spacing: 0
                    Rectangle { width: 1; height: 34; color: AeroTheme.borderDim; visible: index > 0 }
                    ColumnLayout {
                        spacing: 1; Layout.leftMargin: 18; Layout.rightMargin: 18
                        Text { text: modelData.lbl;  font.pixelSize: 9;  color: AeroTheme.textLabel; font.letterSpacing: 1 }
                        Text { text: modelData.val;  font.pixelSize: 14; font.bold: true; color: AeroTheme.textPrime }
                        Text { text: modelData.unit; font.pixelSize: 9;  color: AeroTheme.textDim; visible: modelData.unit !== "" }
                    }
                }
            }
            Item { Layout.fillWidth: true }
        }
    }
}
