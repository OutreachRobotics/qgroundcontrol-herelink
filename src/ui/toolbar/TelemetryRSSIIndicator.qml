/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Telemetry RSSI
Item {
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          _hasTelemetry ? batteryIndicatorRow.width * 1.1 : 0
    visible:        _hasTelemetry

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _hasTelemetry:    _activeVehicle ? _activeVehicle.telemetryLRSSI !== 0 : false

    function getSignalStrengthURL() {
        if(_activeVehicle.telemetryLRSSI<70)
            return "/qmlimages/Signal100.svg"
        else if(_activeVehicle.telemetryLRSSI<80)
            return "/qmlimages/Signal80.svg"
        else if(_activeVehicle.telemetryLRSSI<90)
            return "/qmlimages/Signal60.svg"
        else if(_activeVehicle.telemetryLRSSI<100)
            return "/qmlimages/Signal40.svg"
        else if(_activeVehicle.telemetryLRSSI<110)
            return "/qmlimages/Signal20.svg"
        else
            return "/qmlimages/Signal0.svg"
    }

    function getSignalStrengthColor() {
        if(_activeVehicle.telemetryLRSSI<100)
            return qgcPal.text
        else
            return "red"
    }

    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }

        QGCColoredImage {
            id:                 telemIcon
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.height:  height
            source:             "/qmlimages/RC.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
        }

        QGCColoredImage {
            id:                 telemSignal
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.height:  height
            source:             getSignalStrengthURL()
            fillMode:           Image.PreserveAspectFit
            color:              getSignalStrengthColor()
        }

    }
}
