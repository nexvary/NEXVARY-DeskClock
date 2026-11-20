import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
ApplicationWindow {
    visible: true
    width: 1280
    height: 800
    title: "NEXVARY AeroRadar — Simulation Lab"
    color: "#080b11"
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18
        Label {
            text: "NEXVARY AeroRadar"
            color: "#dbe8f3"
            font.pixelSize: 30
            font.bold: true
        }
        Label {
            text: "SIMULATION ONLY — No live aircraft data connected"
            color: "#f9b85b"
            font.pixelSize: 15
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#101a22"
            radius: 18
            border.color: "#385567"
            Canvas {
                id: radar
                anchors.fill: parent
                anchors.margins: 30
                onPaint: {
                    const ctx = getContext("2d")
                    const w = width, h = height, cx = w / 2, cy = h / 2
                    ctx.clearRect(0, 0, w, h)
                    const r = Math.min(w, h) * 0.43
                    ctx.strokeStyle = "#367564"
                    ctx.lineWidth = 1
                    for (let i = 1; i <= 4; ++i) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, r * i / 4, 0, 2 * Math.PI)
                        ctx.stroke()
                    }
                    ctx.beginPath()
                    ctx.moveTo(cx - r, cy)
                    ctx.lineTo(cx + r, cy)
                    ctx.moveTo(cx, cy - r)
                    ctx.lineTo(cx, cy + r)
                    ctx.stroke()
                    ctx.fillStyle = "#74edb4"
                    const points = [[0.3, -0.5], [-0.65, 0.22], [0.6, 0.35]]
                    for (const p of points) {
                        ctx.beginPath()
                        ctx.arc(cx + p[0] * r, cy + p[1] * r, 5, 0, 2 * Math.PI)
                        ctx.fill()
                    }
                }
            }
        }
        Label {
            text: "Illustrative PPI preview • Static synthetic targets"
            color: "#92a6b6"
        }
    }
}
