import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

ColumnLayout {
    id: trackList
    required property var simulator
    readonly property var tracks: simulator ? simulator.tracks : []
    spacing: 4

    Repeater {
        // Keep delegates and keyboard focus stable while track values refresh.
        model: trackList.tracks.length
        delegate: Button {
            id: trackButton
            required property int index
            readonly property var track: trackList.tracks[index]
            objectName: "track-" + track.id
            Layout.fillWidth: true
            implicitHeight: 40
            text: track.label
            checkable: false
            Accessible.description: qsTr("%1, %2 knots, altitude %3 meters")
                .arg(track.type).arg(track.speed_kt.toFixed(0)).arg(track.altitude_m.toFixed(0))
            onClicked: trackList.simulator.selectTrack(track.id)

            background: Rectangle {
                radius: 3
                color: trackButton.track.selected || trackButton.hovered ? AeroTheme.bgRaised : AeroTheme.bgCard
                border.color: trackButton.activeFocus ? AeroTheme.textPrime
                    : trackButton.track.selected ? AeroTheme.accentBlue : AeroTheme.borderDim
                border.width: trackButton.activeFocus ? 2 : 1
            }

            contentItem: RowLayout {
                spacing: 8

                Rectangle {
                    width: 7
                    height: 7
                    radius: 1
                    color: trackButton.track.type === "UAS" ? AeroTheme.accentGreen : AeroTheme.accentBlue
                }

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: trackButton.text
                        color: AeroTheme.textPrime
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: qsTr("%1  %2 kt  %3 m").arg(trackButton.track.type)
                            .arg(trackButton.track.speed_kt.toFixed(0))
                            .arg(trackButton.track.altitude_m.toFixed(0))
                        color: AeroTheme.textDim
                        font.pixelSize: 10
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    Text {
        visible: trackList.tracks.length === 0
        text: qsTr("No tracks available.")
        color: AeroTheme.textPrime
    }
}
