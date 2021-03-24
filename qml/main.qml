import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import Cutefish.StatusBar 1.0
import Cyber.NetworkManagement 1.0 as NM
import MeuiKit 1.0 as Meui

Item {
    id: rootItem

    Rectangle {
        id: background
        anchors.fill: parent
        color: Meui.Theme.backgroundColor
        opacity: 0.6
    }

    Meui.PopupTips {
        id: popupTips
        backgroundColor: Meui.Theme.backgroundColor
        backgroundOpacity: Meui.Theme.darkMode ? 0.3 : 0.4
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Meui.Units.smallSpacing
        anchors.rightMargin: Meui.Units.smallSpacing

        Item {
            Layout.fillWidth: true
        }

        ListView {
            id: trayView

            orientation: Qt.Horizontal
            layoutDirection: Qt.RightToLeft
            interactive: false
            clip: true
            spacing: 0

            property var itemSize: rootItem.height * 0.8
            property var itemWidth: itemSize + Meui.Units.largeSpacing

            Layout.fillHeight: true
            Layout.preferredWidth: itemWidth * count

            model: SystemTrayModel {
                id: trayModel
            }

            delegate: StandardItem {
                width: trayView.itemWidth
                height: ListView.view.height

                Image {
                    anchors.centerIn: parent
                    width: parent.height * 0.7
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: model.iconName ? "image://icontheme/" + model.iconName : ""
                }

                onClicked: trayModel.leftButtonClick(model.id)
                onRightClicked: trayModel.rightButtonClick(model.id)
                popupText: model.toolTip ? model.toolTip : model.title
            }
        }

        StandardItem {
            id: controler

            Layout.fillHeight: true
            Layout.preferredWidth: _controlerLayout.implicitWidth

            onClicked: {
                if (controlDialog.visible)
                    controlDialog.visible = false
                else {
                    // 先初始化，用户可能会通过Alt鼠标左键移动位置
                    controlDialog.position = Qt.point(0, 0)
                    controlDialog.visible = true
                    controlDialog.position = Qt.point(mapToGlobal(0, 0).x, mapToGlobal(0, 0).y)
                }
            }

            RowLayout {
                id: _controlerLayout
                anchors.fill: parent

                spacing: Meui.Units.largeSpacing

                Image {
                    id: volumeIcon
                    visible: volume.isValid && status === Image.Ready
                    source: "qrc:/images/" + (Meui.Theme.darkMode ? "dark/" : "light/") + volume.iconName + ".svg"
                    width: 16
                    height: width
                    sourceSize: Qt.size(width, height)
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }

                Image {
                    id: wirelessIcon
                    width: 16
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: network.wirelessIconName ? "qrc:/images/" + (Meui.Theme.darkMode ? "dark/" : "light/") + network.wirelessIconName + ".svg" : ""
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    visible: network.enabled &&
                             network.wirelessEnabled &&
                             network.wirelessConnectionName !== "" &&
                             wirelessIcon.status === Image.Ready
                }

                Image {
                    id: batteryIcon
                    visible: battery.available && status === Image.Ready
                    height: 16
                    width: height + 6
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (Meui.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    Layout.alignment: Qt.AlignCenter
                    asynchronous: true
                }

                Label {
                    id: timeLabel
                    Layout.alignment: Qt.AlignCenter
                    font.pixelSize: rootItem.height * 0.5

                    Timer {
                        interval: 1000
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: {
                            timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        }
                    }
                }
            }
        }
    }

    // Components
    ControlDialog {
        id: controlDialog
    }

    Volume {
        id: volume
    }

    Battery {
        id: battery
    }

    NM.ConnectionIcon {
        id: connectionIconProvider
    }

    NM.Network {
        id: network
    }
}