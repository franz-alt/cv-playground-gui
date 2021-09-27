// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Item
{
    id: menuItem

    property string icon
    property string text
    property string toolTip

    property bool disabled: false

    signal pressed

    width: parent.width
    height: childrenRect.height

    Layout.minimumHeight: symbolSize
    Layout.preferredHeight: symbolSize
    Layout.maximumHeight: symbolSize

    ToolTip.delay: 1000
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.text: toolTip

    MenuSymbol
    {
        id: menuSymbol

        icon: menuItem.icon

        iconColor:
        {
            if (menuItem.disabled)
            {
                return theme.menuButtonDisabled;
            }
            else
            {
                return theme.menuButtonForeground;
            }
        }

        MouseArea
        {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            {
                if (menuItem.disabled)
                {
                    menuSymbol.iconColor = theme.menuButtonDisabled;
                }
                else
                {
                    menuSymbol.iconColor = theme.menuButtonHighlighted;
                }
            }

            onExited:
            {
                if (menuItem.disabled)
                {
                    menuSymbol.iconColor = theme.menuButtonDisabled;
                }
                else
                {
                    menuSymbol.iconColor = theme.menuButtonForeground;
                }
            }

            onClicked:
            {
                if (!menuItem.disabled)
                {
                    menuItem.pressed();
                }
            }
        }
    }
}
