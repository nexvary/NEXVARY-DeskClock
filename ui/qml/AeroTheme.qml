pragma Singleton
import QtQuick
import QtCore

QtObject {
    id: theme
    property Settings appearance: Settings {
        category: "Appearance"
        property bool lightMode: false
    }

    readonly property bool lightMode: appearance.lightMode

    function setLightMode(enabled: bool) {
        appearance.lightMode = enabled
    }

    readonly property color bgDeep: lightMode ? "#edf2f7" : "#080808"
    readonly property color bgPanel: lightMode ? "#ffffff" : "#0d1218"
    readonly property color bgCard: lightMode ? "#f4f8fc" : "#111820"
    readonly property color bgRaised: lightMode ? "#e3effa" : "#0a2038"
    readonly property color borderDim: lightMode ? "#afc1d3" : "#1e3450"

    readonly property color accentBlue: lightMode ? "#00547e" : "#00cfff"
    readonly property color accentGreen: lightMode ? "#1b651e" : "#39ff14"
    readonly property color accentAmber: lightMode ? "#7a4600" : "#f0b040"
    readonly property color runningBg: lightMode ? "#e8f6e9" : "#0a2a10"
    readonly property color warningBg: lightMode ? "#fff4de" : "#2a1800"

    readonly property color textPrime: lightMode ? "#13283c" : "#e0e7eb"
    readonly property color textDim: lightMode ? "#435b70" : "#8ca5ba"
    readonly property color textLabel: lightMode ? "#375a7b" : "#8eacce"

    readonly property color scopeBackground: lightMode ? "#f6faff" : "#030810"
    readonly property color scopeStrongLine: lightMode ? "#829db6" : "#286080"
    readonly property color scopeLine: lightMode ? "#c6d7e8" : "#153347"
    readonly property color scopeLabel: lightMode ? "#3a596f" : "#759bbb"
    readonly property color trailColor: lightMode ? "#087655" : "#00dc80"

    readonly property string monoFont: Qt.platform.os === "windows" ? "Consolas" : "Monospace"
}
