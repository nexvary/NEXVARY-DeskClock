import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtQuick.Layouts
import AeroRadar

ColumnLayout {
    id: page
    required property var simulator
    readonly property var replay: simulator.replay
    spacing: 6

    onVisibleChanged: if (!visible) replay.pause()

    FileDialog {
        id: openDialog
        title: qsTr("Open a synthetic recording")
        nameFilters: [qsTr("AeroRadar recordings (*.aerorec)")]
        onAccepted: page.replay.openRecording(selectedFile)
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save synthetic recording")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "aerorec"
        nameFilters: [qsTr("AeroRadar recordings (*.aerorec)")]
        onAccepted: page.replay.saveRecording(selectedFile)
    }

    RowLayout {
        Button {
            objectName: "replay-capture"
            text: page.replay.recording ? qsTr("Stop recording") : qsTr("Start recording")
            onClicked: {
                if (page.replay.recording)
                    page.replay.stopCapture()
                else if (page.replay.available)
                    replaceDialog.open()
                else
                    page.simulator.startRecording()
            }
        }
        Button {
            text: qsTr("Open recording…")
            enabled: !page.replay.recording
            onClicked: {
                if (page.replay.available)
                    openConfirmDialog.open()
                else
                    openDialog.open()
            }
        }
        Button {
            text: qsTr("Save recording…")
            enabled: page.replay.available
            onClicked: saveDialog.open()
        }
    }

    Dialog {
        id: replaceDialog
        title: qsTr("Replace the recording in memory?")
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: page.simulator.startRecording()
    }

    Dialog {
        id: openConfirmDialog
        title: qsTr("Replace the recording in memory?")
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: openDialog.open()
    }

    Label {
        Layout.fillWidth: true
        text: page.replay.error
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        visible: text.length > 0
        color: AeroTheme.accentAmber
        Accessible.role: Accessible.AlertMessage
    }

    Label {
        Layout.fillWidth: true
        visible: !page.replay.available
        wrapMode: Text.WordWrap
        text: page.replay.recording
            ? qsTr("Recording synthetic simulation · %1 frames. Use the simulation controls to run or step.").arg(page.replay.lastFrame + 1)
            : qsTr("Start recording the current synthetic simulation or open an AeroRadar recording.")
        color: AeroTheme.textPrime
    }

    RadarPpi {
        visible: page.replay.available
        Layout.fillWidth: true
        Layout.fillHeight: true
        simulator: page.replay
        sourceLabel: qsTr("DATA: RECORDED SYNTHETIC")
    }
    Item { visible: !page.replay.available; Layout.fillHeight: true }

    RowLayout {
        visible: page.replay.available
        Layout.fillWidth: true
        Button {
            text: page.replay.paused ? qsTr("Play") : qsTr("Pause")
            enabled: !page.replay.ended
            onClicked: page.replay.paused ? page.replay.play() : page.replay.pause()
        }
        Button {
            objectName: "replay-step"
            text: qsTr("Step")
            enabled: page.replay.paused && !page.replay.ended
            onClicked: page.replay.step()
        }
        Button { text: qsTr("Reset"); onClicked: page.replay.reset() }
        ComboBox {
            readonly property var rates: [0.25, 0.5, 1, 2, 4]
            model: rates.map(value => qsTr("%1×").arg(value))
            currentIndex: rates.indexOf(page.replay.rate)
            Accessible.name: qsTr("Replay speed")
            onActivated: page.replay.setRate(rates[currentIndex])
        }
        Slider {
            Layout.fillWidth: true
            from: 0
            to: page.replay.lastFrame
            stepSize: 1
            value: page.replay.frame
            Accessible.name: qsTr("Replay frame")
            onMoved: {
                page.replay.pause()
                page.replay.seek(Math.round(value))
            }
        }
        Label {
            color: AeroTheme.textPrime
            text: page.replay.ended
                ? qsTr("End · %1 s").arg(page.replay.elapsedSeconds.toFixed(1))
                : qsTr("%1 s").arg(page.replay.elapsedSeconds.toFixed(1))
        }
    }

    RowLayout {
        visible: page.replay.available
        Layout.fillWidth: true
        TextField {
            id: bookmarkLabel
            maximumLength: 80
            placeholderText: qsTr("Bookmark label")
            Accessible.name: placeholderText
        }
        Button {
            text: qsTr("Add bookmark")
            enabled: bookmarkLabel.text.trim().length > 0 && page.replay.bookmarks.length < 256
            onClicked: if (page.replay.addBookmark(bookmarkLabel.text)) bookmarkLabel.clear()
        }
        ComboBox {
            Layout.fillWidth: true
            model: page.replay.bookmarks
            textRole: "label"
            displayText: page.replay.bookmarks.length ? currentText : qsTr("No bookmarks")
            enabled: page.replay.bookmarks.length > 0
            Accessible.name: qsTr("Jump to bookmark")
            onActivated: {
                page.replay.pause()
                page.replay.seek(page.replay.bookmarks[index].frame)
            }
        }
    }
    TextField {
        visible: page.replay.available
        Layout.fillWidth: true
        maximumLength: 4096
        placeholderText: qsTr("Research notes")
        Accessible.name: placeholderText
        text: page.replay.notes
        onTextEdited: page.replay.setNotes(text)
    }
}
