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
//-- LightingController
Item {
    id: lightingController
    anchors.top:    parent.top
    anchors.bottom:    parent.bottom
    width:          lightingControllerRow.width


    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
//    property bool _lighting_visible: false


    Component {
        id: ligthingPopUp
//        visible: _lighting_visible?true:false
        anchors.top: parent.bottom
        anchors.right: parent.right

        Rectangle {
            width:  lightRow.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: lightRow.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Row {
                id:                 lightRow
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                Column {
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    QGCLabel {
                        text:           qsTr("LED 1")
                        font.family:    ScreenTools.demiboldFontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         led1Slider
                        height:     400
                        width:      150
                        stepSize:   0.05
                        orientation: Qt.Vertical
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

                        onValueChanged: _activeVehicle.sendCommand(_activeVehicle,MAV_CMD_USER_1,false,led1Slider.value,
                                                                    led2Slider.value,led3Slider.value,led4Slider.value)
                    }
                }

            }
        }
    }

    Row {
        id:             lightingControllerRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        QGCColoredImage {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.width:   width
            source:             "/qmlimages/Battery.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
        }
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 15
            color: qgcPal.text
            opacity: 0
        }
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: qgcPal.text
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
//            _lighting_visible = !_lighting_visible
        }
    }


}
