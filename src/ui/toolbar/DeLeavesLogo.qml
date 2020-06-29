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

    Row {
        id:             deleavesLogoRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        QGCColoredImage {
            id:                 deleavesIcon
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.width:   width
            source:             "/qmlimages/deleaves.svg"
            color:              "#F26E1A"
            fillMode:           Image.PreserveAspectFit
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

                QGCLabel {
                    text:           qsTr("Remote controller")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    id:                 deleavesController
                    width:              1000
                    height:             500
                    source:             "/qml/calibration/mode1/radioCenter.png"
                    fillMode:           Image.PreserveAspectFit
                }

                GridLayout {
                    id:                 deleavesGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("Serial number:") }
                    QGCLabel { text: "0123456789"}
                    QGCLabel { text: qsTr("Firmware version:") }
                    QGCLabel { text: "12.02.104"}
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
            mainWindow.showPopUp(deleavesAbout, centerX)
        }
    }
}
