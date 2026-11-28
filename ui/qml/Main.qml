import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

ApplicationWindow {
    id: root
    visible: true
    width: 1440
    height: 900
    minimumWidth: 1200
    minimumHeight: 760
    objectName: "aeroradar-window"
    title: qsTr("NEXVARY AeroRadar — Civil Aviation Research Lab")
    color: AeroTheme.bgDeep
    palette.window: AeroTheme.bgPanel
    palette.base: AeroTheme.bgCard
    palette.button: AeroTheme.bgRaised
    palette.buttonText: AeroTheme.textPrime
    palette.text: AeroTheme.textPrime
    palette.highlight: AeroTheme.accentBlue
    palette.highlightedText: AeroTheme.bgPanel

    readonly property var simulator: aeroSimulatorModel
    property string workspace: "flight"
    property string utcWallClock: utcDisplay()

    function utcDisplay() {
        return new Date().toISOString().slice(0, 19).replace("T", " ") + " UTC"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.utcWallClock = root.utcDisplay()
    }

    header: StatusStrip {
        simulator: root.simulator
        utcWallClock: root.utcWallClock
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Rectangle {
            Layout.preferredWidth: 164
            Layout.fillHeight: true
            color: AeroTheme.bgPanel
            border.color: AeroTheme.borderDim

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Repeater {
                    model: [
                        {key: "overview", label: qsTr("Overview")},
                        {key: "flight", label: qsTr("Flight simulation")},
                        {key: "radar", label: qsTr("Radar PPI")},
                        {key: "traffic", label: qsTr("Air traffic")},
                        {key: "diagnostics", label: qsTr("Diagnostics")},
                        {key: "settings", label: qsTr("Settings")},
                        {key: "help", label: qsTr("Help")}
                    ]
                    delegate: Button {
                        id: workspaceButton
                        required property var modelData
                        readonly property bool selected: root.workspace === modelData.key
                        objectName: "workspace-" + modelData.key
                        Layout.fillWidth: true
                        implicitHeight: 44
                        text: modelData.label
                        Accessible.description: selected ? qsTr("Current workspace") : ""
                        onClicked: root.workspace = modelData.key
                        background: Rectangle {
                            radius: 3
                            color: workspaceButton.selected || workspaceButton.hovered
                                ? AeroTheme.bgRaised : AeroTheme.bgPanel
                            border.width: workspaceButton.activeFocus ? 2 : 1
                            border.color: workspaceButton.activeFocus ? AeroTheme.textPrime
                                : workspaceButton.selected ? AeroTheme.accentBlue : "transparent"
                        }
                        contentItem: Text {
                            text: workspaceButton.text
                            color: AeroTheme.textPrime
                            font.pixelSize: 13
                            font.bold: workspaceButton.selected
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            RadarPpi {
                visible: root.workspace === "flight" || root.workspace === "radar"
                Layout.fillWidth: true
                Layout.fillHeight: true
                simulator: root.simulator
            }

            WorkspaceInfo {
                visible: root.workspace === "overview"
                Layout.fillWidth: true
                Layout.fillHeight: true
                heading: qsTr("Overview")
                details: [
                    qsTr("Built-in synthetic scenario with %1 tracks.").arg(root.simulator.trackCount),
                    root.simulator.paused ? qsTr("Simulation paused.") : qsTr("Simulation running."),
                    qsTr("The scenario uses a local planar coordinate frame and constant velocity.")
                ]
            }

            WorkspaceInfo {
                visible: root.workspace === "traffic"
                Layout.fillWidth: true
                Layout.fillHeight: true
                heading: qsTr("Air traffic")
                details: root.simulator.selected.id === undefined
                    ? [qsTr("Select a synthetic aircraft from the active track list.")]
                    : [
                        qsTr("Selected track: %1 (%2)").arg(root.simulator.selected.label)
                            .arg(root.simulator.selected.type),
                        qsTr("East %1 km, north %2 km")
                            .arg(root.simulator.selected.x_km.toFixed(2))
                            .arg(root.simulator.selected.y_km.toFixed(2))
                    ]
            }

            WorkspaceInfo {
                visible: root.workspace === "diagnostics"
                Layout.fillWidth: true
                Layout.fillHeight: true
                heading: qsTr("Diagnostics")
                details: [
                    qsTr("Application version %1").arg(Qt.application.version),
                    qsTr("Platform: %1").arg(Qt.platform.os),
                    qsTr("Source: built-in synthetic simulation"),
                    qsTr("Simulation elapsed: %1").arg(root.simulator.simTimeDisplay),
                    qsTr("Playback speed: %1×").arg(root.simulator.timeScale),
                    root.utcWallClock
                ]
            }

            WorkspaceInfo {
                visible: root.workspace === "help"
                Layout.fillWidth: true
                Layout.fillHeight: true
                heading: qsTr("Help")
                details: [
                    qsTr("Use Play, Pause and Reset to control the simulation. Step advances one tick while paused, and the speed selector controls playback pacing."),
                    qsTr("Select a track on the radar or in Active Tracks. Use Tab to move between buttons and Space to activate the focused button."),
                    qsTr("The radar shows local distances in kilometers. Altitude is measured in meters above the simulation reference plane, and heading is measured clockwise from north."),
                    qsTr("Synthetic data for research and education only. Do not use for navigation or air traffic control.")
                ]
            }

            AppearanceSettings {
                visible: root.workspace === "settings"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            FlightInstruments {
                visible: root.workspace === "flight" || root.workspace === "traffic"
                Layout.fillWidth: true
                simulator: root.simulator
            }
        }

        SimulationControls {
            Layout.preferredWidth: 216
            Layout.fillHeight: true
            simulator: root.simulator
        }
    }
}
