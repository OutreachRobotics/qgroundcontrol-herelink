/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2
import QtQuick.Window           2.2
import QtQml.Models             2.1
import QtMultimedia             5.5
import QtQuick.Extras           1.4


import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

/// Flight Display View
QGCView {
    id:             root
    viewPanel:      _panel

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    property alias  guidedController:   guidedActionsController

    property bool activeVehicleJoystickEnabled: _activeVehicle ? _activeVehicle.joystickEnabled : false

    property var    _planMasterController:  masterController
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _mainIsMap:             false
//    property bool   _mainIsMap:             QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_mainIsMapKey,  true) : true
    property bool   _isPipVisible:          QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_PIPVisibleKey, true) : false
    property bool   _useChecklist:          QGroundControl.settingsManager.appSettings.useChecklist.rawValue
    property real   _savedZoomLevel:        0
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _pipSize:               flightView.width * 0.2
    property alias  _guidedController:      guidedActionsController
    property alias  _altitudeSlider:        altitudeSlider

    readonly property var       _dynamicCameras:        _activeVehicle ? _activeVehicle.dynamicCameras : null
    readonly property bool      _isCamera:              _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    readonly property bool      isBackgroundDark:       _mainIsMap ? (_flightMap ? _flightMap.isSatelliteMap : true) : true
    readonly property real      _defaultRoll:           0
    readonly property real      _defaultPitch:          0
    readonly property real      _defaultHeading:        0
    readonly property real      _defaultAltitudeAMSL:   0
    readonly property real      _defaultGroundSpeed:    0
    readonly property real      _defaultAirSpeed:       0
    readonly property string    _mapName:               "FlightDisplayView"
    readonly property string    _showMapBackgroundKey:  "/showMapBackground"
    readonly property string    _mainIsMapKey:          "MainFlyWindowIsMap"
    readonly property string    _PIPVisibleKey:         "IsPIPVisible"

    function setStates() {
        QGroundControl.saveBoolGlobalSetting(_mainIsMapKey, _mainIsMap)
        if(_mainIsMap) {
            //-- Adjust Margins
            _flightMapContainer.state   = "fullMode"
            _flightVideo.state          = "pipMode"
            //-- Save/Restore Map Zoom Level
            if(_savedZoomLevel != 0)
                _flightMap.zoomLevel = _savedZoomLevel
            else
                _savedZoomLevel = _flightMap.zoomLevel
        } else {
            //-- Adjust Margins
            _flightMapContainer.state   = "pipMode"
            _flightVideo.state          = "fullMode"
            //-- Set Map Zoom Level
            _savedZoomLevel = _flightMap.zoomLevel
            _flightMap.zoomLevel = _savedZoomLevel - 3
        }
    }

    function setPipVisibility(state) {
        _isPipVisible = state;
        QGroundControl.saveBoolGlobalSetting(_PIPVisibleKey, state)
    }

    function isInstrumentRight() {
        if(QGroundControl.corePlugin.options.instrumentWidget) {
            if(QGroundControl.corePlugin.options.instrumentWidget.source.toString().length) {
                switch(QGroundControl.corePlugin.options.instrumentWidget.widgetPosition) {
                case CustomInstrumentWidget.POS_TOP_LEFT:
                case CustomInstrumentWidget.POS_BOTTOM_LEFT:
                case CustomInstrumentWidget.POS_CENTER_LEFT:
                    return false;
                }
            }
        }
        return true;
    }

    PlanMasterController {
        id:                     masterController
        Component.onCompleted:  start(true /* flyView */)
    }

    BuiltInPreFlightCheckModel {
        id: preFlightCheckModel
    }

    Connections {
        target:                     _missionController
        onResumeMissionUploadFail:  guidedActionsController.confirmAction(guidedActionsController.actionResumeMissionUploadFail)
    }

    Component.onCompleted: {
        setStates()
        if(QGroundControl.corePlugin.options.flyViewOverlay.toString().length) {
            flyViewOverlay.source = QGroundControl.corePlugin.options.flyViewOverlay
        }
    }

    // The following code is used to track vehicle states such that we prompt to remove mission from vehicle when mission completes

    property bool vehicleArmed:                 _activeVehicle ? _activeVehicle.armed : true // true here prevents pop up from showing during shutdown
    property bool vehicleWasArmed:              false
    property bool vehicleInMissionFlightMode:   _activeVehicle ? (_activeVehicle.flightMode === _activeVehicle.missionFlightMode) : false
    property bool promptForMissionRemove:       false

    onVehicleArmedChanged: {
        if (vehicleArmed) {
            if (!promptForMissionRemove) {
                promptForMissionRemove = vehicleInMissionFlightMode
                vehicleWasArmed = true
            }
        } else {
            if (promptForMissionRemove && (_missionController.containsItems || _geoFenceController.containsItems || _rallyPointController.containsItems)) {
                // ArduPilot has a strange bug which prevents mission clear from working at certain times, so we can't show this dialog
                if (!_activeVehicle.apmFirmware) {
                    root.showDialog(missionCompleteDialogComponent, qsTr("Flight Plan complete"), showDialogDefaultWidth, StandardButton.Close)
                }
            }
            promptForMissionRemove = false
        }
    }

    onVehicleInMissionFlightModeChanged: {
        if (!promptForMissionRemove && vehicleArmed) {
            promptForMissionRemove = true
        }
    }

