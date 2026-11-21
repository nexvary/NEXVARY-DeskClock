import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
// NEXVARY AeroRadar -- Simulation Lab Dashboard (SYNTHETIC DATA ONLY)
ApplicationWindow {
    id: root; visible: true; width: 1440; height: 900
    minimumWidth: 1200; minimumHeight: 760
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
    readonly property real RADAR_KM: 40.0
    property string simClockText: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    Timer { interval: 1000; running: true; repeat: true
            onTriggered: root.simClockText = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss") }
    header: Rectangle {
        color: "#080f1c"; height: 90; border.color: root.borderDim; border.width: 1
        ColumnLayout { anchors.fill: parent; spacing: 0
            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 44
                Layout.leftMargin: 16; Layout.rightMargin: 16; spacing: 12
                Text { text: "NEXVARY AeroRadar"; font.pixelSize: 20; font.bold: true; color: root.textPrime }
                Text { text: "CIVIL AVIATION RESEARCH  |  SIMULATION LAB"
                       font.pixelSize: 10; color: root.textDim; font.letterSpacing: 2 }
                Item { Layout.fillWidth: true }
                Rectangle { height: 28; width: simbadge.implicitWidth+24; radius:4
                    color: "#2a1800"; border.color: root.accentAmb; border.width:1
                    Row { anchors.centerIn:parent; spacing:6
                        Text { text:"WARNING"; font.pixelSize:10; color:root.accentAmb; font.bold:true }
                        Text { id:simbadge; text:"SIMULATION ONLY  |  NO LIVE DATA"
                               font.pixelSize:11; color:root.accentAmb; font.bold:true } }
                }
                Rectangle { height:28; width:runlbl.implicitWidth+28; radius:4
                    color: simulator && !simulator.paused ? "#0a2a10" : "#1a1a0a"
                    border.color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                    border.width:1
                    Row { anchors.centerIn:parent; spacing:6
                        Rectangle { width:7;height:7;radius:4; anchors.verticalCenter:parent.verticalCenter
                            color: simulator && !simulator.paused ? root.accentGrn : root.accentAmb
                            SequentialAnimation on opacity { running: simulator&&!simulator.paused; loops:Animation.Infinite
                                NumberAnimation{to:0.2;duration:600}; NumberAnimation{to:1.0;duration:400} }
                        }
                        Text { id:runlbl; text: simulator&&!simulator.paused?"SIMULATION RUNNING":"SIMULATION PAUSED"
                               font.pixelSize:11; font.bold:true
                               color: simulator&&!simulator.paused?root.accentGrn:root.accentAmb }
                    }
                }
            }
            Rectangle { Layout.fillWidth:true; height:1; color:root.borderDim }
            RowLayout {
                Layout.fillWidth:true; Layout.preferredHeight:43
                Layout.leftMargin:16; Layout.rightMargin:16; spacing:0
                Repeater {
                    model: [
                        {lbl:"TRACKS",        val: simulator?String(simulator.trackCount):"--", unit:"(Simulated)"},
                        {lbl:"SCENARIO",      val:"Research-01", unit:"Multi-Platform Test"},
                        {lbl:"SIM TIME (UTC)",val:simClockText,  unit:""},
                        {lbl:"ELAPSED",       val:simulator?simulator.simTimeDisplay:"00:00:00", unit:""},
                        {lbl:"WEATHER (SIM)", val:"Clear  18 C", unit:"Wind 12kt NW(310)"},
                        {lbl:"ENVIRONMENT",   val:"Coastal / Mountain", unit:""},
                    ]
                    delegate: RowLayout { spacing:0
                        Rectangle { width:1;height:34;color:root.borderDim;visible:index>0 }
                        ColumnLayout { spacing:1; Layout.leftMargin:18; Layout.rightMargin:18
                            Text{text:modelData.lbl;font.pixelSize:9;color:root.textLabel;font.letterSpacing:1}
                            Text{text:modelData.val;font.pixelSize:14;font.bold:true;color:root.textPrime}
                            Text{text:modelData.unit;visible:modelData.unit!=="";font.pixelSize:9;color:root.textDim}
                        }
                    }
                }
                Item { Layout.fillWidth:true }
            }
        }
    }
    RowLayout { anchors{fill:parent;topMargin:2}; spacing:0
        // Left navigation
        Rectangle { Layout.preferredWidth:160; Layout.fillHeight:true
            color:"#07101e"; border.color:root.borderDim; border.width:1
            ColumnLayout { anchors{fill:parent;topMargin:10}; spacing:2
                Rectangle{Layout.fillWidth:true;height:1;color:root.borderDim}
                Repeater {
                    model: [{label:"OVERVIEW",active:false},{label:"FLIGHT SIM",active:true},
                            {label:"RADAR PPI",active:false},{label:"AIR TRAFFIC",active:false},
                            {label:"SENSORS",active:false},{label:"REPLAY",active:false},
                            {label:"RESEARCH",active:false},{label:"SYSTEM",active:false}]
                    delegate: Rectangle { Layout.fillWidth:true; height:46
                        color:modelData.active?"#0a2038":"transparent"
                        border.color:modelData.active?root.accentCyan:"transparent"
                        border.width:modelData.active?1:0; radius:2
                        Text { text:modelData.label; font.pixelSize:11; font.bold:modelData.active
                               color:modelData.active?root.textPrime:root.textDim
                               anchors{left:parent.left;leftMargin:20;verticalCenter:parent.verticalCenter} }
                        Rectangle { visible:modelData.active; width:3; height:parent.height-8; radius:1
                                    anchors{left:parent.left;verticalCenter:parent.verticalCenter}
                                    color:root.accentCyan }
                    }
                }
                Item { Layout.fillHeight:true }
                Text { text:"NEXVARY Inc."; font.pixelSize:9; color:root.textDim
                       Layout.alignment:Qt.AlignHCenter; Layout.bottomMargin:8 }
            }
        }
        // Main workspace
        ColumnLayout { Layout.fillWidth:true; Layout.fillHeight:true; spacing:2
            // Radar PPI + Flight scene
            RowLayout { Layout.fillWidth:true; Layout.fillHeight:true; spacing:2
                // Radar PPI
                Rectangle { Layout.fillWidth:true; Layout.fillHeight:true
                    color:root.bgPanel; border.color:root.borderDim; border.width:1; radius:4
                    RowLayout { id:radarHdr
                        anchors{top:parent.top;left:parent.left;right:parent.right;topMargin:8;leftMargin:12;rightMargin:12}
                        height:28; spacing:8
                        Rectangle{width:10;height:10;radius:5;color:root.accentCyan}
                        Text{text:"RADAR PPI (Simulated Tracks)";font.pixelSize:12;font.bold:true;color:root.textPrime}
                        Item{Layout.fillWidth:true}
                        Text{text:"R: "+root.RADAR_KM+" km";font.pixelSize:10;color:root.accentCyan}
                    }
                    Canvas { id:radarCanvas
                        anchors{top:radarHdr.bottom;bottom:radarLgd.top;left:parent.left;right:parent.right;margins:6}
                        property real sweepAngle:0
                        NumberAnimation on sweepAngle{from:0;to:360;duration:4000;loops:Animation.Infinite
                            running:simulator?!simulator.paused:false}
                        onSweepAngleChanged: requestPaint()
                        Connections{target:simulator; function onSimStateChanged(){radarCanvas.requestPaint()}}
                        onPaint: {
                            var ctx=getContext("2d"),W=width,H=height,cx=W*0.5,cy=H*0.5,R=Math.min(W,H)*0.44
                            ctx.clearRect(0,0,W,H); ctx.fillStyle="#030810"; ctx.fillRect(0,0,W,H)
                            var i,rr,rad,b
                            for(i=1;i<=4;i++){rr=R*i/4;ctx.beginPath();ctx.arc(cx,cy,rr,0,2*Math.PI)
                                ctx.strokeStyle=i===4?"#143a60":"#0e2840";ctx.lineWidth=i===4?1.5:0.8;ctx.stroke()
                                ctx.fillStyle="#2a5a70";ctx.font="9px Consolas,monospace"
                                ctx.fillText((root.RADAR_KM*i/4).toFixed(0)+" km",cx+4,cy-rr+10)}
                            var brgs=[0,30,60,90,120,150,180,210,240,270,300,330]
                            for(i=0;i<brgs.length;i++){b=brgs[i];rad=(b-90)*Math.PI/180
                                ctx.beginPath();ctx.moveTo(cx,cy);ctx.lineTo(cx+Math.cos(rad)*R,cy+Math.sin(rad)*R)
                                ctx.strokeStyle=b%90===0?"#1a4060":"#0d2838";ctx.lineWidth=b%90===0?1:0.5;ctx.stroke()
                                ctx.fillStyle="#2a5070";ctx.font="9px Consolas,monospace";ctx.textAlign="center"
                                ctx.fillText(b+"d",cx+Math.cos(rad)*(R+14),cy+Math.sin(rad)*(R+14)+3)}
                            ctx.textAlign="left"
                            var sr=(sweepAngle-90)*Math.PI/180
                            ctx.beginPath();ctx.moveTo(cx,cy);ctx.arc(cx,cy,R*0.98,sr-1.05,sr,false);ctx.closePath()
                            ctx.fillStyle="rgba(0,212,240,0.04)";ctx.fill()
                            ctx.beginPath();ctx.moveTo(cx,cy);ctx.lineTo(cx+Math.cos(sr)*R,cy+Math.sin(sr)*R)
                            ctx.strokeStyle="rgba(0,212,240,0.65)";ctx.lineWidth=2;ctx.stroke()
                            ctx.beginPath();ctx.arc(cx,cy,4,0,2*Math.PI);ctx.fillStyle="#00d4f0";ctx.fill()
                            if(!simulator)return; var tracks=simulator.tracks; if(!tracks)return
                            var t,px,py,bc,trail,j,a,tpx,tpy,lx,ly,ti
                            for(ti=0;ti<tracks.length;ti++){t=tracks[ti];bc=t.type==="UAS"?"#00e888":"#00d4f0"
                                px=cx+(t.x_km/root.RADAR_KM)*R; py=cy-(t.y_km/root.RADAR_KM)*R
                                trail=t.trail
                                if(trail&&trail.length>1){for(j=1;j<trail.length;j++){a=j/trail.length
                                    tpx=cx+(trail[j].x_km/root.RADAR_KM)*R;tpy=cy-(trail[j].y_km/root.RADAR_KM)*R
                                    ctx.beginPath();ctx.arc(tpx,tpy,2,0,2*Math.PI)
                                    ctx.fillStyle="rgba(0,220,160,"+(a*0.55)+")";ctx.fill()}}
                                ctx.save();ctx.translate(px,py);ctx.rotate((t.heading_deg-90)*Math.PI/180)
                                ctx.strokeStyle=bc;ctx.lineWidth=t.selected?2.5:1.5
                                if(t.type==="UAS"){ctx.strokeRect(-6,-6,12,12);ctx.beginPath()
                                    ctx.moveTo(-5,-5);ctx.lineTo(5,5);ctx.moveTo(5,-5);ctx.lineTo(-5,5);ctx.stroke()
                                }else{ctx.beginPath();ctx.moveTo(0,-9);ctx.lineTo(0,9)
                                    ctx.moveTo(-8,2);ctx.lineTo(8,2);ctx.moveTo(-3,7);ctx.lineTo(3,7);ctx.stroke()}
                                ctx.restore()
                                ctx.beginPath();ctx.moveTo(px,py)
                                ctx.lineTo(px+Math.cos((t.heading_deg-90)*Math.PI/180)*20,
                                           py+Math.sin((t.heading_deg-90)*Math.PI/180)*20)
                                ctx.strokeStyle="rgba(0,210,230,0.5)";ctx.lineWidth=1
                                ctx.setLineDash([3,3]);ctx.stroke();ctx.setLineDash([])
                                if(t.selected){ctx.fillStyle="rgba(8,24,40,0.88)"
                                    ctx.fillRect(px+10,py-50,130,54);ctx.strokeStyle=bc;ctx.lineWidth=0.8
                                    ctx.strokeRect(px+10,py-50,130,54)}
                                lx=px+(t.selected?14:10);ly=py+(t.selected?-46:-10)
                                ctx.fillStyle=bc;ctx.font="bold 11px Consolas,monospace";ctx.fillText(t.label,lx,ly)
                                ctx.fillStyle="#80b0c8";ctx.font="9px Consolas,monospace"
                                ctx.fillText(t.range_km.toFixed(1)+" km",lx,ly+13)
                                ctx.fillText(t.altitude_m.toFixed(0)+" m",lx,ly+24)
                                ctx.fillText(t.speed_kt.toFixed(0)+" kt",lx,ly+35)}
                        }
                    }
                    RowLayout{id:radarLgd;anchors{bottom:parent.bottom;left:parent.left;right:parent.right;bottomMargin:6;leftMargin:12};height:20;spacing:16
                        Text{text:"UAS (Multirotor)";color:"#00e888";font.pixelSize:9}
                        Text{text:"Aircraft (Fixed-Wing)";color:"#00d4f0";font.pixelSize:9}
                        Text{text:"Track History";color:"#00dc80";font.pixelSize:9}
                        Item{Layout.fillWidth:true}
                    }
                }
                // 3D scene placeholder
                Rectangle { Layout.fillWidth:true; Layout.fillHeight:true
                    color:root.bgPanel; border.color:root.borderDim; border.width:1; radius:4
                    RowLayout{id:sceneHdr;anchors{top:parent.top;left:parent.left;right:parent.right;topMargin:8;leftMargin:12;rightMargin:12};height:28;spacing:8
                        Rectangle{width:10;height:10;radius:5;color:"#a060f0"}
                        Text{text:"3D FLIGHT SCENE  |  SYNTHETIC";font.pixelSize:12;font.bold:true;color:root.textPrime}
                    }
                    Rectangle{anchors{right:parent.right;top:sceneHdr.bottom;rightMargin:10;topMargin:6};width:130;height:84
                        color:"rgba(6,12,20,0.80)";radius:4;border.color:"#1a3050";border.width:1
                        visible:simulator&&simulator.selected&&simulator.selected.label!==undefined
                        ColumnLayout{anchors{fill:parent;margins:8};spacing:2
                            Text{text:simulator&&simulator.selected?simulator.selected.label:"";font.pixelSize:13;font.bold:true;color:root.accentCyan}
                            Text{text:"ALT "+(simulator&&simulator.selected?simulator.selected.altitude_m.toFixed(0):"--")+" m";font.pixelSize:10;color:root.textPrime}
                            Text{text:"GS  "+(simulator&&simulator.selected?simulator.selected.speed_kt.toFixed(0):"--")+" kt";font.pixelSize:10;color:root.textPrime}
                            Text{text:"HDG "+(simulator&&simulator.selected?simulator.selected.heading_deg.toFixed(0):"--")+" deg";font.pixelSize:10;color:root.textPrime}
                        }
                    }
                    Canvas{anchors{top:sceneHdr.bottom;bottom:parent.bottom;left:parent.left;right:parent.right;margins:4}
                        onPaint:{
                            var ctx=getContext("2d"),W=width,H=height
                            ctx.clearRect(0,0,W,H)
                            var sky=ctx.createLinearGradient(0,0,0,H*0.62)
                            sky.addColorStop(0,"#04111e");sky.addColorStop(1,"#0d2440")
                            ctx.fillStyle=sky;ctx.fillRect(0,0,W,H*0.62)
                            var ter=ctx.createLinearGradient(0,H*0.62,0,H)
                            ter.addColorStop(0,"#0a1a0a");ter.addColorStop(1,"#050e05")
                            ctx.fillStyle=ter;ctx.fillRect(0,H*0.62,W,H*0.38)
                            ctx.beginPath();ctx.moveTo(0,H*0.62);ctx.lineTo(W,H*0.62)
                            ctx.strokeStyle="#1a5040";ctx.lineWidth=1;ctx.stroke()
                            ctx.beginPath();ctx.moveTo(0,H*0.62)
                            var mp=[0,0.62,0.12,0.50,0.22,0.60,0.35,0.44,0.5,0.58,0.65,0.42,0.78,0.52,0.9,0.46,1,0.62]
                            var mi;for(mi=0;mi<mp.length;mi+=2)ctx.lineTo(W*mp[mi],H*mp[mi+1])
                            ctx.lineTo(W,H*0.62);ctx.fillStyle="#0a1a08";ctx.fill()
                            ctx.fillStyle="rgba(0,0,0,0.5)";ctx.fillRect(W/2-170,H/2-18,340,36)
                            ctx.strokeStyle="#204050";ctx.strokeRect(W/2-170,H/2-18,340,36)
                            ctx.fillStyle="#3a7090";ctx.font="11px Consolas,monospace";ctx.textAlign="center"
                            ctx.fillText("Qt Quick 3D viewport -- planned P3 implementation",W/2,H/2+4)
                            ctx.textAlign="left"
                        }
                        Component.onCompleted:requestPaint()
                    }
                }
            }
            // Instruments row
            Rectangle{Layout.fillWidth:true;Layout.preferredHeight:130
                color:root.bgPanel;border.color:root.borderDim;border.width:1;radius:2
                RowLayout{anchors{fill:parent;margins:8};spacing:6
                    // Attitude indicator
                    ColumnLayout{Layout.preferredWidth:120;spacing:2
                        Text{text:"ATTITUDE (AC-01)";font.pixelSize:9;color:root.textLabel;font.letterSpacing:1}
                        Canvas{id:aiCanvas;width:110;height:100
                            onPaint:{
                                var ctx=getContext("2d"),cx=width/2,cy=height/2,r=46
                                ctx.clearRect(0,0,width,height)
                                ctx.save();ctx.beginPath();ctx.arc(cx,cy,r,0,2*Math.PI);ctx.clip()
                                ctx.fillStyle="#062240";ctx.fillRect(0,0,width,cy+8)
                                ctx.fillStyle="#1a0e04";ctx.fillRect(0,cy+8,width,height)
                                ctx.beginPath();ctx.moveTo(0,cy+8);ctx.lineTo(width,cy+8)
                                ctx.strokeStyle="#c08020";ctx.lineWidth=2;ctx.stroke()
                                ctx.restore()
                                ctx.beginPath();ctx.arc(cx,cy,r,0,2*Math.PI)
                                ctx.strokeStyle="#2a5060";ctx.lineWidth=2;ctx.stroke()
                                ctx.strokeStyle="#f0d040";ctx.lineWidth=2
                                ctx.beginPath();ctx.moveTo(cx-18,cy+8);ctx.lineTo(cx-6,cy+8);ctx.lineTo(cx-6,cy+4);ctx.stroke()
                                ctx.beginPath();ctx.moveTo(cx+18,cy+8);ctx.lineTo(cx+6,cy+8);ctx.lineTo(cx+6,cy+4);ctx.stroke()
                                ctx.beginPath();ctx.arc(cx,cy+6,3,0,2*Math.PI);ctx.fillStyle="#f0d040";ctx.fill()
                            }
                            Component.onCompleted:requestPaint()
                        }
                    }
                    Rectangle{width:1;Layout.fillHeight:true;color:root.borderDim}
                    // Heading
                    ColumnLayout{Layout.preferredWidth:110;spacing:2
                        Text{text:"HEADING";font.pixelSize:9;color:root.textLabel;font.letterSpacing:1}
                        Canvas{id:hdgCanvas;width:100;height:100
                            property real hdg:simulator&&simulator.selected?simulator.selected.heading_deg:87
                            onHdgChanged:requestPaint()
                            Connections{target:simulator;function onSimStateChanged(){hdgCanvas.requestPaint()}}
                            onPaint:{
                                var ctx=getContext("2d"),cx=width/2,cy=height/2,r=44,d,a
                                ctx.clearRect(0,0,width,height)
                                ctx.beginPath();ctx.arc(cx,cy,r,0,2*Math.PI);ctx.fillStyle="#04080f";ctx.fill()
                                ctx.strokeStyle="#1a4060";ctx.lineWidth=2;ctx.stroke()
                                for(d=0;d<360;d+=30){a=(d-hdg-90)*Math.PI/180
                                    var inner=d%90===0?r-10:r-6
                                    ctx.beginPath();ctx.moveTo(cx+Math.cos(a)*inner,cy+Math.sin(a)*inner)
                                    ctx.lineTo(cx+Math.cos(a)*(r-2),cy+Math.sin(a)*(r-2))
                                    ctx.strokeStyle=d%90===0?"#00d4f0":"#204858";ctx.lineWidth=d%90===0?1.5:0.8;ctx.stroke()}
                                ctx.fillStyle="#00d4f0";ctx.font="bold 16px Consolas,monospace"
                                ctx.textAlign="center";ctx.fillText(hdg.toFixed(0)+" deg",cx,cy+6);ctx.textAlign="left"
                            }
                        }
                    }
                    Rectangle{width:1;Layout.fillHeight:true;color:root.borderDim}
                    // Altitude
                    ColumnLayout{Layout.preferredWidth:90;spacing:2
                        Text{text:"ALTITUDE";font.pixelSize:9;color:root.textLabel;font.letterSpacing:1}
                        Rectangle{width:80;height:100;color:"#04080f";radius:3;border.color:root.borderDim
                            Text{anchors.centerIn:parent
                                text:simulator&&simulator.selected?simulator.selected.altitude_m.toFixed(0)+"\nm":"--"
                                font.pixelSize:16;font.bold:true;color:root.accentCyan;horizontalAlignment:Text.AlignHCenter}
                        }
                    }
                    Rectangle{width:1;Layout.fillHeight:true;color:root.borderDim}
                    // Ground speed
                    ColumnLayout{Layout.preferredWidth:120;spacing:2
                        Text{text:"GROUNDSPEED";font.pixelSize:9;color:root.textLabel;font.letterSpacing:1}
                        Text{text:simulator&&simulator.selected?simulator.selected.speed_kt.toFixed(0)+" kt":"-- kt"
                             font.pixelSize:24;font.bold:true;color:root.textPrime}
                    }
                    Rectangle{width:1;Layout.fillHeight:true;color:root.borderDim}
                    // Sensor source
                    ColumnLayout{Layout.fillWidth:true;spacing:4
                        Text{text:"SENSOR SOURCE";font.pixelSize:9;color:root.textLabel;font.letterSpacing:1}
                        Text{text:"Source:    Simulation";font.pixelSize:10;color:root.textPrime}
                        Text{text:"Type:      Synthetic (SITL)";font.pixelSize:10;color:root.textPrime}
                        Text{text:"Latency:   24 ms";font.pixelSize:10;color:root.textPrime}
                        Text{text:"Confidence: 0.98";font.pixelSize:10;color:root.accentGrn}
                    }
                }
            }
            // Timeline + telemetry row
            Rectangle{Layout.fillWidth:true;Layout.preferredHeight:130
                color:root.bgPanel;border.color:root.borderDim;border.width:1;radius:2
                RowLayout{anchors{fill:parent;margins:8};spacing:8
                    // Timeline
                    ColumnLayout{Layout.fillWidth:true;Layout.fillHeight:true;spacing:6
                        Row{spacing:8;Rectangle{width:10;height:10;radius:5;color:"#a060f0";anchors.verticalCenter:parent.verticalCenter}
                            Text{text:"FLIGHT TIMELINE & REPLAY";font.pixelSize:11;font.bold:true;color:root.textPrime}}
                        Item{Layout.fillWidth:true;height:20
                            Rectangle{anchors.verticalCenter:parent.verticalCenter;width:parent.width;height:4;radius:2;color:"#0d2030"
                                Rectangle{width:parent.width*0.3;height:parent.height;color:"#2060a0";radius:2}}
                            Text{text:"00:00:00";anchors{left:parent.left;bottom:parent.bottom};font.pixelSize:8;color:root.textDim}
                            Text{text:simulator?simulator.simTimeDisplay:"00:00:00"
                                 anchors{right:parent.right;bottom:parent.bottom};font.pixelSize:8;color:root.textDim}
                        }
                        RowLayout{spacing:8
                            Repeater{model:[{l:"|<",act:"toStart"},{l:"<<",act:"noop"},{l:"||>",act:"pause"},{l:">>",act:"noop"},{l:">|",act:"noop"}]
                                delegate:Rectangle{width:36;height:28;radius:3;color:"#071020";border.color:root.borderDim;border.width:1
                                    Text{anchors.centerIn:parent;text:modelData.l;font.pixelSize:11;color:root.textPrime}
                                    TapHandler{onTapped:{if(!simulator)return
                                        if(modelData.act==="pause"){if(simulator.paused)simulator.play();else simulator.pause()}
                                        else if(modelData.act==="toStart"){simulator.reset()}}}
                                }
                            }
                            Text{text:"x 1.0";font.pixelSize:11;color:root.textPrime}
                            Item{Layout.fillWidth:true}
                        }
                    }
                    Rectangle{width:1;Layout.fillHeight:true;color:root.borderDim}
                    // Telemetry chart
                    ColumnLayout{Layout.preferredWidth:parent.width*0.4;Layout.fillHeight:true;spacing:4
                        Row{spacing:8;Rectangle{width:10;height:10;radius:5;color:"#0060c0";anchors.verticalCenter:parent.verticalCenter}
                            Text{text:"TELEMETRY (AC-01)";font.pixelSize:11;font.bold:true;color:root.textPrime}}
                        Canvas{id:telCanvas;Layout.fillWidth:true;Layout.fillHeight:true
                            property var altHistory:[]
                            Connections{target:simulator;function onSimStateChanged(){
                                if(simulator&&simulator.selected)telCanvas.altHistory.push(simulator.selected.altitude_m)
                                if(telCanvas.altHistory.length>60)telCanvas.altHistory.shift()
                                telCanvas.requestPaint()}}
                            onPaint:{
                                var ctx=getContext("2d"),W=width,H=height
                                ctx.clearRect(0,0,W,H);ctx.fillStyle="#04090f";ctx.fillRect(0,0,W,H)
                                if(altHistory.length<2)return
                                var mx=altHistory[0],mn=altHistory[0],i
                                for(i=1;i<altHistory.length;i++){if(altHistory[i]>mx)mx=altHistory[i];if(altHistory[i]<mn)mn=altHistory[i]}
                                mx+=100;mn-=100;var rng=mx-mn||1
                                ctx.beginPath()
                                for(i=0;i<altHistory.length;i++){var x=i/(altHistory.length-1)*W,y=H-(altHistory[i]-mn)/rng*H
                                    if(i===0)ctx.moveTo(x,y);else ctx.lineTo(x,y)}
                                ctx.strokeStyle="#00d4f0";ctx.lineWidth=1.5;ctx.stroke()
                                ctx.fillStyle="#5a7890";ctx.font="8px Consolas,monospace";ctx.fillText("Altitude (m)",2,10)
                            }
                        }
                        Row{spacing:12;Repeater{model:[{c:"#00d4f0",l:"Altitude (m)"},{c:"#00e888",l:"Groundspeed (kt)"},{c:"#f0b040",l:"VS (m/s)"}]
                            delegate:Row{spacing:4;Rectangle{width:12;height:2;color:modelData.c;radius:1;anchors.verticalCenter:parent.verticalCenter}
                                Text{text:modelData.l;font.pixelSize:8;color:root.textDim}}}}
                    }
                }
            }
        }
        // Right panel
        Rectangle{Layout.preferredWidth:220;Layout.fillHeight:true
            color:"#07101e";border.color:root.borderDim;border.width:1
            ColumnLayout{anchors{fill:parent;margins:8};spacing:8
                // Sensor health
                Rectangle{Layout.fillWidth:true;color:root.bgCard;radius:3;border.color:root.borderDim;border.width:1
                    height:sc1.implicitHeight+16
                    ColumnLayout{id:sc1;anchors{fill:parent;margins:8};spacing:4
                        Text{text:"SENSOR HEALTH";font.pixelSize:10;font.bold:true;color:root.textPrime}
                        Repeater{model:[{n:"GNSS (Sim)"},{n:"ADS-B (Sim)"},{n:"Radar (Sim)"},{n:"EO/IR (Sim)"}]
                            delegate:RowLayout{
                                Text{text:"  Online 100%";font.pixelSize:9;color:root.accentGrn}
                                Text{text:modelData.n;font.pixelSize:9;color:root.textDim;Layout.fillWidth:true}
                            }
                        }
                    }
                }
                // Scenario controls
                Rectangle{Layout.fillWidth:true;color:root.bgCard;radius:3;border.color:root.borderDim;border.width:1
                    height:sc2.implicitHeight+16
                    ColumnLayout{id:sc2;anchors{fill:parent;margins:8};spacing:6
                        Text{text:"SCENARIO CONTROLS";font.pixelSize:10;font.bold:true;color:root.textPrime}
                        Repeater{model:[{l:"Scenario",v:"Research-01"},{l:"Traffic",v:"3 Aircraft"},{l:"Weather",v:"Clear"},{l:"Wind",v:"12 kt (NW)"}]
                            delegate:RowLayout{Text{text:modelData.l+":";font.pixelSize:9;color:root.textDim;Layout.preferredWidth:62}
                                Text{text:modelData.v;font.pixelSize:9;color:root.textPrime}}}
                        RowLayout{spacing:4
                            Repeater{model:[{l:"Run",a:"play"},{l:"Pause",a:"pause"},{l:"Reset",a:"reset"}]
                                delegate:Rectangle{height:26;Layout.fillWidth:true;radius:3;color:"#071020"
                                    border.color:modelData.a==="play"?root.accentGrn:(modelData.a==="reset"?root.accentAmb:root.accentCyan);border.width:1
                                    Text{anchors.centerIn:parent;text:modelData.l;font.pixelSize:10;color:root.textPrime}
                                    TapHandler{onTapped:{if(!simulator)return
                                        if(modelData.a==="play")simulator.play()
                                        else if(modelData.a==="pause")simulator.pause()
                                        else simulator.reset()}}
                                }
                            }
                        }
                    }
                }
                // Waypoints
                Rectangle{Layout.fillWidth:true;color:root.bgCard;radius:3;border.color:root.borderDim;border.width:1
                    height:sc3.implicitHeight+16
                    ColumnLayout{id:sc3;anchors{fill:parent;margins:8};spacing:4
                        Text{text:"ROUTE & WAYPOINTS";font.pixelSize:10;font.bold:true;color:root.textPrime}
                        Repeater{model:[{w:"WPT-01",c:"34.112N 35.698E"},{w:"WPT-02",c:"34.178N 35.821E"},{w:"WPT-03",c:"34.230N 35.930E"}]
                            delegate:RowLayout{spacing:4
                                Rectangle{width:7;height:7;radius:3;color:root.accentAmb}
                                ColumnLayout{spacing:0
                                    Text{text:modelData.w;font.pixelSize:9;font.bold:true;color:root.textPrime}
                                    Text{text:modelData.c;font.pixelSize:8;color:root.textDim}
                                }
                            }
                        }
                    }
                }
                // Sim clock
                Rectangle{Layout.fillWidth:true;color:root.bgCard;radius:3;border.color:root.borderDim;border.width:1
                    height:sc4.implicitHeight+16
                    ColumnLayout{id:sc4;anchors{fill:parent;margins:8};spacing:4
                        Text{text:"SIMULATION CLOCK";font.pixelSize:10;font.bold:true;color:root.textPrime}
                        Repeater{model:[{l:"Elapsed",v:simulator?simulator.simTimeDisplay:"00:00:00"},{l:"Speed",v:"x 1.0"}]
                            delegate:RowLayout{Text{text:modelData.l+":";font.pixelSize:9;color:root.textDim;Layout.preferredWidth:60}
                                Text{text:modelData.v;font.pixelSize:10;font.bold:true;color:root.textPrime}}}
                    }
                }
                Item{Layout.fillHeight:true}
            }
        }
    }
    footer: Rectangle{height:28;color:"#04080f";border.color:root.borderDim;border.width:1
        Row{anchors{left:parent.left;leftMargin:12;verticalCenter:parent.verticalCenter};spacing:12
            Rectangle{width:7;height:7;radius:4;color:root.accentGrn;anchors.verticalCenter:parent.verticalCenter}
            Text{text:"MODE: OFFLINE SIMULATION";font.pixelSize:9;color:root.textDim}
            Text{text:"|";color:root.borderDim}
            Text{text:"DATA: SYNTHETIC";font.pixelSize:9;color:root.textDim}
            Text{text:"|";color:root.borderDim}
            Text{text:"BUILD: P0 FOUNDATION (v0.1)";font.pixelSize:9;color:root.textDim}
        }
        Text{text:"محاكاة الطيران";anchors{right:parent.right;rightMargin:12;verticalCenter:parent.verticalCenter}
             font.pixelSize:11;color:root.textDim}
    }
}
