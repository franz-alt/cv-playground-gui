// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0
import QtQuick.Controls 2.15

Item
{
    property string filter

    function filterText()
    {
        return textArea.text;
    }

    ScrollView
    {
        anchors.fill: parent

        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        TextArea
        {
            id: textArea

            placeholderText: qsTr("Enter filter expression")

            color: theme.textInputColor

            background: Rectangle
            {
                color: theme.textInputBackground
            }

            onTextChanged:
            {
                filter = text;
            }
        }
    }

    Component.onCompleted:
    {
        textArea.text = filter;
    }
}
