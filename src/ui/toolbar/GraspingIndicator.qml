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

        Gauge {
            id: graspingGauge
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth:          300
            implicitHeight:         50
            minimumValue:           0
            maximumValue:           100
            value:                  _activeVehicle.roll.value
            tickmarkStepSize:       100
            minorTickmarkCount:     0
            orientation:            Qt.Horizontal
            style: GaugeStyle {
                tickmark: Item {
                    visible: false
                }
                tickmarkLabel: Item {
                    visible: false
                }
                background: Rectangle {
                    color: "white"
                    border.color: "black"
                }
                valueBar: Rectangle {
                    color: "#F26E1C"
                    implicitWidth: 45
                }
            }
        }

        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               Math.floor(_activeVehicle.roll.value) + "%"
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              qgcPal.buttonText
        }

        QGCLabel {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            verticalAlignment:  Text.AlignVCenter
            text:               "a"
            font.pointSize:     ScreenTools.mediumFontPointSize
            color:              "transparent"
        }

        QGCColoredImage {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.height:  height
            source:             "/qmlimages/pendulum.png"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.buttonText
            visible:            _activeVehicle.pitch.value>0.5?true:false
        }

    }


}
