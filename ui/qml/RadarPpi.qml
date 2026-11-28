import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AeroRadar

// Self-contained Plan-Position Indicator panel.
// Renders range rings, bearing spokes, sweep beam and synthetic track icons.
// Exposes simulator and rangeKm as explicit properties for testability.
Rectangle {
    id: ppi
    color: AeroTheme.bgPanel
    border.color: AeroTheme.borderDim
    border.width: 1
    radius: 4

    // ── Public interface ─────────────────────────────────────────────────
    objectName: "radar-ppi"
    property var simulator: null
    readonly property var tracks: simulator ? simulator.tracks : []
    readonly property var rangesKm: [10, 20, 40, 80, 160, 320, 640, 1280]
    property int rangeIndex: 2
    readonly property real rangeKm: rangesKm[rangeIndex]
    property real centerEastKm: 0
    property real centerNorthKm: 0
    property bool showLabels: true
    property bool showHistory: true
    property string trackTypeFilter: ""

    function zoomBy(delta) {
        rangeIndex = Math.max(0, Math.min(rangesKm.length - 1, rangeIndex + delta))
    }

    function resetView() {
        rangeIndex = 2
        centerEastKm = 0
        centerNorthKm = 0
    }

    function includesTrack(track) {
        return trackTypeFilter === "" || track.type === trackTypeFilter
    }

    onRangeKmChanged: radarCanvas.requestPaint()
    onCenterEastKmChanged: radarCanvas.requestPaint()
    onCenterNorthKmChanged: radarCanvas.requestPaint()
    onShowLabelsChanged: radarCanvas.requestPaint()
    onShowHistoryChanged: radarCanvas.requestPaint()
    onTrackTypeFilterChanged: radarCanvas.requestPaint()
    onTracksChanged: if (visible) radarCanvas.requestPaint()

    // ── Panel header ─────────────────────────────────────────────────────
    RowLayout {
        id: ppiHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        anchors { topMargin: 8; leftMargin: 12; rightMargin: 12 }
        height: 36
        spacing: 8

        Rectangle { width: 10; height: 10; radius: 5; color: AeroTheme.accentBlue }
        Text {
            text: "RADAR PPI — Simulated Tracks"
            font.pixelSize: 12; font.bold: true; color: AeroTheme.textPrime
        }
        Item { Layout.fillWidth: true }
        Text {
            text: qsTr("Range %1 km").arg(ppi.rangeKm)
            font.pixelSize: 12
            color: AeroTheme.accentBlue
        }
        Button {
            objectName: "radar-zoom-in"
            text: "+"
            Accessible.name: qsTr("Zoom in")
            enabled: ppi.rangeIndex > 0
            onClicked: ppi.zoomBy(-1)
        }
        Button {
            objectName: "radar-zoom-out"
            text: "−"
            Accessible.name: qsTr("Zoom out")
            enabled: ppi.rangeIndex < ppi.rangesKm.length - 1
            onClicked: ppi.zoomBy(1)
        }
        Button {
            objectName: "radar-reset-view"
            text: qsTr("Center")
            Accessible.description: qsTr("Restore the original center and range")
            onClicked: ppi.resetView()
        }
    }

    // ── Radar canvas ─────────────────────────────────────────────────────
    Canvas {
        id: radarCanvas
        objectName: "radar-canvas"
        readonly property real scopeRadius: Math.min(width, height) * 0.44
        readonly property real pixelsPerKm: scopeRadius / ppi.rangeKm
        readonly property real originX: width * 0.5 - ppi.centerEastKm * pixelsPerKm
        readonly property real originY: height * 0.5 + ppi.centerNorthKm * pixelsPerKm

        function project(eastKm, northKm) {
            return Qt.point(originX + eastKm * pixelsPerKm, originY - northKm * pixelsPerKm)
        }
        anchors {
            top: ppiHeader.bottom; bottom: ppiLegend.top
            left: parent.left; right: parent.right
            margins: 6
        }

        property real sweepAngle: 0

        NumberAnimation on sweepAngle {
            from: 0; to: 360; duration: 4000
            loops: Animation.Infinite
            running: ppi.visible && ppi.simulator && !ppi.simulator.paused
        }
        onSweepAngleChanged: requestPaint()
        onVisibleChanged: if (visible) requestPaint()

        Connections {
            target: AeroTheme
            function onLightModeChanged() {
                if (radarCanvas.visible)
                    radarCanvas.requestPaint()
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            var W = width, H = height;
            if (W < 10 || H < 10) return;
            var cx = originX, cy = originY;
            var R = scopeRadius;
            ctx.clearRect(0, 0, W, H);
            ctx.fillStyle = AeroTheme.scopeBackground;
            ctx.fillRect(0, 0, W, H);

            // Range rings + labels
            var i, rr, rad, b;
            for (i = 1; i <= 4; i++) {
                rr = R * i / 4;
                ctx.beginPath();
                ctx.arc(cx, cy, rr, 0, 2 * Math.PI);
                ctx.strokeStyle = (i === 4) ? AeroTheme.scopeStrongLine : AeroTheme.scopeLine;
                ctx.lineWidth   = (i === 4) ? 1.5 : 0.8;
                ctx.stroke();
                ctx.fillStyle = AeroTheme.scopeLabel;
                ctx.font      = "9px monospace";
                ctx.textAlign = "left";
                ctx.fillText((ppi.rangeKm * i / 4).toFixed(0) + " km",
                             cx + 4, cy - rr + 10);
            }

            // Bearing spokes
            var brgs = [0,30,60,90,120,150,180,210,240,270,300,330];
            for (i = 0; i < brgs.length; i++) {
                b   = brgs[i];
                rad = (b - 90) * Math.PI / 180;
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.lineTo(cx + Math.cos(rad) * R, cy + Math.sin(rad) * R);
                ctx.strokeStyle = (b % 90 === 0) ? AeroTheme.scopeStrongLine : AeroTheme.scopeLine;
                ctx.lineWidth   = (b % 90 === 0) ? 1 : 0.5;
                ctx.stroke();
                ctx.fillStyle = AeroTheme.scopeLabel;
                ctx.font      = "9px monospace";
                ctx.textAlign = "center";
                ctx.fillText(b + "°",
                             cx + Math.cos(rad) * (R + 14),
                             cy + Math.sin(rad) * (R + 14) + 3);
            }
            ctx.textAlign = "left";

            // Sweep beam (sector fill + leading edge)
            var sr = (sweepAngle - 90) * Math.PI / 180;
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, R * 0.98, sr - 1.05, sr, false);
            ctx.closePath();
            ctx.fillStyle = Qt.alpha(AeroTheme.accentBlue, 0.06);
            ctx.fill();
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.lineTo(cx + Math.cos(sr) * R, cy + Math.sin(sr) * R);
            ctx.strokeStyle = Qt.alpha(AeroTheme.accentBlue, 0.65);
            ctx.lineWidth   = 2;
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(cx, cy, 4, 0, 2 * Math.PI);
            ctx.fillStyle = AeroTheme.accentBlue;
            ctx.fill();

            // Track icons
            if (!ppi.simulator) return;
            var tracks = ppi.tracks;
            if (!tracks || tracks.length === 0) return;
            var t, px, py, bc, trail, j, a, lx, ly, ti;
            for (ti = 0; ti < tracks.length; ti++) {
                t  = tracks[ti];
                if (!ppi.includesTrack(t)) continue;
                bc = (t.type === "UAS") ? AeroTheme.accentGreen : AeroTheme.accentBlue;
                const position = project(t.x_km, t.y_km);
                px = position.x;
                py = position.y;

                // Trail dots
                trail = t.trail;
                if (ppi.showHistory && trail && trail.length > 1) {
                    for (j = 1; j < trail.length; j++) {
                        a   = j / trail.length;
                        const trailPoint = project(trail[j].x_km, trail[j].y_km);
                        ctx.beginPath();
                        ctx.arc(trailPoint.x, trailPoint.y, 2, 0, 2 * Math.PI);
                        ctx.fillStyle = Qt.alpha(AeroTheme.trailColor, a * 0.65);
                        ctx.fill();
                    }
                }

                // Icon (UAS = cross-in-square; fixed-wing = aircraft silhouette)
                ctx.save();
                ctx.translate(px, py);
                ctx.rotate(t.heading_deg * Math.PI / 180);
                ctx.strokeStyle = bc;
                ctx.lineWidth   = t.selected ? 2.5 : 1.5;
                if (t.type === "UAS") {
                    ctx.strokeRect(-6, -6, 12, 12);
                    ctx.beginPath();
                    ctx.moveTo(-5, -5); ctx.lineTo( 5,  5);
                    ctx.moveTo( 5, -5); ctx.lineTo(-5,  5);
                    ctx.stroke();
                } else {
                    ctx.beginPath();
                    ctx.moveTo( 0, -9); ctx.lineTo(0,  9);
                    ctx.moveTo(-8,  2); ctx.lineTo(8,  2);
                    ctx.moveTo(-3,  7); ctx.lineTo(3,  7);
                    ctx.stroke();
                }
                ctx.restore();

                // Velocity vector
                ctx.beginPath();
                ctx.moveTo(px, py);
                ctx.lineTo(px + Math.cos((t.heading_deg - 90) * Math.PI / 180) * 20,
                           py + Math.sin((t.heading_deg - 90) * Math.PI / 180) * 20);
                ctx.strokeStyle = Qt.alpha(AeroTheme.accentBlue, 0.55);
                ctx.lineWidth   = 1;
                ctx.setLineDash([3, 3]);
                ctx.stroke();
                ctx.setLineDash([]);

                if (!ppi.showLabels) continue;

                // Selection data box
                if (t.selected) {
                    ctx.fillStyle   = Qt.alpha(AeroTheme.bgCard, 0.92);
                    ctx.fillRect(px + 10, py - 50, 130, 54);
                    ctx.strokeStyle = bc;
                    ctx.lineWidth   = 0.8;
                    ctx.strokeRect(px + 10, py - 50, 130, 54);
                }
                lx = px + (t.selected ? 14 : 10);
                ly = py + (t.selected ? -46 : -10);
                ctx.fillStyle = bc;
                ctx.font      = "bold 11px monospace";
                ctx.fillText(t.label, lx, ly);
                ctx.fillStyle = AeroTheme.scopeLabel;
                ctx.font      = "9px monospace";
                ctx.fillText(t.range_km.toFixed(1)   + " km",          lx, ly + 13);
                ctx.fillText(t.altitude_m.toFixed(0)  + " m",          lx, ly + 24);
                ctx.fillText(t.speed_kt.toFixed(0)    + " kt  " +
                             t.heading_deg.toFixed(0) + "°",      lx, ly + 35);
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: dragDetected ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            property bool dragDetected: false
            property real startX
            property real startY
            property real startEast
            property real startNorth

            onPressed: function(mouse) {
                dragDetected = false
                startX = mouse.x
                startY = mouse.y
                startEast = ppi.centerEastKm
                startNorth = ppi.centerNorthKm
            }

            onPositionChanged: function(mouse) {
                if (!pressed || radarCanvas.pixelsPerKm <= 0)
                    return
                const offsetX = mouse.x - startX
                const offsetY = mouse.y - startY
                if (!dragDetected && Math.hypot(offsetX, offsetY) < 6)
                    return
                dragDetected = true
                const scale = radarCanvas.pixelsPerKm
                ppi.centerEastKm = Math.max(-1280, Math.min(1280, startEast - offsetX / scale))
                ppi.centerNorthKm = Math.max(-1280, Math.min(1280, startNorth + offsetY / scale))
            }

            onReleased: function(mouse) {
                const moved = dragDetected
                dragDetected = false
                if (moved || !containsMouse || !ppi.simulator)
                    return
                const tracks = ppi.tracks
                let nearestId = null
                let nearestPx = 18
                for (const track of tracks) {
                    if (!ppi.includesTrack(track))
                        continue
                    const point = radarCanvas.project(track.x_km, track.y_km)
                    const distance = Math.hypot(mouse.x - point.x, mouse.y - point.y)
                    if (distance < nearestPx) {
                        nearestPx = distance
                        nearestId = track.id
                    }
                }
                if (nearestId !== null)
                    ppi.simulator.selectTrack(nearestId)
            }

            onCanceled: dragDetected = false

            onWheel: function(wheel) {
                if (wheel.angleDelta.y !== 0)
                    ppi.zoomBy(wheel.angleDelta.y > 0 ? -1 : 1)
            }
        }
    }

    // ── Legend ────────────────────────────────────────────────────────────
    RowLayout {
        id: ppiLegend
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        anchors { bottomMargin: 6; leftMargin: 12 }
        height: 32
        spacing: 10

        CheckBox {
            objectName: "radar-labels"
            text: qsTr("Labels")
            checked: ppi.showLabels
            onToggled: ppi.showLabels = checked
        }
        CheckBox {
            objectName: "radar-history"
            text: qsTr("History")
            checked: ppi.showHistory
            onToggled: ppi.showHistory = checked
        }
        ComboBox {
            objectName: "radar-track-filter"
            model: [
                {label: qsTr("All tracks"), type: ""},
                {label: qsTr("Fixed-wing"), type: "FIXED_WING"},
                {label: qsTr("Multirotor"), type: "UAS"}
            ]
            textRole: "label"
            valueRole: "type"
            currentIndex: model.findIndex(entry => entry.type === ppi.trackTypeFilter)
            Accessible.name: qsTr("Radar track type filter")
            onActivated: function(index) { ppi.trackTypeFilter = model[index].type }
        }

        Text { text: "UAS (Multirotor)";      color: AeroTheme.accentGreen; font.pixelSize: 9 }
        Text { text: "Aircraft (Fixed-Wing)"; color: AeroTheme.accentBlue; font.pixelSize: 9 }
        Item { Layout.fillWidth: true }
        Text { text: "DATA: SYNTHETIC"; color: AeroTheme.accentAmber; font.pixelSize: 9 }
    }
}
