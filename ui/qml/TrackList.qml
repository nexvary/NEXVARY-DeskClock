import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

ListView {
    id: trackList
    required property var simulator
    readonly property var tracks: simulator ? simulator.tracks : []
    spacing: 4
    clip: true
    reuseItems: true
    ScrollBar.vertical: ScrollBar {}

    // Count-based delegates keep keyboard focus stable while track values refresh.
    model: tracks.length
    delegate: Button {
        id: trackButton
        required property int index
        readonly property var track: trackList.tracks[index]
        objectName: track ? "track-" + track.id : ""
        width: trackList.width - 12
        implicitHeight: 40
        text: track ? track.label : ""
        checkable: false
        enabled: !!track
        Accessible.description: track ? qsTr("%1, %2 knots, altitude %3 meters")
            .arg(track.type).arg(track.speed_kt.toFixed(0)).arg(track.altitude_m.toFixed(0)) : ""
        onClicked: trackList.simulator.selectTrack(track.id)

        background: Rectangle {
            radius: 3
            color: (trackButton.track?.selected || trackButton.hovered) ? AeroTheme.bgRaised : AeroTheme.bgCard
            border.color: trackButton.activeFocus ? AeroTheme.textPrime
                : trackButton.track?.selected ? AeroTheme.accentBlue : AeroTheme.borderDim
            border.width: trackButton.activeFocus ? 2 : 1
        }

        contentItem: RowLayout {
            spacing: 8

            Rectangle {
                width: 7
                height: 7
                radius: 1
                color: trackButton.track?.type === "UAS" ? AeroTheme.accentGreen : AeroTheme.accentBlue
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: trackButton.text
                    textFormat: Text.PlainText
                    color: AeroTheme.textPrime
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: trackButton.track ? qsTr("%1  %2 kt  %3 m").arg(trackButton.track.type)
                        .arg(trackButton.track.speed_kt.toFixed(0))
                        .arg(trackButton.track.altitude_m.toFixed(0)) : ""
                    textFormat: Text.PlainText
                    color: AeroTheme.textDim
                    font.pixelSize: 10
                }
            }

        }
    }

    Text {
        visible: trackList.tracks.length === 0
        text: qsTr("No tracks available.")
        color: AeroTheme.textPrime
    }
}
