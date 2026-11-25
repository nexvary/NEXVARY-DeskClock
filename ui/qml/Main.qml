import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

// NEXVARY AeroRadar — Simulation Lab Dashboard
// DATA: SYNTHETIC / SIMULATED.  No live aircraft data.
//
// Orchestration-only: composes independent QML modules.
// All simulation logic lives in C++ SimulatorModel (context property: aeroSimulatorModel).
ApplicationWindow {
    id: root
    visible: true
    width: 1440; height: 900
    minimumWidth: 1200; minimumHeight: 760
    title: "NEXVARY AeroRadar — Civil Aviation Research Lab"
    color: AeroTheme.bgDeep

    // UTC wall clock — updated every second by a QML timer
    property string utcWallClock: new Date().toISOString().slice(0, 19).replace("T", " ") + " UTC"
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.utcWallClock =
            new Date().toISOString().slice(0, 19).replace("T", " ") + " UTC"
    }

    // ── Application header ───────────────────────────────────────────────
    header: StatusStrip {
        simulator:    aeroSimulatorModel
        utcWallClock: root.utcWallClock
    }

    // ── Main layout ──────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 2
        spacing: 0

        // Left navigation rail
        Rectangle {
            Layout.preferredWidth: 160; Layout.fillHeight: true
            color: "#07101e"
            border.color: AeroTheme.borderDim; border.width: 1

            ColumnLayout {
                anchors.fill: parent; anchors.topMargin: 10; spacing: 2

                Rectangle { Layout.fillWidth: true; height: 1; color: AeroTheme.borderDim }

                Repeater {
                    model: [
                        {label:"OVERVIEW",    active:false, planned:true},
                        {label:"FLIGHT SIM",  active:true,  planned:false},
                        {label:"RADAR PPI",   active:false, planned:true},
                        {label:"AIR TRAFFIC", active:false, planned:true},
                        {label:"SENSORS",     active:false, planned:true},
                        {label:"REPLAY",      active:false, planned:true},
                        {label:"RESEARCH",    active:false, planned:true},
                        {label:"SYSTEM",      active:false, planned:true}
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 46
                        color:        modelData.active ? "#0a2038" : "transparent"
                        border.color: modelData.active ? AeroTheme.accentBlue : "transparent"
                        border.width: modelData.active ? 1 : 0
                        radius: 2

                        Text {
                            text: modelData.planned && !modelData.active
                                  ? modelData.label + " (P2)" : modelData.label
                            font.pixelSize: 11; font.bold: modelData.active
                            color: modelData.active ? AeroTheme.textPrime : AeroTheme.textDim
                            anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        }
                        // Active-page indicator bar
                        Rectangle {
                            visible: modelData.active
                            width: 3; height: parent.height - 8; radius: 1
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            color: AeroTheme.accentBlue
                        }
                    }
                }

                Item { Layout.fillHeight: true }
                Text {
                    text: "NEXVARY Inc."
                    font.pixelSize: 9; color: AeroTheme.textDim
                    Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 8
                }
            }
        }

        // Central workspace
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 2

            RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 2

                // Radar PPI component
                RadarPpi {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    simulator: aeroSimulatorModel
                    rangeKm: 40.0
                }

                // 3-D scene — Planned P2
                Rectangle {
                    Layout.preferredWidth: 300; Layout.fillHeight: true
                    color: AeroTheme.bgPanel
                    border.color: AeroTheme.borderDim; border.width: 1; radius: 4

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 8

                        RowLayout {
                            spacing: 8
                            Rectangle { width: 8; height: 8; radius: 4; color: AeroTheme.textDim }
                            Text { text: "3-D SCENE (P2)"; font.pixelSize: 11; font.bold: true; color: AeroTheme.textDim }
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            color: "#050e1a"; radius: 2
                            Text {
                                anchors.centerIn: parent
                                text: "Qt Quick 3D\nScene\nPlanned P2"
                                font.pixelSize: 10; color: AeroTheme.textLabel
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Selected track detail panel
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 4
                            visible: aeroSimulatorModel && aeroSimulatorModel.selected &&
                                     aeroSimulatorModel.selected.id !== undefined

                            Text { text: "SELECTED TRACK"; font.pixelSize: 9; color: AeroTheme.textLabel }
                            Rectangle { Layout.fillWidth: true; height: 1; color: AeroTheme.borderDim }

                            Repeater {
                                model: (aeroSimulatorModel && aeroSimulatorModel.selected &&
                                        aeroSimulatorModel.selected.id !== undefined) ? [
                                    {k:"ID",   v: String(aeroSimulatorModel.selected.label)},
                                    {k:"TYPE", v: String(aeroSimulatorModel.selected.type)},
                                    {k:"ALT",  v: aeroSimulatorModel.selected.altitude_m.toFixed(0) + " m"},
                                    {k:"SPD",  v: aeroSimulatorModel.selected.speed_kt.toFixed(0)   + " kt"},
                                    {k:"HDG",  v: aeroSimulatorModel.selected.heading_deg.toFixed(0) + "°"},
                                    {k:"RNG",  v: aeroSimulatorModel.selected.range_km.toFixed(1)   + " km"}
                                ] : []
                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: modelData.k; font.pixelSize: 9; color: AeroTheme.textDim; Layout.preferredWidth: 40 }
                                    Text { text: modelData.v; font.pixelSize: 9; color: AeroTheme.accentBlue }
                                }
                            }
                        }
                    }
                }
            }

            // Flight instruments strip
            FlightInstruments {
                Layout.fillWidth: true
                simulator: aeroSimulatorModel
            }

            // Scenario timeline bar
            Rectangle {
                Layout.fillWidth: true; height: 36
                color: AeroTheme.bgPanel
                border.color: AeroTheme.borderDim; border.width: 1; radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 12

                    Text {
                        text: "SCENARIO TIMELINE"
                        font.pixelSize: 9; font.bold: true
                        color: AeroTheme.textLabel; font.family: AeroTheme.monoFont
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 6; radius: 3; color: "#0d1e30"
                        Rectangle {
                            width: parent.width * Math.min(
                                       1.0, aeroSimulatorModel ? aeroSimulatorModel.simTimeSeconds / 600.0 : 0)
                            height: parent.height; radius: parent.radius
                            color: AeroTheme.accentBlue
                        }
                    }
                    Text {
                        text: aeroSimulatorModel ? aeroSimulatorModel.simTimeDisplay : "00:00:00"
                        font.pixelSize: 10; color: AeroTheme.accentBlue
                        font.family: AeroTheme.monoFont
                    }
                    Text {
                        text: "10:00"
                        font.pixelSize: 10; color: AeroTheme.textDim
                        font.family: AeroTheme.monoFont
                    }
                }
            }
        }

        // Right simulation controls
        SimulationControls {
            Layout.preferredWidth: 210; Layout.fillHeight: true
            simulator: aeroSimulatorModel
        }
    }
}
