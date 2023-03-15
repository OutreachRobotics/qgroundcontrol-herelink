/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.4
import QtQuick.Layouts  1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Grasping Indicator
Item {
    id: graspingItem
    anchors.top:    parent.top
    anchors.bottom:    parent.bottom
    visible:        true
    width:          graspingRow.width

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle


    Row {
        id:             graspingRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: qgcPal.text
        }
        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }

        QGCColoredImage {
            id:                 shearsIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/shears.png"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color:              "black"
        }

        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               Math.floor(_activeVehicle.sensorsPresentBits) + "%"
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              qgcPal.buttonText
        }

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: qgcPal.text
        }

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }

        QGCColoredImage {
            id:                 taxiIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/taxi.svg"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color:              "black"
            visible:            _activeVehicle.sensorsEnabledBits ? true : false
        }

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }

        QGCColoredImage {
            id:                 wristIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/robot_wrist.png"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color:              "black"
            visible:            _activeVehicle.sensorsHealthBits ? true : false
        }


    }


}
