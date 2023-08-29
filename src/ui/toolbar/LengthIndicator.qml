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
//-- Lenght Indicator
Item {
    id: lengthItem
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    visible:        true
    width:          lengthRow.width

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property double _atitude_offset: 0.0

    Row {
        id:             lengthRow
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

        QGCColoredImage {
            id:                 lengthIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/length.png"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color: "black"
        }
        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               (_activeVehicle.altitudeRelative.value.toFixed(1) + " m")
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              qgcPal.buttonText
        }
    }
    MouseArea {
        anchors.fill:   lengthRow
        onDoubleClicked:      _activeVehicle.sendCommand(_activeVehicle, 182, false, 0)
    }

}
