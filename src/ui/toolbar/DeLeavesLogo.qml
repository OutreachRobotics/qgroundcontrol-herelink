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
//-- DeLeaves Logo clickable

Item {
    id:             deleavesLogo
    width:          deleavesIcon.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    anchors.left:   parent.left
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    Row {
        id:             deleavesLogoRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.left:   parent.left

        QGCColoredImage {
            id:                     deleavesIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            height:                 120
            width:                  300
            sourceSize.width:       width
            source:                 "/qmlimages/deleaves.svg"
            color:                  "#F26E1A"
            fillMode:               Image.PreserveAspectFit
        }
    }

    Component {
        id: deleavesAbout

        Rectangle {
            width:  deleavesColumn.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: deleavesColumn.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id: deleavesColumn
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(deleavesGrid.width, deleavesController.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                Image {
                    id:                 deleavesController
                    width:              1400
                    height:             600
                    source:             "/qmlimages/deleavesController.png"
                    fillMode:           Image.PreserveAspectFit
                }

                GridLayout {
                    id:                 deleavesGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("Serial number:") }
                    QGCLabel { text: " " + _activeVehicle.sensorsEnabledBits}
                    QGCLabel { text: qsTr("Firmware version:") }
                    QGCLabel { text: " " + _activeVehicle.sensorsHealthBits + "." + _activeVehicle.sensorsPresentBits + "." + Math.round(_activeVehicle.battery.current.value*100)}
                }
            }
            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX, toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }
    
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            var centerX = mapToItem(toolBar, x, y).x + (width / 2)
            mainWindow.showPopUp(deleavesAbout, centerX-70)
        }
    }
}
