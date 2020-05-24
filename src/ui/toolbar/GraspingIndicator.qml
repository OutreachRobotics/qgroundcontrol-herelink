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
import QtQuick.Controls.Styles 1.4

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
    anchors.topMargin:      7
    visible:        true
    width:          1000

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle


    Row {
        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               "Cut "
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              qgcPal.buttonText
        }
        ProgressBar {
            value: _activeVehicle.roll.value/100
            style: ProgressBarStyle {
                    background: Rectangle {
                        radius: 2
                        color: "lightgray"
                        border.color: "gray"
                        border.width: 1
                        implicitWidth: 300
                        implicitHeight: 50
                    }
                    progress: Rectangle {
                        color: "forestgreen"
                        border.color: "forestgreen"
                    }
                }
        }

        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               " " + Math.floor(_activeVehicle.roll.value) + "%"
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              qgcPal.buttonText
        }

    }


}