//    Item{
//        id: cameraToggle
//        anchors.right: parent.right
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 10
//        anchors.rightMargin: 15
//        height: camIcon.height+camSwitch.height+ScreenTools.defaultFontPixelHeight*1.5
//        width: camSwitch.width+ScreenTools.defaultFontPixelWidth*2
//        z: 50
//        visible: _activeVehicle ? true : false

//        Rectangle {
//            id: cameraRect
//            anchors.fill: parent
//            color: "white"
//            border.color:   qgcPal.text
//            opacity: 0.5
//            radius: width*0.1

//            Column {
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.verticalCenter: parent.verticalCenter
//                spacing: 20

//                QGCColoredImage {
//                    id:                 camIcon
//                    width:              height
//                    height:             120
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    source:             "/qmlimages/camera_switch.png"
//                    fillMode:           Image.PreserveAspectFit
//                    color:              "black"
//                }

//                QGCSwitch {
//                    id:             camSwitch
//                    enabled:        true
//                    checked:        false
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    style: SwitchStyle {
//                            groove: Rectangle {
//                                implicitWidth: 180
//                                implicitHeight: 100
//                                border.width: 1
//                                color: camSwitch.checked ? "orange" : "#bdbebf"
//                                radius: 30
//                            }
//                            handle: Rectangle {
//                                implicitWidth: 90
//                                implicitHeight: 100
//                                radius: 30
//                            }
//                        }
//                    onCheckedChanged: {
//                        if(checked) {
//                             _activeVehicle.sendCommand(_activeVehicle,183,false,1)
//                        } else {
//                             _activeVehicle.sendCommand(_activeVehicle,183,false,0)
//                        }
//                    }
//                }
//            }
//        }
//        Timer {
//            interval: 10000; running: true; repeat: true
//            onTriggered: {
//                _activeVehicle.sendCommand(_activeVehicle,184,false,_activeVehicle.getRopeLenght())
//            }
//        }
//    }

    property real deg2rad: (3.1416/180)
    function getReachValue()
    {
        return activeVehicle.pitchRate.value>1.0?1.0:activeVehicle.pitchRate.value<0?0:activeVehicle.pitchRate.value
    }
    function getPitchValue()
    {
        return ((activeVehicle.pitch.value*deg2rad)>1.0?100:(activeVehicle.pitch.value*deg2rad)<0?0:activeVehicle.pitch.value*100*deg2rad)
    }

    Item{
        id: workspaceIndicator
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        height: 400
        width: 200
        z: 50
        visible: _activeVehicle? true : false

        Rectangle {
            id: workspaceRect
            anchors.fill: parent
            color: "white"
            border.color:   qgcPal.text
            opacity: 0.5
            radius: width*0.2

            ColumnLayout {
                id: workspaceCol
                anchors.fill: parent
                Layout.alignment:Qt.AlignHCenter

                Gauge {
                    id: reachGauge
                    anchors.top:            parent.top
                    anchors.left:           parent.left
                    anchors.leftMargin:     54
                    implicitWidth:          100
                    implicitHeight:         340
                    minimumValue:           0
                    maximumValue:           100
                    value:                  getPitchValue()
                    tickmarkStepSize:       100
                    minorTickmarkCount:     0
                    orientation:            Qt.Vertical
                    tickmarkAlignment:      Qt.AlignRight
                    style: GaugeStyle {
                        tickmark: Item {
                            visible:    false
                            implicitWidth:      0
                        }
                        tickmarkLabel: Item {
                            visible:    false
                            implicitWidth:      0
                        }
                        background: Rectangle {
                            color: "white"
                            border.color: "black"
                        }
                        valueBar: Rectangle {
                            color: getPitchValue()>90 ? "red" : "green"
                            implicitWidth: 90
                        }
                    }
                }
                Label {
                    id: distanceLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom:     parent.bottom
                    anchors.margins:    20
                    verticalAlignment:  Text.AlignVCenter
                    font.pointSize:     ScreenTools.mediumFontPointSize
                    text:               (_activeVehicle.rollRate.value)>0.2?(_activeVehicle.rollRate.value).toFixed(1)+" m":"<0.2" + " m"
                    color:              (_activeVehicle.rollRate.value)>0.2?"black":"red"
                }
            }
        }
        Rectangle {
            color: "black"
            anchors.top: parent.top
            anchors.topMargin: (20+295*(1-getReachValue()))
            anchors.horizontalCenter: parent.horizontalCenter
            width:  90
            height: 5
        }
    }

    function getRollValue() {
        if((activeVehicle.roll.value*deg2rad)>1.0)
            return 100
        else if((activeVehicle.roll.value*deg2rad)<-1.0)
            return -100
        else
            return (activeVehicle.roll.value*100*deg2rad)
    }
    function getGaugeWidth() {
        var maxSpan = Math.abs(lateralReachGauge.maximumValue) + Math.abs(lateralReachGauge.minimumValue)
        var fill = Math.abs(lateralReachGauge.value)
        var fillPercent = fill/maxSpan

        var fillWidth = lateralReachGauge.width * fillPercent
        return fillWidth - fillWidth/5
    }


    Item{
        id: rollWorkspace
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 10
        height: lateralReachGauge.height + 10
        width: lateralReachGauge.width + 20
        opacity: 0.7
        z: 50
        visible: _activeVehicle ? true : false
        Rectangle {
            color: "white"
            border.width: 1
            radius: width*0.05
            anchors.fill: parent
            Gauge {
                id:                     lateralReachGauge
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.verticalCenter:    parent.verticalCenter
                implicitWidth:          340
                implicitHeight:         50
                minimumValue:           -100
                maximumValue:           100
                value:                  getRollValue()
                tickmarkStepSize:       10
                minorTickmarkCount:     0
                orientation:            Qt.Horizontal
                style: GaugeStyle {
                    tickmark: Item {
                        visible:    false
                        implicitWidth:      0
                    }
                    tickmarkLabel: Item {
                        visible:    false
                        implicitWidth:      0
                    }
                    background: Rectangle {
                        color: "white"
                        border.color: "black"
                    }
                    valueBar:
                        Item {
                            anchors.top: parent.top
                            implicitWidth: 45
                        Rectangle {
                            color: getRollValue()>90 || getRollValue()<-90 ? "red" : "green"
                            width:          parent.width
                            implicitHeight: getGaugeWidth()
                            y: getRollValue() < 0? -height : 0
                        }
                    }
                }
            }
        }
        Rectangle {
            color: "black"
            anchors.left: parent.left
            anchors.leftMargin: lateralReachGauge.width/2+9
            anchors.verticalCenter: parent.verticalCenter
            width:  3
            height: 41
        }
    }

    Item{
        id: camera_downward
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        height: 250
        width: height
        z: 50
        visible: _activeVehicle? true : false


        Rectangle {
            id: bottomSensorRect
            anchors.fill: parent
            color: "white"
            border.color:   qgcPal.text
            opacity: 0.5
            radius: width*0.2

//            Row {
//                id: bottomSensorCol
//                anchors.bottom: parent.bottom
//                height: parent.height/2.5

//                QGCColoredImage {
//                    anchors.top:                parent.top
//                    anchors.bottom:             parent.bottom
//                    anchors.left:               bottomSensorRect.left
//                    width:                      height
//                    sourceSize.width:           width
//                    source:                     "/qmlimages/bottom_sensor.svg"
//                    fillMode:                   Image.PreserveAspectFit
//                    color:                      "black"
//    //                opacity:                    0.5
//                    rotation:                   180
//                }
//                Label {
//                    anchors.top:        parent.top
//                    anchors.bottom:     parent.bottom
//                    anchors.right:      bottomSensorRect.right
//                    verticalAlignment:  Text.AlignVCenter
//                    text:               (_activeVehicle.sensorsHealthBits-30)>20?((_activeVehicle.sensorsHealthBits-30)/100).toFixed(2):"<0.20" + " m"
//                    font.pointSize:     ScreenTools.mediumFontPointSize
//                    color:              (_activeVehicle.sensorsHealthBits-30)>100?"black":"red"
//                }
//            }
            QGCColoredImage {
                anchors.top:                parent.top
                anchors.bottom:             bottomSensorCol.top
                anchors.left:               parent.left
                anchors.right:              parent.right
                width:                      height*1.4
                sourceSize.width:           width
                source:                     "/qmlimages/CameraIcon.svg"
                fillMode:                   Image.PreserveAspectFit
                color:                      "black"
    //            opacity:                    0.5
                rotation:                   180 - (_activeVehicle.sensorsPresentBits-90)
            }
        }
    }

    property bool _lighting_visible: false
    property int sliderWidth: 500

    //-- LightingController
    Item {
        anchors.top:    parent.top
        anchors.right:    parent.right
        anchors.topMargin: 150
        anchors.rightMargin: 10
        height: 100
        width:  height
        z: 50
        visible: _activeVehicle ? true : false
        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color:   qgcPal.text
            opacity: 0.5
            radius: width*0.2
            QGCColoredImage {
                id:                 lightingIcon
                anchors.fill:       parent
                anchors.margins:    5
                sourceSize.width:   width
                source:             "/qmlimages/bulb.png"
                fillMode:           Image.PreserveAspectFit
                color:              qgcPal.text
            }
        }
        MouseArea {
            anchors.fill:   parent
            onClicked: {
                _lighting_visible = !_lighting_visible
            }
        }
    }


    Item {
        id: ligthingPopUp
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width:  parent.width - 300
        height: 400
        visible: false // change to next line to activate full LED control
        // visible: _lighting_visible && _activeVehicle ? true : false
        z: 50


        Rectangle {
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            opacity: 0.75

            Row {
                id:                 lightRow
                spacing:            ScreenTools.defaultFontPixelHeight * 5
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.fill:       parent
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 1.0

                Column {
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    anchors.verticalCenter: parent.verticalCenter
                    QGCLabel {
                        text:           qsTr("UP LEFT")
                        font.family:    ScreenTools.demiboldFontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         led1Slider
                        height:     50
                        width:      sliderWidth
                        stepSize:   0.05
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 0.65)
                            }
                        }

                        onValueChanged: _activeVehicle.sendCommand(_activeVehicle,181,false,led1Slider.value,
                                                                    led2Slider.value,led3Slider.value,led4Slider.value,led5Slider.value)
                    }
                    Rectangle {
                        opacity: 0
                        height: 100
                        width: 10
                    }

                    QGCLabel {
                        text:           qsTr("DOWN LEFT")
                        font.family:    ScreenTools.demiboldFontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         led2Slider
                        height:     50
                        width:      sliderWidth
                        stepSize:   0.05
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 0.65)
                            }
                        }

                        onValueChanged: _activeVehicle.sendCommand(_activeVehicle,181,false,led1Slider.value,
                                                                    led2Slider.value,led3Slider.value,led4Slider.value,led5Slider.value)
                    }
                }
                Column {
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    anchors.verticalCenter: parent.verticalCenter
                    QGCLabel {
                        text:           qsTr("CENTER BEAM")
                        font.family:    ScreenTools.demiboldFontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         led3Slider
                        height:     50
                        width:      sliderWidth
                        stepSize:   0.05
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 0.65)
                            }
                        }

                        onValueChanged: _activeVehicle.sendCommand(_activeVehicle,181,false,led1Slider.value,
                                                                    led2Slider.value,led3Slider.value,led4Slider.value,led5Slider.value)
                    }
                }
                Column {
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    anchors.verticalCenter: parent.verticalCenter

                    QGCLabel {
                        text:           qsTr("UP RIGHT")
                        font.family:    ScreenTools.demiboldFontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         led4Slider
                        height:     50
                        width:      sliderWidth
                        stepSize:   0.05
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 0.65)
                            }
                        }

                        onValueChanged: _activeVehicle.sendCommand(_activeVehicle,181,false,led1Slider.value,
                                                                    led2Slider.value,led3Slider.value,led4Slider.value,led5Slider.value)
                    }
                    Rectangle {
                        opacity: 0
                        height: 100
                        width: 10
                    }
                    QGCLabel {
                        text:           qsTr("DOWN RIGHT")
                        font.family:    ScreenTools.demiboldFontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         led5Slider
                        height:     50
                        width:      sliderWidth
                        stepSize:   0.05
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 0.65)
                            }
                        }

                        onValueChanged: _activeVehicle.sendCommand(_activeVehicle,181,false,led1Slider.value,
                                                                    led2Slider.value,led3Slider.value,led4Slider.value,led5Slider.value)
                    }
                }
            }
        }
    }

    Item {
        id: ligthingMinimalPopUp
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width:  parent.width / 1.5
        height: 550
        visible: _lighting_visible && _activeVehicle ? true : false
        z: 50


        Rectangle {
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            opacity: 0.75


            Column {
                anchors.horizontalCenter: parent.horizontalCenter

                QGCLabel {
                    text:           qsTr("LED POWER")
                    font.family:    ScreenTools.boldFontFamily
                    font.pointSize:         ScreenTools.largeFontPointSize
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                QGCSwitch {
                    id:             ledSwitch
                    enabled:        true
                    checked:        false
                    anchors.horizontalCenter: parent.horizontalCenter
                    style: SwitchStyle {
                            groove: Rectangle {
                                    implicitWidth: 300
                                    implicitHeight: 60
                                    border.width: 1
                                    color: ledSwitch.checked ? "orange" : "#bdbebf"
                            }
                        }
                    onCheckedChanged: {
                        if(checked) {
                            _activeVehicle.sendCommand(_activeVehicle,181,false,ambientLEDSlider.value,
                                       ambientLEDSlider.value,beamSlider.value,ambientLEDSlider.value,ambientLEDSlider.value)
                        } else {
                            _activeVehicle.sendCommand(_activeVehicle,181,false,0,0,0,0,0)
                        }
                    }
                }

                Rectangle {
                    opacity: 0
                    height: 100
                    width: 10
                }

                anchors.margins:    ScreenTools.defaultFontPixelHeight
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                anchors.verticalCenter: parent.verticalCenter
                QGCLabel {
                    text:           qsTr("LED INTENSITY")
                    font.family:    ScreenTools.boldFontFamily
                    font.pointSize:         ScreenTools.largeFontPointSize
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                QGCSlider {
                    id:         ambientLEDSlider
                    height:     80
                    width:      800
                    stepSize:   0.05
                    value:      0.5
                    orientation: Qt.Horizontal
                    style: SliderStyle {
                        handle: Rectangle {
                            anchors.centerIn:   parent
                            color:              qgcPal.button
                            border.color:       qgcPal.buttonText
                            border.width:       1
                            implicitWidth:      _radius * 2
                            implicitHeight:     _radius * 2
                            radius:             _radius

                            property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 1.5)
                        }
                        groove: Rectangle {
                            implicitWidth: 800
                            implicitHeight: 60
                            height: implicitHeight
                            radius: 20
                            color: "#bdbebf"

                            Rectangle {
                                implicitHeight: 60
                                color: ledSwitch.checked ? "orange" : "#bdbebf"
                                radius: 20
                                implicitWidth: ambientLEDSlider.value * ambientLEDSlider.width
                            }
                        }
                    }

                    onValueChanged: if(ledSwitch.checked)
                            _activeVehicle.sendCommand(_activeVehicle,181,false,ambientLEDSlider.value,
                                    ambientLEDSlider.value,beamSlider.value,ambientLEDSlider.value,ambientLEDSlider.value)
                }
                Rectangle {
                    opacity: 0
                    height: 100
                    width: 10
                }

                QGCLabel {
                    text:           qsTr("BEAM INTENSITY")
                    font.family:    ScreenTools.boldFontFamily
                    font.pointSize:         ScreenTools.largeFontPointSize
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false
                }
                QGCSlider {
                    id:         beamSlider
                    height:     80
                    width:      800
                    stepSize:   0.05
                    orientation: Qt.Horizontal
                    visible:    false
                    style: SliderStyle {
                        handle: Rectangle {
                            anchors.centerIn:   parent
                            color:              qgcPal.button
                            border.color:       qgcPal.buttonText
                            border.width:       1
                            implicitWidth:      _radius * 2
                            implicitHeight:     _radius * 2
                            radius:             _radius

                            property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 1.5)
                        }
                        groove: Rectangle {
                            implicitWidth: 800
                            implicitHeight: 60
                            height: implicitHeight
                            radius: 20
                            color: "#bdbebf"

                            Rectangle {
                                implicitHeight: 60
                                color: ledSwitch.checked ? "orange" : "#bdbebf"
                                radius: 20
                                implicitWidth: beamSlider.value * beamSlider.width
                            }
                        }
                    }

                    onValueChanged: if(ledSwitch.checked)
                            _activeVehicle.sendCommand(_activeVehicle,181,false,ambientLEDSlider.value,
                                    ambientLEDSlider.value,beamSlider.value,ambientLEDSlider.value,ambientLEDSlider.value)
                }
            }
        }
    }



