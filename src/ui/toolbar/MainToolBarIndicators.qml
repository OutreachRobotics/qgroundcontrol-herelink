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
import QtQuick.Dialogs  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Item {
    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _communicationLost:   _activeVehicle ? _activeVehicle.connectionLost : false

    QGCPalette { id: qgcPal }

    // Easter egg mechanism
    MouseArea {
        anchors.fill: parent
        onClicked: {
            _clickCount++
            eggTimer.restart()
            if (_clickCount == 5 && !QGroundControl.corePlugin.showAdvancedUI) {
                advancedModeConfirmation.visible = true
            } else if (_clickCount == 7) {
                QGroundControl.corePlugin.showTouchAreas = true
            }
        }

        property int _clickCount: 0

        Timer {
            id:             eggTimer
            interval:       1000
            onTriggered:    parent._clickCount = 0
        }

        MessageDialog {
            id:                 advancedModeConfirmation
            title:              qsTr("Advanced Mode")
            text:               QGroundControl.corePlugin.showAdvancedUIMessage
            standardButtons:    StandardButton.Yes | StandardButton.No

            onYes: {
                QGroundControl.corePlugin.showAdvancedUI = true
                visible = false
            }
        }
    }

    property bool buttonClicked: false

    RowLayout {
        id:                     deleavesLogo
        anchors.bottomMargin:   1
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        anchors.fill:           parent
        spacing:                ScreenTools.defaultFontPixelWidth * 2

        Row {
            id:             deleavesLogoRow
            Layout.fillHeight:  true
            spacing:            ScreenTools.defaultFontPixelWidth / 2

            QGCColoredImage {
                id:                     deleavesIcon
                anchors.verticalCenter: parent.verticalCenter
                height:                 120
                width:                  120
                sourceSize.width:       width
                source:                 "/qmlimages/deleaves.svg"
                color:                  "#F26E1A"
                fillMode:               Image.PreserveAspectFit
            }

            Rectangle {
                width: ScreenTools.defaultFontPixelWidth
                height: 10
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                opacity: 0
            }

            Rectangle {
                color:                  buttonClicked ? "#F26E1A" : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                height:                 100
                width:                  100

                QGCColoredImage {
                    id:                     hamburgerIcon
                    anchors.fill:           parent
                    sourceSize.width:       width
                    source:                 "qrc:/qmlimages/Hamburger.svg"
                    color:                  buttonClicked ? "transparent" : "#F26E1A"
                    fillMode:               Image.PreserveAspectFit

                }

                MouseArea {
                    anchors.fill:   parent
                    onClicked: {
                        var centerX = mapToItem(toolBar, x, y).x
                        mainWindow.showPopUp(deleavesMenu, centerX)
                    }
                }
            }

            Rectangle {
                width: ScreenTools.defaultFontPixelWidth * 6
                height: 10
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                opacity: 0
            }

            QGCLabel {
                id:                     waitForVehicle
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 4
                text:                   qsTr("Waiting For DeLeaves Sampling Tool Connection")
                font.pointSize:         ScreenTools.mediumFontPointSize
                font.family:            ScreenTools.demiboldFontFamily
                color:                  qgcPal.colorRed
                visible:                !_activeVehicle
            }

            Repeater {
                model:      _activeVehicle ? _activeVehicle.toolBarIndicators : []
                Loader {
                    anchors.top:    parent.top
                    anchors.bottom: parent.bottom
                    source:         modelData;
                    visible:        _activeVehicle && !_communicationLost
                }
            }
        }

        Component {
            id: deleavesAbout

            Rectangle {
                width:  deleavesGrid.width   + ScreenTools.defaultFontPixelWidth  * 3
                height: deleavesGrid.height  + ScreenTools.defaultFontPixelHeight * 2
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text

                GridLayout {
                    id:                 deleavesGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel {
                        text: qsTr("Herelink Serial Number:")
                        verticalAlignment: Text.AlignVCenter
                    }
                    QGCLabel {
                        text: "HX4060759500366"
                        verticalAlignment: Text.AlignVCenter
                    }
                    QGCLabel {
                        text: qsTr("Herelink Ground Station Version:")
                        verticalAlignment: Text.AlignVCenter
                    }
                    QGCLabel {
                        text: "1.0.12"
                        verticalAlignment: Text.AlignVCenter
                    }

                    QGCLabel {
                        text: qsTr("DeLeaves Serial Number:")
                        verticalAlignment: Text.AlignVCenter
                    }
                    QGCLabel {
                        text: _activeVehicle? " " + _activeVehicle.sensorsEnabledBits : "Not Connected"
                        verticalAlignment: Text.AlignVCenter
                    }
                    QGCLabel {
                        text: qsTr("DeLeaves Firmware Version:")
                        verticalAlignment: Text.AlignVCenter
                    }
                    QGCLabel {
                        text: _activeVehicle ? " " + _activeVehicle.sensorsHealthBits + "." + _activeVehicle.sensorsPresentBits + "." + Math.round(_activeVehicle.battery.current.value*100) : "Not Connected"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Component.onCompleted: {
                    var pos = mapFromItem(toolBar, centerX, toolBar.height)
                    x = pos.x
                    y = pos.y + ScreenTools.defaultFontPixelHeight
                }
            }
        }

        Component {
            id: deleavesController

            Rectangle {
                width:  deleavesControllerImage.width   + ScreenTools.defaultFontPixelWidth  * 3
                height: deleavesControllerImage.height  + ScreenTools.defaultFontPixelHeight * 2
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text

                Image {
                    id:                 deleavesControllerImage
                    anchors.centerIn:   parent
                    width:              1645
                    height:             720
                    source:             "/qmlimages/deleavesController.png"
                    fillMode:           Image.PreserveAspectFit
                }

                Component.onCompleted: {
                    var pos = mapFromItem(toolBar, centerX, toolBar.height)
                    x = pos.x
                    y = pos.y + ScreenTools.defaultFontPixelHeight
                }
            }
        }

        Component {
            id: deleavesMenu

            Rectangle {
                width:  deleavesMenuColumn.width   + ScreenTools.defaultFontPixelWidth  * 6
                height: deleavesMenuColumn.height  + ScreenTools.defaultFontPixelHeight
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text

                Column {
                    id: deleavesMenuColumn
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    width:              deleavesControllerMenu.width
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent

                    QGCLabel {
                        id:                     deleavesControllerMenu
                        height:                 ScreenTools.defaultFontPixelHeight * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:                   qsTr("Controller Configuration")
                        font.pointSize:         ScreenTools.mediumFontPointSize
                        font.family:            ScreenTools.demiboldFontFamily
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill:   parent
                            onClicked: {
                                mainWindow.showPopUp(deleavesController, 30)
                            }
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width + ScreenTools.defaultFontPixelWidth * 6
                        height: 2
                        color: qgcPal.text
                    }

                    QGCLabel {
                        id:                     deleavesAboutMenu
                        text:                   qsTr("About")
                        width:                  parent.width
                        height:                 ScreenTools.defaultFontPixelHeight * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize:         ScreenTools.mediumFontPointSize
                        font.family:            ScreenTools.demiboldFontFamily
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill:   parent
                            onClicked: {
                                var centerX = mapToItem(toolBar, x, y).x  + (width / 2)
                                mainWindow.showPopUp(deleavesAbout, centerX)
                            }
                        }
                   }
                }
                Component.onCompleted: {
                    var pos = mapFromItem(toolBar, centerX, toolBar.height)
                    x = pos.x
                    y = pos.y + ScreenTools.defaultFontPixelHeight
                    buttonClicked = true
                }
                Component.onDestruction: {
                    buttonClicked = false
                }
            }
        }
    }


    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        visible:                x > indicatorRow.width && !_communicationLost
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      _userBrandingIndoor ?
                                                    _userBrandImageIndoor : (_userBrandingOutdoor ?
                                                        _userBrandImageOutdoor : (_corePluginBranding ?
                                                            QGroundControl.corePlugin.brandImageIndoor : (_activeVehicle ?
                                                                _activeVehicle.brandImageIndoor : ""
                                                            )
                                                        )
                                                    )
        property string _brandImageOutdoor:     _userBrandingOutdoor ?
                                                    _userBrandImageOutdoor : (_userBrandingIndoor ?
                                                        _userBrandImageIndoor : (_corePluginBranding ?
                                                            QGroundControl.corePlugin.brandImageOutdoor : (_activeVehicle ?
                                                                _activeVehicle.brandImageOutdoor : ""
                                                            )
                                                        )
                                                    )
    }

    Row {
        anchors.fill:       parent
        layoutDirection:    Qt.RightToLeft
        spacing:            ScreenTools.defaultFontPixelWidth
        visible:            _communicationLost

        QGCButton {
            id:                     disconnectButton
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("Disconnect")
            primary:                true
            onClicked:              _activeVehicle.disconnectInactiveVehicle()
        }

        QGCLabel {
            id:                     connectionLost
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("COMMUNICATION LOST")
            font.pointSize:         ScreenTools.largeFontPointSize
            font.family:            ScreenTools.demiboldFontFamily
            color:                  qgcPal.colorRed
        }
    }
}
