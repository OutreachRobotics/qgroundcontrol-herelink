/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2
import QtQuick.Window           2.2
import QtQml.Models             2.1
import QtMultimedia             5.5

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0


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
        id:                     mambaLogo
        anchors.bottomMargin:   1
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        anchors.fill:           parent
        spacing:                ScreenTools.defaultFontPixelWidth * 2

        Row {
            id:             mambaLogoRow
            Layout.fillHeight:  true
            spacing:            ScreenTools.defaultFontPixelWidth / 2

            Image {
                id:                     mambaIcon
                anchors.verticalCenter: parent.verticalCenter
                height:                 100
                width:                  100
                sourceSize.width:       width
                source:                 "/qmlimages/outreach_logo.png"
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
                color:                  buttonClicked ? "#000000" : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                height:                 100
                width:                  100

                QGCColoredImage {
                    id:                     hamburgerIcon
                    anchors.fill:           parent
                    sourceSize.width:       width
                    source:                 "qrc:/qmlimages/Hamburger.svg"
                    color:                  buttonClicked ? "transparent" : "#000000"
                    fillMode:               Image.PreserveAspectFit

                }

                MouseArea {
                    anchors.fill:   parent
                    onClicked: {
                        var centerX = mapToItem(toolBar, x, y).x
                        mainWindow.showPopUp(hamburgerMenu, centerX)
                    }
                }
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

            QGCLabel {
                id:                     waitForVehicle
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 4
                text:                   qsTr("Waiting For Mamba Connection")
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
            id: mambaAbout

            Rectangle {
                width:  mambaAboutColumn.width   + ScreenTools.defaultFontPixelWidth  * 3
                height: mambaAboutColumn.height  + ScreenTools.defaultFontPixelHeight * 2
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text

                Column {
                    id:                 mambaAboutColumn
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    width:              mambaGrid.width + ScreenTools.defaultFontPixelWidth  * 2
                    height:             mambaGrid.height + mambaAboutLogo.height + mambaWebsite.height + ScreenTools.defaultFontPixelHeight
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent

                    Image {
                        id:                    mambaAboutLogo
                        width:                 600
                        anchors.horizontalCenter: parent.horizontalCenter
                        source:                 "/qmlimages/outreach_logo_horz.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                   GridLayout {
                        id:                 mambaGrid
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        columnSpacing:      ScreenTools.defaultFontPixelWidth
                        columns:            2

                        QGCLabel {
                            text: qsTr("Herelink Serial Number:")
                            verticalAlignment: Text.AlignVCenter
                        }
                        QGCLabel {
                            text: "HX4060751300310"
                            verticalAlignment: Text.AlignVCenter
                        }
                        QGCLabel {
                            text: qsTr("Herelink Ground Station Version:")
                            verticalAlignment: Text.AlignVCenter
                        }
                        QGCLabel {
                            text: "3.0.0"
                            verticalAlignment: Text.AlignVCenter
                        }

                        QGCLabel {
                            text: qsTr("Mamba Serial Number:")
                            verticalAlignment: Text.AlignVCenter
                        }
                        QGCLabel {
                            text: _activeVehicle? " " + "555555555" : " Not Connected"
                            verticalAlignment: Text.AlignVCenter
                        }
                        QGCLabel {
                            text: qsTr("Mamba Firmware Version:")
                            verticalAlignment: Text.AlignVCenter
                        }
                        QGCLabel {
                            text: _activeVehicle ? " 3.0.0" : " Not Connected"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    QGCLabel {
                       id:                     mambaWebsite
                       text:                   "www.outreachrobotics.com"
                       anchors.horizontalCenter: parent.horizontalCenter
                       font.pointSize:         ScreenTools.mediumFontPointSize
                       font.family:            ScreenTools.demiboldFontFamily
                       color:                  qgcPal.text
                    }
                }


                Component.onCompleted: {
                    var pos = mapFromItem(toolBar, centerX, toolBar.height)
                    x = pos.x
                    y = pos.y + ScreenTools.defaultFontPixelHeight
                }
            }
        }

        property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 0.65)

        Component {
            id: mambaParameters
            // Parameter sent in flightDisplayView with a 10 sec timer
            Rectangle {
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text
                opacity: 0.75
                width:  ropeLengthSlider.width + ScreenTools.defaultFontPixelWidth*4
                height: 780

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    anchors.verticalCenter: parent.verticalCenter

                    QGCLabel {
                        text:           qsTr("ROPE LENGTH")
                        font.family:    ScreenTools.boldFontFamily
                        font.pointSize:         ScreenTools.largeFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         ropeLengthSlider
                        height:     80
                        width:      800
                        value:     ( _activeVehicle.getRopeLenght()-5)/15
                        stepSize:   0.3333
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 1.5)
                            }
                            groove: Rectangle {
                                implicitWidth: 800
                                implicitHeight: 60
                                height: implicitHeight
                                radius: 20
                                color: "#bdbebf"

                                Rectangle {
                                    implicitHeight: 60
                                    color: "orange"
                                    radius: 20
                                    implicitWidth: ropeLengthSlider.value * ropeLengthSlider.width
                                }
                            }
                        }
                        onValueChanged: _activeVehicle.setRopeLenght((ropeLengthSlider.value*15+5).toFixed(0))
                    }

                    QGCLabel {
                        text:           (ropeLengthSlider.value*15+5).toFixed(0) + " m"
                        font.family:    ScreenTools.boldFontFamily
                        font.pointSize:         ScreenTools.largeFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        opacity: 0
                        height: 100
                        width: 10
                    }

                    QGCLabel {
                        text:           qsTr("PARAM2")
                        font.family:    ScreenTools.boldFontFamily
                        font.pointSize:         ScreenTools.largeFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCSlider {
                        id:         param2Slider
                        height:     80
                        width:      800
                        stepSize:   0.05
                        orientation: Qt.Horizontal
                        style: SliderStyle {
                            handle: Rectangle {
                                anchors.centerIn:   parent
                                color:              qgcPal.button
                                border.color:       qgcPal.buttonText
                                border.width:       1
                                implicitWidth:      _radius * 2
                                implicitHeight:     _radius * 2
                                radius:             _radius

                                property real _radius: Math.round(ScreenTools.defaultFontPixelHeight * 1.5)
                            }
                            groove: Rectangle {
                                implicitWidth: 800
                                implicitHeight: 60
                                height: implicitHeight
                                radius: 20
                                color: "#bdbebf"

                                Rectangle {
                                    implicitHeight: 60
                                    color: "orange"
                                    radius: 20
                                    implicitWidth: param2Slider.value * param2Slider.width
                                }
                            }
                        }

//                        onValueChanged:
                    }
                    QGCLabel {
                        text:           (param2Slider.value*100).toFixed(0)
                        font.family:    ScreenTools.boldFontFamily
                        font.pointSize:         ScreenTools.largeFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
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
            id: mambaController

            Rectangle {
                width:  mambaControllerImage.width   + ScreenTools.defaultFontPixelWidth  * 3
                height: mambaControllerImage.height  + ScreenTools.defaultFontPixelHeight * 2
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text

                Image {
                    id:                 mambaControllerImage
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
            id: hamburgerMenu

            Rectangle {
                width:  hamburgerMenuCol.width   + ScreenTools.defaultFontPixelWidth  * 6
                height: hamburgerMenuCol.height  + ScreenTools.defaultFontPixelHeight
                radius: ScreenTools.defaultFontPixelHeight * 0.5
                color:  qgcPal.window
                border.color:   qgcPal.text

                Column {
                    id: hamburgerMenuCol
                    spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                    width:              mambaControllerMenu.width
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent

                    QGCLabel {
                        id:                     mambaControllerMenu
                        height:                 ScreenTools.defaultFontPixelHeight * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:                   qsTr("Controller Configuration")
                        font.pointSize:         ScreenTools.mediumFontPointSize
                        font.family:            ScreenTools.demiboldFontFamily
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill:   parent
                            onClicked: {
                                mainWindow.showPopUp(mambaController, 30)
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
                        id:                     aboutMenu
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
                                mainWindow.showPopUp(mambaAbout, centerX)
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
                        id:                     parametersMenu
                        text:                   qsTr("Parameters")
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
                                mainWindow.showPopUp(mambaParameters, centerX)
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
        visible:                false
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
        onVisibleChanged:   _activeVehicle.disconnectInactiveVehicle()

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
