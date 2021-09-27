// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0
import QtGraphicalEffects 1.12

Item
{
    property string icon
    property color iconColor

    width: childrenRect.width
    height: childrenRect.height

    anchors.margins: 10

    Rectangle
    {
        width: childrenRect.width
        height: childrenRect.height

        color: theme.menuButtonBackground

        Image
        {
            id: menuItemSymbol
            source: icon

            width: mainMenu.symbolSize
            height: mainMenu.symbolSize
        }

        ColorOverlay
        {
            anchors.fill: menuItemSymbol

            source: menuItemSymbol

            color: iconColor
        }
    }
}
