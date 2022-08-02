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

    function getAngleValue() {
        return Math.atan2(_activeVehicle.sensorsPresentBits-_activeVehicle.sensorsEnabledBits,27.5)
    }

    function getDistanceValue(){
        return (_activeVehicle.sensorsPresentBits*Math.cos(getAngleValue()) + _activeVehicle.sensorsEnabledBits*Math.cos(getAngleValue())) / 2 - 22
    }

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
            id:                 distIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/distance.png"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color:              "black"
        }

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }

        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               Math.floor(getDistanceValue())>300 ? "300" : Math.floor(getDistanceValue())<0?0:Math.floor(getDistanceValue()) + "cm"
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              qgcPal.buttonText
            opacity:            Math.floor(getDistanceValue())>300 ? 0.5 : 1
        }

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }
//        Rectangle {
//            anchors.top: parent.top
//            anchors.bottom: parent.bottom
//            width: 1
//            color: qgcPal.text
//        }

//        Rectangle {
//            width: ScreenTools.defaultFontPixelWidth
//            height: 10
//            anchors.verticalCenter: parent.verticalCenter
//            color: "white"
//            opacity: 0
//        }

//        QGCColoredImage {
//            id:                 angleIcon
//            width:              height
//            anchors.top:        parent.top
//            anchors.bottom:     parent.bottom
//            source:             "/qmlimages/angle.png"
//            fillMode:           Image.PreserveAspectFit
//            sourceSize.height:  height
//            color:              "black"
//        }

//        Rectangle {
//            width: ScreenTools.defaultFontPixelWidth
//            height: 10
//            anchors.verticalCenter: parent.verticalCenter
//            color: "white"
//            opacity: 0
//        }

//        QGCLabel {
//            anchors.top:        parent.top
//            anchors.bottom:     parent.bottom
//            verticalAlignment:  Text.AlignVCenter
//            text:               Math.floor(getAngleValue()*180/3.1416) + "°"
//            font.pointSize:     ScreenTools.mediumFontPointSize
//            color:              qgcPal.buttonText
//            QGCPalette { id: qgcPal }
//            opacity:            Math.floor(getDistanceValue())>300 ? 0.5 : 1

//        }

//        Rectangle {
//            width: ScreenTools.defaultFontPixelWidth*2
//            height: 10
//            anchors.verticalCenter: parent.verticalCenter
//            color: "white"
//            opacity: 0
//        }

        QGCColoredImage {
            id:                 taxiIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/taxi.svg"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color: "black"
            visible:            _activeVehicle.sensorsHealthBits ? true : false
        }

        Rectangle {
            width: ScreenTools.defaultFontPixelWidth*2
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            opacity: 0
        }
    }

}
