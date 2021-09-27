// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0
import QtQuick.Layouts 1.3

Item
{
    id: mainMenu

    property Item filterImage

    property int symbolSize

    Rectangle
    {
        id: menuBarItems

        anchors.fill: parent

        color: theme.menuButtonBackground

        ColumnLayout
        {
            anchors.topMargin: theme.menuButtonSymbolBorderMargin
            anchors.leftMargin: theme.menuButtonSymbolBorderMargin
            anchors.bottomMargin: theme.menuButtonSymbolBorderMargin

            anchors.fill: parent

            Column
            {
                spacing: 10

                Layout.fillWidth: true

                MenuItem
                {
                    icon: "../../images/file-svgrepo-com.svg"
                    text: qsTr("Open Input")
                    toolTip: qsTr("Open an input file.")

                    onPressed:
                    {
                        filterImage.selectInput();
                    }
                }

                MenuItem
                {
                    icon: "../../images/save-svgrepo-com.svg"
                    text: qsTr("Save")
                    toolTip: qsTr("Save image to a file.")
                    disabled: true
                }

                MenuItem
                {
                    icon: "../../images/hat-and-magic-wand-svgrepo-com.svg"
                    text: qsTr("Process")
                    toolTip: qsTr("Perform an image filter on the image.")

                    height: symbolSize

                    onPressed:
                    {
                        magicDialog.open();
                    }
                }

                MenuSeparator {}

                MenuItem
                {
                    icon: "../../images/settings-svgrepo-com.svg"
                    text: qsTr("Preferences")
                    toolTip: qsTr("Change application settings.")

                    onPressed:
                    {
                        settingsDialog.open();
                    }
                }
            }

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            MenuItem
            {
                icon: "../../images/help-svgrepo-com.svg"
                text: qsTr("About")
                toolTip: qsTr("Display some application informations.")

                Layout.fillWidth: true

                onPressed:
                {
                    aboutDialog.open();
                }
            }
        }
    }
}
