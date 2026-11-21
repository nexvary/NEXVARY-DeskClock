import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// NEXVARY AeroRadar -- Simulation Lab Dashboard
// DATA: SYNTHETIC / SIMULATED. No live aircraft data.
ApplicationWindow {
    id: root
    visible: true
    width: 1440
    height: 900
    minimumWidth: 1200
    minimumHeight: 760
    title: "NEXVARY AeroRadar -- Civil Aviation Research Lab"
    color: "#060c14"

    readonly property color bgDeep:    "#060c14"
    readonly property color bgPanel:   "#091624"
    readonly property color bgCard:    "#0d1e30"
    readonly property color borderDim: "#1a3048"
    readonly property color accentCyan:"#00d4f0"
    readonly property color accentGrn: "#00e888"
    readonly property color accentAmb: "#f0b040"
    readonly property color textPrime: "#c0d8e8"
    readonly property color textDim:   "#5a7890"
    readonly property color textLabel: "#3a6080"
    readonly property string monoFont: Qt.platform.os === "windows" ? "Consolas" : "Monospace"
    readonly property real radarKm: 40.0

    property string simClockText: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.simClockText = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    }
    header: Rectangle {
        color: "#080f1c"
        height: 90
        border.color: root.borderDim
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 12

                Text {
                    text: "NEXVARY AeroRadar"
                    font.pixelSize: 20
                    font.bold: true
                    color: root.textPrime
                }
                Text {
                    text: "CIVIL AVIATION RESEARCH  |  SIMULATION LAB"
                    font.pixelSize: 10
                    color: root.textDim
                    font.letterSpacing: 2
                }
                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 28
                    width: simbadge.implicitWidth + 24
                    radius: 4
                    color: "#2a1800"
                    border.color: root.accentAmb
                    border.width: 1
                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "WARNING"
                            font.pixelSize: 10
                            color: root.accentAmb
                            font.bold: true
                        }
                        Text {
                            id: simbadge
                            text: "SIMULATION ONLY  |  NO LIVE DATA"
                            font.pixelSize: 11
                            color: root.accentAmb
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    height: 28
                    width: runlbl.implicitWidth + 28
                    radius: 4
                    color: simulator && !simulator.paused ? "#0a2a10" : "#1a1a0a"
                    border.color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                    border.width: 1
                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                            SequentialAnimation on opacity {
                                running: simulator && !simulator.paused
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.2; duration: 600 }
                                NumberAnimation { to: 1.0; duration: 400 }
                            }
                        }
                        Text {
                            id: runlbl
                            text: simulator && !simulator.paused ? "SIMULATION RUNNING" : "SIMULATION PAUSED"
                            font.pixelSize: 11
                            font.bold: true
                            color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: root.borderDim }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 43
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 0
                Repeater {
                    model: [
                        {lbl:"TRACKS",        val: simulator ? String(simulator.trackCount) : "--", unit:"(Simulated)"},
                        {lbl:"SCENARIO",      val: "Research-01", unit:"Multi-Platform Test"},
                        {lbl:"SIM TIME (UTC)",val: simClockText,  unit:""},
                        {lbl:"ELAPSED",       val: simulator ? simulator.simTimeDisplay : "00:00:00", unit:""},
                        {lbl:"WEATHER (SIM)", val: "Clear  18 C", unit:"Wind 12kt NW(310)"},
                        {lbl:"ENVIRONMENT",   val: "Coastal / Mountain", unit:""},
                    ]
                    delegate: RowLayout {
                        spacing: 0
                        Rectangle {
                            width: 1
                            height: 34
                            color: root.borderDim
                            visible: index > 0
                        }
                        ColumnLayout {
                            spacing: 1
                            Layout.leftMargin: 18
                            Layout.rightMargin: 18
                            Text {
                                text: modelData.lbl
                                font.pixelSize: 9
                                color: root.textLabel
                                font.letterSpacing: 1
                            }
                            Text {
                                text: modelData.val
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textPrime
                            }
                            Text {
                                text: modelData.unit
                                visible: modelData.unit !== ""
                                font.pixelSize: 9
                                color: root.textDim
                            }
                        }
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 2
        spacing: 0

        // Left navigation
        Rectangle {
            Layout.preferredWidth: 160
            Layout.fillHeight: true
            color: "#07101e"
            border.color: root.borderDim
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 10
                spacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.borderDim
                }
                Repeater {
                    model: [
                        {label:"OVERVIEW",    active:false},
                        {label:"FLIGHT SIM",  active:true},
                        {label:"RADAR PPI",   active:false},
                        {label:"AIR TRAFFIC", active:false},
                        {label:"SENSORS",     active:false},
                        {label:"REPLAY",      active:false},
                        {label:"RESEARCH",    active:false},
                        {label:"SYSTEM",      active:false}
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 46
                        color: modelData.active ? "#0a2038" : "transparent"
                        border.color: modelData.active ? root.accentCyan : "transparent"
                        border.width: modelData.active ? 1 : 0
                        radius: 2
                        Text {
                            text: modelData.label
                            font.pixelSize: 11
                            font.bold: modelData.active
                            color: modelData.active ? root.textPrime : root.textDim
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            visible: modelData.active
                            width: 3
                            height: parent.height - 8
                            radius: 1
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.accentCyan
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                Text {
                    text: "NEXVARY Inc."
                    font.pixelSize: 9
                    color: root.textDim
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 8
                }
            }
        }

        // Ã¢â€â‚¬Ã¢â€â‚¬ Main workspace Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                // Ã¢â€â‚¬Ã¢â€â‚¬ Radar PPI panel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.bgPanel
                    border.color: root.borderDim
                    border.width: 1
                    radius: 4

                    RowLayout {
                        id: radarHdr
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 8
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        height: 28
                        spacing: 8
                        Rectangle { width: 10; height: 10; radius: 5; color: root.accentCyan }
                        Text {
                            text: "RADAR PPI \u2014 Simulated Tracks"
                            font.pixelSize: 12
                            font.bold: true
                            color: root.textPrime
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "R: " + root.radarKm + " km"
                            font.pixelSize: 10
                            color: root.accentCyan
                        }
                    }

                    Canvas {
                        id: radarCanvas
                        anchors.top: radarHdr.bottom
                        anchors.bottom: radarLegend.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 6

                        property real sweepAngle: 0
                        NumberAnimation on sweepAngle {
                            from: 0
                            to: 360
                            duration: 4000
                            loops: Animation.Infinite
                            running: simulator ? !simulator.paused : false
                        }
                        onSweepAngleChanged: requestPaint()

                        Connections {
                            target: simulator
                            function onSimStateChanged() { radarCanvas.requestPaint() }
                        }

                        onPaint: {
                            var ctx = getContext("2d");
                            var W = width, H = height;
                            if (W < 10 || H < 10) return;
                            var cx = W * 0.5, cy = H * 0.5;
                            var R = Math.min(W, H) * 0.44;
                            ctx.clearRect(0, 0, W, H);
                            ctx.fillStyle = "#030810";
                            ctx.fillRect(0, 0, W, H);
                            var i, rr, rad, b;
                            for (i = 1; i <= 4; i++) {
                                rr = R * i / 4;
                                ctx.beginPath();
                                ctx.arc(cx, cy, rr, 0, 2 * Math.PI);
                                ctx.strokeStyle = (i === 4) ? "#143a60" : "#0e2840";
                                ctx.lineWidth = (i === 4) ? 1.5 : 0.8;
                                ctx.stroke();
                                ctx.fillStyle = "#2a5a70";
                                ctx.font = "9px Consolas,monospace";
                                ctx.textAlign = "left";
                                ctx.fillText((root.radarKm * i / 4).toFixed(0) + " km",
                                             cx + 4, cy - rr + 10);
                            }
                            var brgs = [0,30,60,90,120,150,180,210,240,270,300,330];
                            for (i = 0; i < brgs.length; i++) {
                                b = brgs[i];
                                rad = (b - 90) * Math.PI / 180;
                                ctx.beginPath();
                                ctx.moveTo(cx, cy);
                                ctx.lineTo(cx + Math.cos(rad) * R, cy + Math.sin(rad) * R);
                                ctx.strokeStyle = (b % 90 === 0) ? "#1a4060" : "#0d2838";
                                ctx.lineWidth = (b % 90 === 0) ? 1 : 0.5;
                                ctx.stroke();
                                ctx.fillStyle = "#2a5070";
                                ctx.font = "9px Consolas,monospace";
                                ctx.textAlign = "center";
                                ctx.fillText(b + "\u00B0",
                                             cx + Math.cos(rad) * (R + 14),
                                             cy + Math.sin(rad) * (R + 14) + 3);
                            }
                            ctx.textAlign = "left";
                            var sr = (sweepAngle - 90) * Math.PI / 180;
                            ctx.beginPath();
                            ctx.moveTo(cx, cy);
                            ctx.arc(cx, cy, R * 0.98, sr - 1.05, sr, false);
                            ctx.closePath();
                            ctx.fillStyle = "rgba(0,212,240,0.04)";
                            ctx.fill();
                            ctx.beginPath();
                            ctx.moveTo(cx, cy);
                            ctx.lineTo(cx + Math.cos(sr) * R, cy + Math.sin(sr) * R);
                            ctx.strokeStyle = "rgba(0,212,240,0.65)";
                            ctx.lineWidth = 2;
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(cx, cy, 4, 0, 2 * Math.PI);
                            ctx.fillStyle = "#00d4f0";
                            ctx.fill();
                            if (!simulator) return;
                            var tracks = simulator.tracks;
                            if (!tracks || tracks.length === 0) return;
                            var t, px, py, bc, trail, j, a, tpx, tpy, lx, ly, ti;
                            for (ti = 0; ti < tracks.length; ti++) {
                                t = tracks[ti];
                                bc = (t.type === "UAS") ? "#00e888" : "#00d4f0";
                                px = cx + (t.x_km / root.radarKm) * R;
                                py = cy - (t.y_km / root.radarKm) * R;
                                trail = t.trail;
                                if (trail && trail.length > 1) {
                                    for (j = 1; j < trail.length; j++) {
                                        a = j / trail.length;
                                        tpx = cx + (trail[j].x_km / root.radarKm) * R;
                                        tpy = cy - (trail[j].y_km / root.radarKm) * R;
                                        ctx.beginPath();
                                        ctx.arc(tpx, tpy, 2, 0, 2 * Math.PI);
                                        ctx.fillStyle = "rgba(0,220,160," + (a * 0.55) + ")";
                                        ctx.fill();
                                    }
                                }
                                ctx.save();
                                ctx.translate(px, py);
                                ctx.rotate((t.heading_deg - 90) * Math.PI / 180);
                                ctx.strokeStyle = bc;
                                ctx.lineWidth = t.selected ? 2.5 : 1.5;
                                if (t.type === "UAS") {
                                    ctx.strokeRect(-6, -6, 12, 12);
                                    ctx.beginPath();
                                    ctx.moveTo(-5, -5); ctx.lineTo(5, 5);
                                    ctx.moveTo(5, -5);  ctx.lineTo(-5, 5);
                                    ctx.stroke();
                                } else {
                                    ctx.beginPath();
                                    ctx.moveTo(0, -9); ctx.lineTo(0, 9);
                                    ctx.moveTo(-8, 2); ctx.lineTo(8, 2);
                                    ctx.moveTo(-3, 7); ctx.lineTo(3, 7);
                                    ctx.stroke();
                                }
                                ctx.restore();
                                ctx.beginPath();
                                ctx.moveTo(px, py);
                                ctx.lineTo(px + Math.cos((t.heading_deg-90)*Math.PI/180)*20,
                                           py + Math.sin((t.heading_deg-90)*Math.PI/180)*20);
                                ctx.strokeStyle = "rgba(0,210,230,0.5)";
                                ctx.lineWidth = 1;
                                ctx.setLineDash([3,3]);
                                ctx.stroke();
                                ctx.setLineDash([]);
                                if (t.selected) {
                                    ctx.fillStyle = "rgba(8,24,40,0.88)";
                                    ctx.fillRect(px + 10, py - 50, 130, 54);
                                    ctx.strokeStyle = bc;
                                    ctx.lineWidth = 0.8;
                                    ctx.strokeRect(px + 10, py - 50, 130, 54);
                                }
                                lx = px + (t.selected ? 14 : 10);
                                ly = py + (t.selected ? -46 : -10);
                                ctx.fillStyle = bc;
                                ctx.font = "bold 11px Consolas,monospace";
                                ctx.fillText(t.label, lx, ly);
                                ctx.fillStyle = "#80b0c8";
                                ctx.font = "9px Consolas,monospace";
                                ctx.fillText(t.range_km.toFixed(1) + " km", lx, ly + 13);
                                ctx.fillText(t.altitude_m.toFixed(0) + " m", lx, ly + 24);
                                ctx.fillText(t.speed_kt.toFixed(0) + " kt  " + t.heading_deg.toFixed(0) + "\u00B0",
                                             lx, ly + 35);
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: function(mouse) {
                                if (!simulator) return;
                                var W = radarCanvas.width, H = radarCanvas.height;
                                var cx = W * 0.5, cy = H * 0.5;
                                var R = Math.min(W, H) * 0.44;
                                var tracks = simulator.tracks;
                                if (!tracks) return;
                                var best = -1, bestD = 18;
                                for (var ti = 0; ti < tracks.length; ti++) {
                                    var t = tracks[ti];
                                    var px = cx + (t.x_km / root.radarKm) * R;
                                    var py = cy - (t.y_km / root.radarKm) * R;
                                    var d = Math.sqrt((mouse.x-px)*(mouse.x-px) +
                                                      (mouse.y-py)*(mouse.y-py));
                                    if (d < bestD) { bestD = d; best = t.id; }
                                }
                                if (best >= 0) simulator.selectTrack(best);
                            }
                        }
                    }

                    RowLayout {
                        id: radarLegend
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottomMargin: 6
                        anchors.leftMargin: 12
                        height: 20
                        spacing: 16
                        Text { text: "UAS (Multirotor)";      color: "#00e888"; font.pixelSize: 9 }
                        Text { text: "Aircraft (Fixed-Wing)"; color: "#00d4f0"; font.pixelSize: 9 }
                        Text { text: "Track History";         color: "#00dc80"; font.pixelSize: 9 }
                        Item { Layout.fillWidth: true }
                        Text { text: "DATA: SYNTHETIC"; color: root.accentAmb; font.pixelSize: 9 }
                    }
                }

                // Ã¢â€â‚¬Ã¢â€â‚¬ 3-D scene placeholder Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true
                    color: root.bgPanel
                    border.color: root.borderDim
                    border.width: 1
                    radius: 4

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        RowLayout {
                            spacing: 8
                            Rectangle { width: 8; height: 8; radius: 4; color: root.textDim }
                            Text {
                                text: "3-D SCENE (P2)"
                                font.pixelSize: 11
                                font.bold: true
                                color: root.textDim
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#050e1a"
                            radius: 2
                            Text {
                                anchors.centerIn: parent
                                text: "Qt Quick 3D\nScene\nPlanned P2"
                                font.pixelSize: 10
                                color: root.textLabel
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            visible: simulator && simulator.selected &&
                                     simulator.selected.id !== undefined
                            Text {
                                text: "SELECTED TRACK"
                                font.pixelSize: 9
                                color: root.textLabel
                            }
                            Rectangle { Layout.fillWidth: true; height: 1; color: root.borderDim }
                            Repeater {
                                model: (simulator && simulator.selected &&
                                        simulator.selected.id !== undefined) ? [
                                    {k:"ID",   v: String(simulator.selected.label)},
                                    {k:"TYPE", v: String(simulator.selected.type)},
                                    {k:"ALT",  v: simulator.selected.altitude_m.toFixed(0) + " m"},
                                    {k:"SPD",  v: simulator.selected.speed_kt.toFixed(0) + " kt"},
                                    {k:"HDG",  v: simulator.selected.heading_deg.toFixed(0) + "\u00B0"},
                                    {k:"RNG",  v: simulator.selected.range_km.toFixed(1) + " km"}
                                ] : []
                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.k
                                        font.pixelSize: 9
                                        color: root.textDim
                                        Layout.preferredWidth: 40
                                    }
                                    Text {
                                        text: modelData.v
                                        font.pixelSize: 9
                                        color: root.accentCyan
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Ã¢â€â‚¬Ã¢â€â‚¬ Instruments row Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
            Rectangle {
                Layout.fillWidth: true
                height: 86
                color: root.bgPanel
                border.color: root.borderDim
                border.width: 1
                radius: 4
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 0

                    Repeater {
                        model: (simulator && simulator.selected &&
                                simulator.selected.id !== undefined) ? [
                            {lbl:"ALTITUDE", val: simulator.selected.altitude_m.toFixed(0), unit:"m MSL"},
                            {lbl:"SPEED",    val: simulator.selected.speed_kt.toFixed(1),   unit:"kt"},
                            {lbl:"HEADING",  val: simulator.selected.heading_deg.toFixed(0),unit:"\u00B0 (CW/N)"},
                            {lbl:"RANGE",    val: simulator.selected.range_km.toFixed(2),   unit:"km"},
                            {lbl:"TRACK ID", val: simulator.selected.label,                 unit:simulator.selected.type}
                        ] : [
                            {lbl:"ALTITUDE", val:"--", unit:"m MSL"},
                            {lbl:"SPEED",    val:"--", unit:"kt"},
                            {lbl:"HEADING",  val:"--", unit:"\u00B0"},
                            {lbl:"RANGE",    val:"--", unit:"km"},
                            {lbl:"TRACK ID", val:"--", unit:"Select track"}
                        ]
                        delegate: RowLayout {
                            spacing: 0
                            Rectangle {
                                width: 1
                                height: 50
                                color: root.borderDim
                                visible: index > 0
                            }
                            ColumnLayout {
                                spacing: 2
                                Layout.leftMargin: 20
                                Layout.rightMargin: 20
                                Text {
                                    text: modelData.lbl
                                    font.pixelSize: 9
                                    color: root.textLabel
                                    font.family: root.monoFont
                                    font.bold: true
                                }
                                Text {
                                    text: modelData.val
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: root.accentCyan
                                    font.family: root.monoFont
                                }
                                Text {
                                    text: modelData.unit
                                    font.pixelSize: 9
                                    color: root.textDim
                                    font.family: root.monoFont
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ColumnLayout {
                        spacing: 4
                        Layout.rightMargin: 8
                        Text {
                            text: simulator ? simulator.simTimeDisplay : "--:--:--"
                            font.pixelSize: 22
                            font.bold: true
                            color: root.textPrime
                            font.family: root.monoFont
                            Layout.alignment: Qt.AlignHCenter
                        }
                        RowLayout {
                            spacing: 6
                            Layout.alignment: Qt.AlignHCenter
                            Repeater {
                                model: [
                                    {lbl:"PLAY",  col:"#00d4f0"},
                                    {lbl:"PAUSE", col:"#f0b040"},
                                    {lbl:"RESET", col:"#5a7890"}
                                ]
                                delegate: Rectangle {
                                    width: 54
                                    height: 22
                                    radius: 2
                                    color: ctlMa.containsMouse ? Qt.lighter(modelData.col, 1.3) : "transparent"
                                    border.color: modelData.col
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.lbl
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: ctlMa.containsMouse ? "#000" : modelData.col
                                        font.family: root.monoFont
                                    }
                                    MouseArea {
                                        id: ctlMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (!simulator) return;
                                            if (modelData.lbl === "PLAY")       simulator.play();
                                            else if (modelData.lbl === "PAUSE") simulator.pause();
                                            else                                 simulator.reset();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Ã¢â€â‚¬Ã¢â€â‚¬ Timeline bar Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: root.bgPanel
                border.color: root.borderDim
                border.width: 1
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12
                    Text {
                        text: "SCENARIO TIMELINE"
                        font.pixelSize: 9
                        font.bold: true
                        color: root.textLabel
                        font.family: root.monoFont
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: "#0d1e30"
                        Rectangle {
                            width: parent.width * Math.min(1.0,
                                       simulator ? simulator.simTimeSeconds / 600.0 : 0)
                            height: parent.height
                            radius: parent.radius
                            color: root.accentCyan
                        }
                    }
                    Text {
                        text: simulator ? simulator.simTimeDisplay : "00:00:00"
                        font.pixelSize: 10
                        color: root.accentCyan
                        font.family: root.monoFont
                    }
                    Text {
                        text: "10:00"
                        font.pixelSize: 10
                        color: root.textDim
                        font.family: root.monoFont
                    }
                }
            }
        }

        // Ã¢â€â‚¬Ã¢â€â‚¬ Right control panel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
        Rectangle {
            Layout.preferredWidth: 210
            Layout.fillHeight: true
            color: "#07101e"
            border.color: root.borderDim
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "CONTROLS"
                    font.pixelSize: 10
                    font.bold: true
                    color: root.textLabel
                    font.family: root.monoFont
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: root.borderDim }

                RowLayout {
                    spacing: 8
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                    }
                    Text {
                        text: simulator && !simulator.paused ? "RUNNING" : "PAUSED"
                        font.pixelSize: 11
                        font.bold: true
                        color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                        font.family: root.monoFont
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: [
                            {lbl:"PLAY",  sub:"Resume simulation", col:"#00d4f0"},
                            {lbl:"PAUSE", sub:"Freeze simulation",  col:"#f0b040"},
                            {lbl:"RESET", sub:"Restore to T=0",     col:"#5a7890"}
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 44
                            radius: 3
                            color: bigMa.containsMouse ? Qt.lighter(modelData.col, 1.4) : "#0d1e30"
                            border.color: modelData.col
                            border.width: 1
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    text: modelData.lbl
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: bigMa.containsMouse ? "#000" : modelData.col
                                    font.family: root.monoFont
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: modelData.sub
                                    font.pixelSize: 8
                                    color: bigMa.containsMouse ? "#333" : root.textDim
                                    font.family: root.monoFont
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            MouseArea {
                                id: bigMa
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (!simulator) return;
                                    if (modelData.lbl === "PLAY")       simulator.play();
                                    else if (modelData.lbl === "PAUSE") simulator.pause();
                                    else                                 simulator.reset();
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: root.borderDim }

                Text {
                    text: "ACTIVE TRACKS"
                    font.pixelSize: 9
                    font.bold: true
                    color: root.textLabel
                    font.family: root.monoFont
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Repeater {
                        model: simulator ? simulator.tracks : []
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: 2
                            color: modelData.selected ? "#0a2038" : "transparent"
                            border.color: modelData.selected ? root.accentCyan : root.borderDim
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: 6
                                Rectangle {
                                    width: 7
                                    height: 7
                                    radius: 1
                                    color: modelData.type === "UAS" ? root.accentGrn : root.accentCyan
                                }
                                ColumnLayout {
                                    spacing: 1
                                    Text {
                                        text: modelData.label
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: root.textPrime
                                        font.family: root.monoFont
                                    }
                                    Text {
                                        text: modelData.type + "  " +
                                              modelData.speed_kt.toFixed(0) + "kt  " +
                                              modelData.altitude_m.toFixed(0) + "m"
                                        font.pixelSize: 8
                                        color: root.textDim
                                        font.family: root.monoFont
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: simulator.selectTrack(modelData.id)
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 3
                    color: "#1a1000"
                    border.color: root.accentAmb
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "DATA: SYNTHETIC\nNot for navigation"
                        font.pixelSize: 8
                        color: root.accentAmb
                        horizontalAlignment: Text.AlignHCenter
                        font.family: root.monoFont
                    }
                }
            }
        }

    }
}
