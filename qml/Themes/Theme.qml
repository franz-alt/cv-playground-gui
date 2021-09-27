// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0

QtObject
{
    // general
    property color primaryForeground: "black"
    property color primaryBackground: "lightgray"

    readonly property int buttonRoundness: 4

    // application menu buttons
    property color menuButtonForeground: "dimgray"
    property color menuButtonBackground: "white"
    property color menuButtonHighlighted: "black"
    property color menuButtonDisabled: "lightgray"

    readonly property int menuButtonSymbolBorderMargin: 8

    // text input
    property color textInputColor: "black"
    property color textInputBackground: "white"

    // dialog window
    property color dialogWindowTitleColor: "black"
    property color dialogWindowTitleBackground: "white"
    property color dialogWindowBackground: "white"

    // dialog window buttons
    property color dialogButtonTextColor: "black"
    property color dialogButtonBackground: "gray"
    property color dialogButtonHighlighted: "lightgray"
}
