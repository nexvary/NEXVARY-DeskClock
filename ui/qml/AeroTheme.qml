pragma Singleton
import QtQuick

// NEXVARY AeroRadar — unified design token singleton.
// All QML components import AeroRadar and reference AeroTheme.<token>.
QtObject {
    // ── Background layers ────────────────────────────────────────────────
    readonly property color bgDeep:    "#080808"   // Deep Glossy Black (brand)
    readonly property color bgPanel:   "#0d1218"
    readonly property color bgCard:    "#111820"
    readonly property color borderDim: "#1e3450"

    // ── Nexvary brand accents ────────────────────────────────────────────
    readonly property color accentBlue:  "#00CFFF"  // Electric Blue
    readonly property color accentGreen: "#39FF14"  // Neon Green
    readonly property color accentRed:   "#FF3131"  // Neon Red
    readonly property color accentAmber: "#f0b040"  // Amber / warning

    // ── Text hierarchy ───────────────────────────────────────────────────
    readonly property color silver:    "#C0C0C0"   // Metallic Silver (brand)
    readonly property color textPrime: "#C0C0C0"
    readonly property color textDim:   "#5a7890"
    readonly property color textLabel: "#3a6080"

    // ── Typography ───────────────────────────────────────────────────────
    readonly property string monoFont: Qt.platform.os === "windows" ? "Consolas" : "Monospace"
    readonly property string uiFont:   Qt.platform.os === "windows" ? "Segoe UI" : "Sans"
}
