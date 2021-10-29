// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.1
import QtGraphicalEffects 1.12

import ".."
import "../Themes"

Item
{
    id: viewItem

    width: 500
    height: 400

    visible: false

    property string title

    property bool resizable: true

    property Item header
    property Item contentItem
    property Item footer

    property string dialogIcon

    enum DialogButtons
    {
        Ok = 1,
        Cancel = 2
    }

    property int dialogButtons: BaseDialog.DialogButtons.Ok | BaseDialog.DialogButtons.Cancel

    signal accepted
    signal rejected

    function open()
    {
        visible = true;
    }

    function close()
    {
        visible = false;
    }

    onContentItemChanged:
    {
        if (contentItem !== null)
        {
            contentItem.parent = contentData;
            contentItem.anchors.fill = contentData;
            contentItem.anchors.margins = 10;
        }
    }

    Component.onCompleted:
    {
        header.parent = contentHeader;
        footer.parent = contentFooter;
    }

    Window
    {
        id: window

        title: viewItem.title

        visible: viewItem.visible

        flags: Qt.Dialog | Qt.FramelessWindowHint

        Rectangle
        {
            anchors.fill: parent

            color: theme.dialogWindowBackground
            border.color: theme.dialogWindowBorderColor

            ColumnLayout
            {
                anchors.fill: parent

                Item
                {
                    id: contentHeader

                    height: 45

                    Layout.fillWidth: true
                }

                Item
                {
                    id: contentData

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Item
                {
                    id: contentFooter

                    height: 55

                    Layout.fillWidth: true

                    activeFocusOnTab: true
                }
            }
        }

        onVisibleChanged:
        {
            viewItem.visible = visible;
        }

        Component.onCompleted:
        {
            width = viewItem.width;
            height = viewItem.height;

            if (!viewItem.resizable)
            {
                minimumWidth = width;
                maximumWidth = width;

                minimumHeight = height;
                maximumHeight = height;
            }
        }

        MouseArea
        {
            id : resizearea

            width: 5
            height: 5

            anchors.bottom: parent.bottom
            anchors.right: parent.right

            cursorShape: viewItem.resizable ? Qt.SizeFDiagCursor : Qt.ArrowCursor

            acceptedButtons: Qt.LeftButton

            pressAndHoldInterval: 100

            onPressAndHold:
            {
                window.startSystemResize(Qt.BottomEdge | Qt.RightEdge);
            }
        }
    }

    header: Item
    {
        width: parent.width
        height: 45

        anchors.fill: parent

        Rectangle
        {
            anchors.fill: parent

            color: theme.dialogWindowTitleBackground
        }

        Rectangle
        {
            width: childrenRect.width
            height: childrenRect.height

            x: 10
            y: 13

            color: theme.dialogWindowTitleBackground

            Image
            {
                id: dialogTitleSymbol
                source: dialogIcon

                width: 20
                height: 20
            }

            ColorOverlay
            {
                anchors.fill: dialogTitleSymbol

                source: dialogTitleSymbol

                color: theme.dialogWindowTitleColor
            }
        }

        Label
        {
            text: viewItem.title

            font.bold: true
            font.pixelSize: 16

            color: theme.dialogWindowTitleColor

            x: 38
            y: 10

            background: Rectangle
            {
                color: theme.dialogWindowTitleBackground
            }
        }

        MouseArea
        {
            anchors.fill: parent

            property real lastMouseX: 0
            property real lastMouseY: 0

            onPressed:
            {
                lastMouseX = mouseX;
                lastMouseY = mouseY;
            }

            onMouseXChanged: window.x += (mouseX - lastMouseX)
            onMouseYChanged: window.y += (mouseY - lastMouseY)
        }
    }

    footer: DialogButtonBox
    {
        alignment: Qt.AlignCenter

        anchors.fill: parent

        spacing: 5

        RoundButton
        {
            id: okButton

            visible: (dialogButtons & BaseDialog.DialogButtons.Ok) !== 0

            width: visible ? 100 : 0

            text: qsTr("Ok")

            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            contentItem: Text
            {
                text: okButton.text
                color: theme.dialogButtonTextColor
                horizontalAlignment: Text.AlignHCenter
            }

            background: Rectangle
            {
                radius: theme.buttonRoundness
                color: theme.dialogButtonBackground
            }

            MouseArea
            {
                anchors.fill: parent

                hoverEnabled: true

                onEntered:
                {
                    okButton.contentItem.color = theme.dialogButtonHighlighted;
                }

                onExited:
                {
                    okButton.contentItem.color = theme.dialogButtonTextColor;
                }

                onClicked:
                {
                    okButton.clicked();
                }
            }

            onClicked:
            {
                viewItem.close();
            }
        }

        RoundButton
        {
            id: cancelButton

            visible: (dialogButtons & BaseDialog.DialogButtons.Cancel) !== 0

            width: visible ? 100 : 0

            text: qsTr("Cancel")

            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            contentItem: Text
            {
                text: cancelButton.text
                color: theme.dialogButtonTextColor
                horizontalAlignment: Text.AlignHCenter
            }

            background: Rectangle
            {
                radius: theme.buttonRoundness
                color: theme.dialogButtonBackground
            }

            MouseArea
            {
                anchors.fill: parent

                hoverEnabled: true

                onEntered:
                {
                    cancelButton.contentItem.color = theme.dialogButtonHighlighted;
                }

                onExited:
                {
                    cancelButton.contentItem.color = theme.dialogButtonTextColor;
                }

                onClicked:
                {
                    cancelButton.clicked();
                }
            }

            onClicked:
            {
                viewItem.close();
            }
        }

        onAccepted:
        {
            viewItem.accepted();
        }

        onRejected:
        {
            viewItem.rejected();
        }
    }
}
