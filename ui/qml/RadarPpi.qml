import QtQuick
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
    property var  simulator: null
    property real rangeKm:   40.0

    // ── Panel header ─────────────────────────────────────────────────────
    RowLayout {
        id: ppiHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        anchors { topMargin: 8; leftMargin: 12; rightMargin: 12 }
        height: 28
        spacing: 8

        Rectangle { width: 10; height: 10; radius: 5; color: AeroTheme.accentBlue }
        Text {
            text: "RADAR PPI — Simulated Tracks"
            font.pixelSize: 12; font.bold: true; color: AeroTheme.textPrime
        }
        Item { Layout.fillWidth: true }
        Text {
            text: "R: " + ppi.rangeKm.toFixed(0) + " km"
            font.pixelSize: 10; color: AeroTheme.accentBlue
        }
    }

    // ── Radar canvas ─────────────────────────────────────────────────────
    Canvas {
        id: radarCanvas
        anchors {
            top: ppiHeader.bottom; bottom: ppiLegend.top
            left: parent.left; right: parent.right
            margins: 6
        }

        property real sweepAngle: 0

        NumberAnimation on sweepAngle {
            from: 0; to: 360; duration: 4000
            loops: Animation.Infinite
            running: ppi.simulator ? !ppi.simulator.paused : false
        }
        onSweepAngleChanged: requestPaint()

        Connections {
            target: ppi.simulator
            function onSimStateChanged() { radarCanvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d");
            var W = width, H = height;
            if (W < 10 || H < 10) return;
            var cx = W * 0.5, cy = H * 0.5;
            var R  = Math.min(W, H) * 0.44;
            ctx.clearRect(0, 0, W, H);
            ctx.fillStyle = "#030810";
            ctx.fillRect(0, 0, W, H);

            // Range rings + labels
            var i, rr, rad, b;
            for (i = 1; i <= 4; i++) {
                rr = R * i / 4;
                ctx.beginPath();
                ctx.arc(cx, cy, rr, 0, 2 * Math.PI);
                ctx.strokeStyle = (i === 4) ? "#143a60" : "#0e2840";
                ctx.lineWidth   = (i === 4) ? 1.5 : 0.8;
                ctx.stroke();
                ctx.fillStyle = "#2a5a70";
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
                ctx.strokeStyle = (b % 90 === 0) ? "#1a4060" : "#0d2838";
                ctx.lineWidth   = (b % 90 === 0) ? 1 : 0.5;
                ctx.stroke();
                ctx.fillStyle = "#2a5070";
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
            ctx.fillStyle = "rgba(0,207,255,0.04)";
            ctx.fill();
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.lineTo(cx + Math.cos(sr) * R, cy + Math.sin(sr) * R);
            ctx.strokeStyle = "rgba(0,207,255,0.65)";
            ctx.lineWidth   = 2;
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(cx, cy, 4, 0, 2 * Math.PI);
            ctx.fillStyle = "#00CFFF";
            ctx.fill();

            // Track icons
            if (!ppi.simulator) return;
            var tracks = ppi.simulator.tracks;
            if (!tracks || tracks.length === 0) return;
            var t, px, py, bc, trail, j, a, tpx, tpy, lx, ly, ti;
            for (ti = 0; ti < tracks.length; ti++) {
                t  = tracks[ti];
                bc = (t.type === "UAS") ? "#39FF14" : "#00CFFF";
                px = cx + (t.x_km / ppi.rangeKm) * R;
                py = cy - (t.y_km / ppi.rangeKm) * R;

                // Trail dots
                trail = t.trail;
                if (trail && trail.length > 1) {
                    for (j = 1; j < trail.length; j++) {
                        a   = j / trail.length;
                        tpx = cx + (trail[j].x_km / ppi.rangeKm) * R;
                        tpy = cy - (trail[j].y_km / ppi.rangeKm) * R;
                        ctx.beginPath();
                        ctx.arc(tpx, tpy, 2, 0, 2 * Math.PI);
                        ctx.fillStyle = "rgba(0,220,160," + (a * 0.55) + ")";
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
                ctx.strokeStyle = "rgba(0,207,255,0.5)";
                ctx.lineWidth   = 1;
                ctx.setLineDash([3, 3]);
                ctx.stroke();
                ctx.setLineDash([]);

                // Selection data box
                if (t.selected) {
                    ctx.fillStyle   = "rgba(8,24,40,0.88)";
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
                ctx.fillStyle = "#80b0c8";
                ctx.font      = "9px monospace";
                ctx.fillText(t.range_km.toFixed(1)   + " km",          lx, ly + 13);
                ctx.fillText(t.altitude_m.toFixed(0)  + " m",          lx, ly + 24);
                ctx.fillText(t.speed_kt.toFixed(0)    + " kt  " +
                             t.heading_deg.toFixed(0) + "°",      lx, ly + 35);
            }
        }

        // Click-to-select track
        MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) {
                if (!ppi.simulator) return;
                var W  = radarCanvas.width, H = radarCanvas.height;
                var cx = W * 0.5, cy = H * 0.5;
                var R  = Math.min(W, H) * 0.44;
                var tracks = ppi.simulator.tracks;
                if (!tracks) return;
                var best = -1, bestD = 18;
                for (var ti = 0; ti < tracks.length; ti++) {
                    var t  = tracks[ti];
                    var px = cx + (t.x_km / ppi.rangeKm) * R;
                    var py = cy - (t.y_km / ppi.rangeKm) * R;
                    var d  = Math.sqrt((mouse.x - px) * (mouse.x - px) +
                                       (mouse.y - py) * (mouse.y - py));
                    if (d < bestD) { bestD = d; best = t.id; }
                }
                if (best >= 0) ppi.simulator.selectTrack(best);
            }
        }
    }

    // ── Legend ────────────────────────────────────────────────────────────
    RowLayout {
        id: ppiLegend
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        anchors { bottomMargin: 6; leftMargin: 12 }
        height: 20
        spacing: 16

        Text { text: "UAS (Multirotor)";      color: "#39FF14"; font.pixelSize: 9 }
        Text { text: "Aircraft (Fixed-Wing)"; color: "#00CFFF"; font.pixelSize: 9 }
        Text { text: "Track History";         color: "#00dc80"; font.pixelSize: 9 }
        Item { Layout.fillWidth: true }
        Text { text: "DATA: SYNTHETIC"; color: AeroTheme.accentAmber; font.pixelSize: 9 }
    }
}
