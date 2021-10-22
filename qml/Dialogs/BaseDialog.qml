// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

import ".."
import "../Themes"

Dialog
{
    id: dialog

    width: 500
    height: 400

    modal: Qt.WindowModal

    property string dialogIcon

    enum DialogButtons
    {
        Ok = 1,
        Cancel = 2
    }

    property int dialogButtons: BaseDialog.DialogButtons.Ok | BaseDialog.DialogButtons.Cancel

    signal dialogAccepted
    signal dialogRejected

    background: Rectangle
    {
        color: theme.dialogWindowBackground
    }

    header: Item
    {
        width: parent.width
        height: 45

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
            text: dialog.title

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
    }

    footer: DialogButtonBox
    {
        alignment: Qt.AlignCenter

        spacing: 5

        background: theme.dialogWindowBackground

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
                close();
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
        }

        onAccepted:
        {
            dialog.dialogAccepted();
        }

        onRejected:
        {
            dialog.dialogRejected();
        }
    }
}