//    property var    _videoReceiver:         QGroundControl.videoManager.videoReceiver
//    property bool   _recordingVideo:        _videoReceiver && _videoReceiver.recording
//    property bool   _videoRunning:          _videoReceiver && _videoReceiver.videoRunning
//    property bool   _streamingEnabled:      QGroundControl.settingsManager.videoSettings.streamConfigured

//    Rectangle {
//        width:  videoRow.width   + ScreenTools.defaultFontPixelWidth * 2
//        height: videoRow.height  + ScreenTools.defaultFontPixelHeight
//        radius: ScreenTools.defaultFontPixelHeight * 0.5
//        color:  qgcPal.window
//        border.color:   qgcPal.text
//        anchors.right: parent.right
//        anchors.bottom: parent.bottom
//        anchors.margins: ScreenTools.defaultFontPixelHeight / 2
//        z: 100


//        Row {
//            id:             videoRow
//            spacing:            ScreenTools.defaultFontPixelWidth
//            anchors.centerIn: parent

//            QGCLabel {
//               text:            _recordingVideo ? qsTr("Stop Recording") : qsTr("Record Stream")
//               visible:         QGroundControl.settingsManager.videoSettings.showRecControl.rawValue
//               anchors.verticalCenter: parent.verticalCenter
//            }
//            // Button to start/stop video recording
//            Item {
//                anchors.margins:    ScreenTools.defaultFontPixelHeight / 2
//                height:             ScreenTools.defaultFontPixelHeight * 2
//                anchors.verticalCenter: parent.verticalCenter
//                width:              height
//                Layout.alignment:   Qt.AlignHCenter
//                visible:            QGroundControl.settingsManager.videoSettings.showRecControl.rawValue
//                Rectangle {
//                    id:                 recordBtnBackground
//                    anchors.top:        parent.top
//                    anchors.bottom:     parent.bottom
//                    width:              height
//                    radius:             _recordingVideo ? 0 : height
//                    color:              (_videoRunning && _streamingEnabled) ? "red" : "gray"
//                    SequentialAnimation on opacity {
//                        running:        _recordingVideo
//                        loops:          Animation.Infinite
//                        PropertyAnimation { to: 0.5; duration: 500 }
//                        PropertyAnimation { to: 1.0; duration: 500 }
//                    }
//                }
//                QGCColoredImage {
//                    anchors.top:                parent.top
//                    anchors.bottom:             parent.bottom
//                    anchors.horizontalCenter:   parent.horizontalCenter
//                    width:                      height * 0.625
//                    sourceSize.width:           width
//                    source:                     "/qmlimages/CameraIcon.svg"
//                    visible:                    recordBtnBackground.visible
//                    fillMode:                   Image.PreserveAspectFit
//                    color:                      "white"
//                }
//                MouseArea {
//                    anchors.fill:   parent
//                    enabled:        _videoRunning && _streamingEnabled
//                    onClicked: {
//                        if (_recordingVideo) {
//                            _videoReceiver.stopRecording()
//                            // reset blinking animation
//                            recordBtnBackground.opacity = 1
//                        } else {
//                            _videoReceiver.startRecording()
//                        }
//                    }
//                }
//            }
//        }
//    }



    Component {
        id: missionCompleteDialogComponent

        QGCViewDialog {
            property var activeVehicleCopy: _activeVehicle
            onActiveVehicleCopyChanged:
                if (!activeVehicleCopy) {
                    hideDialog()
                }

            QGCFlickable {
                anchors.fill:   parent
                contentHeight:  column.height

                ColumnLayout {
                    id:                 column
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight
                        visible:            !_activeVehicle.connectionLost || !_guidedController.showResumeMission

                        QGCLabel {
                            Layout.fillWidth:       true
                            text:                   qsTr("%1 Images Taken").arg(_activeVehicle.cameraTriggerPoints.count)
                            horizontalAlignment:    Text.AlignHCenter
                            visible:                _activeVehicle.cameraTriggerPoints.count != 0
                        }

                        QGCButton {
                            Layout.fillWidth:   true
                            text:               qsTr("Remove plan from vehicle")
                            onClicked: {
                                _planMasterController.removeAllFromVehicle()
                                hideDialog()
                            }
                        }

                        QGCButton {
                            Layout.fillWidth:   true
                            Layout.alignment:   Qt.AlignHCenter
                            text:               qsTr("Leave plan on vehicle")
                            onClicked:          hideDialog()
                        }

                        Rectangle {
                            Layout.fillWidth:   true
                            color:              qgcPal.text
                            height:             1
                        }

                        QGCButton {
                            Layout.fillWidth:   true
                            Layout.alignment:   Qt.AlignHCenter
                            text:               qsTr("Resume Mission From Waypoint %1").arg(_guidedController._resumeMissionIndex)
                            visible:            _guidedController.showResumeMission

                            onClicked: {
                                guidedController.executeAction(_guidedController.actionResumeMission, null, null)
                                hideDialog()
                            }
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Resume Mission will rebuild the current mission from the last flown waypoint and upload it to the vehicle for the next flight.")
                            visible:            _guidedController.showResumeMission
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            color:              qgcPal.warningText
                            text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle when communication is lost.")
                            visible:            _guidedController.showResumeMission
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight
                        visible:            _activeVehicle.connectionLost && _guidedController.showResumeMission

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            color:              qgcPal.warningText
                            text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle.")
                        }
                    }
                }
            }
        }
    }

    Window {
        id:             videoWindow
        width:          !_mainIsMap ? _panel.width  : _pipSize
        height:         !_mainIsMap ? _panel.height : _pipSize * (9/16)
        visible:        false

        Item {
            id:             videoItem
            anchors.fill:   parent
        }

        onClosing: {
            _flightVideo.state = "unpopup"
            videoWindow.visible = false
        }
    }

    /* This timer will startVideo again after the popup window appears and is loaded.
     * Such approach was the only one to avoid a crash for windows users
     */
    Timer {
      id: videoPopUpTimer
      interval: 2000;
      running: false;
      repeat: false
      onTriggered: {
          // If state is popup, the next one will be popup-finished
          if (_flightVideo.state ==  "popup") {
            _flightVideo.state = "popup-finished"
          }
          QGroundControl.videoManager.startVideo()
      }
    }

    QGCMapPalette { id: mapPal; lightColors: _mainIsMap ? _flightMap.isSatelliteMap : true }

    QGCViewPanel {
        id:             _panel
        anchors.fill:   parent

        //-- Map View
        //   For whatever reason, if FlightDisplayViewMap is the _panel item, changing
        //   width/height has no effect.
        Item {
            id: _flightMapContainer
            z:  _mainIsMap ? _panel.z + 1 : _panel.z + 2
            anchors.left:   _panel.left
            anchors.bottom: _panel.bottom
            visible:        false
            width:          _mainIsMap ? _panel.width  : _pipSize
            height:         _mainIsMap ? _panel.height : _pipSize * (9/16)
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    0
                    }
                }
            ]
            FlightDisplayViewMap {
                id:                         _flightMap
                anchors.fill:               parent
                planMasterController:       masterController
                guidedActionsController:    _guidedController
                flightWidgets:              flightDisplayViewWidgets
                rightPanelWidth:            ScreenTools.defaultFontPixelHeight * 9
                qgcView:                    root
                multiVehicleView:           !singleVehicleView.checked
                scaleState:                 (_mainIsMap && flyViewOverlay.item) ? (flyViewOverlay.item.scaleState ? flyViewOverlay.item.scaleState : "bottomMode") : "bottomMode"
            }
        }

        //-- Video View
        Item {
            id:             _flightVideo
            z:              _mainIsMap ? _panel.z + 2 : _panel.z + 1
            width:          !_mainIsMap ? _panel.width  : _pipSize
            height:         !_mainIsMap ? _panel.height : _pipSize * (9/16)
            anchors.left:   _panel.left
            anchors.bottom: _panel.bottom
            visible:        QGroundControl.videoManager.hasVideo && (!_mainIsMap || _isPipVisible)

            onParentChanged: {
                /* If video comes back from popup
                 * correct anchors.
                 * Such thing is not possible with ParentChange.
                 */
                if(parent == _panel) {
                    // Do anchors again after popup
                    anchors.left =       _panel.left
                    anchors.bottom =     _panel.bottom
                    anchors.margins =    ScreenTools.defaultFontPixelHeight
                }
            }

            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target: _flightVideo
                        anchors.margins: ScreenTools.defaultFontPixelHeight
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: false
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target: _flightVideo
                        anchors.margins:    0
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: false
                    }
                },
                State {
                    name: "popup"
                    StateChangeScript {
                        script: {
                            // Stop video, restart it again with Timer
                            // Avoiding crashs if ParentChange is not yet done
                            QGroundControl.videoManager.stopVideo()
                            videoPopUpTimer.running = true
                        }
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: true
                    }
                },
                State {
                    name: "popup-finished"
                    ParentChange {
                        target: _flightVideo
                        parent: videoItem
                        x: 0
                        y: 0
                        width: videoItem.width
                        height: videoItem.height
                    }
                },
                State {
                    name: "unpopup"
                    StateChangeScript {
                        script: {
                            QGroundControl.videoManager.stopVideo()
                            videoPopUpTimer.running = true
                        }
                    }
                    ParentChange {
                        target: _flightVideo
                        parent: _panel
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: false
                    }
                }
            ]
            //-- Video Streaming
            FlightDisplayViewVideo {
                id:             videoStreaming
                anchors.fill:   parent
                visible:        QGroundControl.videoManager.isGStreamer
            }
            //-- UVC Video (USB Camera or Video Device)
            Loader {
                id:             cameraLoader
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.isGStreamer
                source:         QGroundControl.videoManager.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml"
            }
        }

        QGCPipable {
            id:                 _flightVideoPipControl
            z:                  _flightVideo.z + 3
            width:              _pipSize
            height:             _pipSize * (9/16)
            anchors.left:       _panel.left
            anchors.bottom:     _panel.bottom
            anchors.margins:    ScreenTools.defaultFontPixelHeight
            visible:            false
            isHidden:           !_isPipVisible
            isDark:             isBackgroundDark
            enablePopup:        _mainIsMap
            onActivated: {
                _mainIsMap = !_mainIsMap
                setStates()
            }
            onHideIt: {
                setPipVisibility(!state)
            }
            onPopup: {
                videoWindow.visible = true
                _flightVideo.state = "popup"
            }
            onNewWidth: {
                _pipSize = newWidth
            }
        }

        Row {
            id:                     singleMultiSelector
            anchors.topMargin:      ScreenTools.toolbarHeight + _margins
            anchors.rightMargin:    _margins
            anchors.right:          parent.right
            anchors.top:            parent.top
            spacing:                ScreenTools.defaultFontPixelWidth
            z:                      _panel.z + 4
            visible:                QGroundControl.multiVehicleManager.vehicles.count > 1

            ExclusiveGroup { id: multiVehicleSelectorGroup }

            QGCRadioButton {
                id:             singleVehicleView
                exclusiveGroup: multiVehicleSelectorGroup
                text:           qsTr("Single")
                checked:        true
                textColor:      mapPal.text
            }

            QGCRadioButton {
                exclusiveGroup: multiVehicleSelectorGroup
                text:           qsTr("Multi-Vehicle")
                textColor:      mapPal.text
            }
        }

        FlightDisplayViewWidgets {
            id:                 flightDisplayViewWidgets
            z:                  _panel.z + 4
            height:             ScreenTools.availableHeight - (singleMultiSelector.visible ? singleMultiSelector.height + _margins : 0)
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom
            qgcView:            root
            useLightColors:     isBackgroundDark
            missionController:  _missionController
            visible:            singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
        }

        //-------------------------------------------------------------------------
        //-- Loader helper for plugins to overlay elements over the fly view
        Loader {
            id:                 flyViewOverlay
            z:                  flightDisplayViewWidgets.z + 1
            visible:            !QGroundControl.videoManager.fullScreen
            height:             ScreenTools.availableHeight
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom

            property var qgcView: root
        }

        MultiVehicleList {
            anchors.margins:            _margins
            anchors.top:                singleMultiSelector.bottom
            anchors.right:              parent.right
            anchors.bottom:             parent.bottom
            width:                      ScreenTools.defaultFontPixelWidth * 30
            visible:                    !singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
            z:                          _panel.z + 4
            guidedActionsController:    _guidedController
        }

        //-- Virtual Joystick
        Loader {
            id:                         virtualJoystickMultiTouch
            z:                          _panel.z + 5
            width:                      parent.width  - (_flightVideoPipControl.width / 2)
            height:                     Math.min(ScreenTools.availableHeight * 0.25, ScreenTools.defaultFontPixelWidth * 16)
            visible:                    (_virtualJoystick ? _virtualJoystick.value : false) && !QGroundControl.videoManager.fullScreen && !(_activeVehicle ? _activeVehicle.highLatencyLink : false)
            anchors.bottom:             _flightVideoPipControl.top
            anchors.bottomMargin:       ScreenTools.defaultFontPixelHeight * 2
            anchors.horizontalCenter:   flightDisplayViewWidgets.horizontalCenter
            source:                     "qrc:/qml/VirtualJoystick.qml"
            active:                     (_virtualJoystick ? _virtualJoystick.value : false) && !(_activeVehicle ? _activeVehicle.highLatencyLink : false)

            property bool useLightColors: isBackgroundDark

            property Fact _virtualJoystick: QGroundControl.settingsManager.appSettings.virtualJoystick
        }

        ToolStrip {
//            visible:            (_activeVehicle ? _activeVehicle.guidedModeSupported : true) && !QGroundControl.videoManager.fullScreen
            visible:            false
            id:                 toolStrip
            anchors.leftMargin: isInstrumentRight() ? ScreenTools.defaultFontPixelWidth : undefined
            anchors.left:       isInstrumentRight() ? _panel.left : undefined
            anchors.rightMargin:isInstrumentRight() ? undefined : ScreenTools.defaultFontPixelWidth
            anchors.right:      isInstrumentRight() ? undefined : _panel.right
            anchors.topMargin:  ScreenTools.toolbarHeight + (_margins * 2)
            anchors.top:        _panel.top
            z:                  _panel.z + 4
            title:              qsTr("Fly")
            maxHeight:          (_flightVideo.visible ? _flightVideo.y : parent.height) - toolStrip.y
            buttonVisible:      [ _useChecklist, _guidedController.showTakeoff || !_guidedController.showLand, _guidedController.showLand && !_guidedController.showTakeoff, true, true, true ]
            buttonEnabled:      [ _useChecklist && _activeVehicle, _guidedController.showTakeoff, _guidedController.showLand, _guidedController.showRTL, _guidedController.showPause, _anyActionAvailable ]

            property bool _anyActionAvailable: _guidedController.showStartMission || _guidedController.showResumeMission || _guidedController.showChangeAlt || _guidedController.showLandAbort
            property var _actionModel: [
                {
                    title:      _guidedController.startMissionTitle,
                    text:       _guidedController.startMissionMessage,
                    action:     _guidedController.actionStartMission,
                    visible:    _guidedController.showStartMission
                },
                {
                    title:      _guidedController.continueMissionTitle,
                    text:       _guidedController.continueMissionMessage,
                    action:     _guidedController.actionContinueMission,
                    visible:    _guidedController.showContinueMission
                },
                {
                    title:      _guidedController.changeAltTitle,
                    text:       _guidedController.changeAltMessage,
                    action:     _guidedController.actionChangeAlt,
                    visible:    _guidedController.showChangeAlt
                },
                {
                    title:      _guidedController.landAbortTitle,
                    text:       _guidedController.landAbortMessage,
                    action:     _guidedController.actionLandAbort,
                    visible:    _guidedController.showLandAbort
                }
            ]

            model: [
                {
                    name:               "Checklist",
                    iconSource:         "/qmlimages/check.svg",
                    dropPanelComponent: checklistDropPanel
                },
                {
                    name:       _guidedController.takeoffTitle,
                    iconSource: "/res/takeoff.svg",
                    action:     _guidedController.actionTakeoff
                },
                {
                    name:       _guidedController.landTitle,
                    iconSource: "/res/land.svg",
                    action:     _guidedController.actionLand
                },
                {
                    name:       _guidedController.rtlTitle,
                    iconSource: "/res/rtl.svg",
                    action:     _guidedController.actionRTL
                },
                {
                    name:       _guidedController.pauseTitle,
                    iconSource: "/res/pause-mission.svg",
                    action:     _guidedController.actionPause
                },
                {
                    name:       qsTr("Action"),
                    iconSource: "/res/action.svg",
                    action:     -1
                }
            ]

            onClicked: {
                guidedActionsController.closeAll()
                var action = model[index].action
                if (action === -1) {
                    guidedActionList.model   = _actionModel
                    guidedActionList.visible = true
                } else {
                    _guidedController.confirmAction(action)
                }
            }
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            confirmDialog:      guidedActionConfirm
            actionList:         guidedActionList
            altitudeSlider:     _altitudeSlider
            z:                  _flightVideoPipControl.z + 1

            onShowStartMissionChanged: {
                if (showStartMission) {
                    confirmAction(actionStartMission)
                }
            }

            onShowContinueMissionChanged: {
                if (showContinueMission) {
                    confirmAction(actionContinueMission)
                }
            }

            onShowLandAbortChanged: {
                if (showLandAbort) {
                    confirmAction(actionLandAbort)
                }
            }

            /// Close all dialogs
            function closeAll() {
                mainWindow.enableToolbar()
                rootLoader.sourceComponent  = null
                guidedActionConfirm.visible = false
                guidedActionList.visible    = false
                altitudeSlider.visible      = false
            }
        }

        GuidedActionConfirm {
            id:                         guidedActionConfirm
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
            altitudeSlider:             _altitudeSlider
        }

        GuidedActionList {
            id:                         guidedActionList
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id:                 altitudeSlider
            anchors.margins:    _margins
            anchors.right:      parent.right
            anchors.topMargin:  ScreenTools.toolbarHeight + _margins
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            z:                  _guidedController.z
            radius:             ScreenTools.defaultFontPixelWidth / 2
            width:              ScreenTools.defaultFontPixelWidth * 10
            color:              qgcPal.window
            visible:            false
        }
    }

    //-- Airspace Indicator
    Rectangle {
        id:             airspaceIndicator
        width:          airspaceRow.width + (ScreenTools.defaultFontPixelWidth * 3)
        height:         airspaceRow.height * 1.25
        color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
        visible:        QGroundControl.airmapSupported && _mainIsMap && flightPermit && flightPermit !== AirspaceFlightPlanProvider.PermitNone && !messageArea.visible && !criticalMmessageArea.visible
        radius:         3
        border.width:   1
        border.color:   qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.35) : Qt.rgba(1,1,1,0.35)
        anchors.top:    parent.top
        anchors.topMargin: ScreenTools.toolbarHeight + (ScreenTools.defaultFontPixelHeight * 0.25)
        anchors.horizontalCenter: parent.horizontalCenter
        Row {
            id: airspaceRow
            spacing: ScreenTools.defaultFontPixelWidth
            anchors.centerIn: parent
            QGCLabel { text: airspaceIndicator.providerName+":"; anchors.verticalCenter: parent.verticalCenter; }
            QGCLabel {
                text: {
                    if(airspaceIndicator.flightPermit) {
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitPending)
                            return qsTr("Approval Pending")
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitAccepted || airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitNotRequired)
                            return qsTr("Flight Approved")
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitRejected)
                            return qsTr("Flight Rejected")
                    }
                    return ""
                }
                color: {
                    if(airspaceIndicator.flightPermit) {
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitPending)
                            return qgcPal.colorOrange
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitAccepted || airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitNotRequired)
                            return qgcPal.colorGreen
                    }
                    return qgcPal.colorRed
                }
                anchors.verticalCenter: parent.verticalCenter;
            }
        }
        property var  flightPermit: QGroundControl.airmapSupported ? QGroundControl.airspaceManager.flightPlan.flightPermitStatus : null
        property string  providerName: QGroundControl.airspaceManager.providerName
    }

    //-- Checklist GUI
    Component {
        id: checklistDropPanel
        PreFlightCheckList {
            model: preFlightCheckModel
        }
    }
}
