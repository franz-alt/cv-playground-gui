// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0

Item
{
    id: menuSeparator

    width: parent.width
    height: mainMenu.symbolSize

    Column
    {
        Rectangle
        {
            width: mainMenu.symbolSize
            height: 10

            color: theme.menuButtonBackground
        }

        Rectangle
        {
            width: mainMenu.symbolSize
            height: 1

            color: theme.menuButtonForeground
        }

        Rectangle
        {
            width: mainMenu.symbolSize
            height: 5

            color: theme.menuButtonBackground
        }
    }
}
