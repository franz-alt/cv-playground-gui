// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.0

import "Dialogs"
import "MainMenu"
import "Themes"

Window
{
    id: mainWindow

    width: 800
    height: 600

    // decide visibility after check if previous application settings should be restored
    visible: false

    title: qsTr("cv-playground")

    property var theme: Theme.create(mainWindow, "Default")

    Menu
    {
        id: mainMenu

        filterImage: filterImage

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: mainMenu.symbolSize + 2 * theme.menuButtonSymbolBorderMargin
    }

    FilterImage
    {
        id: filterImage

        anchors.left: mainMenu.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    MagicDialog
    {
        id: magicDialog

        anchors.centerIn: parent

        onAccepted:
        {
            filterImage.setFilter(magicDialog.filter);
        }
    }

    SettingsDialog
    {
        id: settingsDialog

        anchors.centerIn: parent

        onAccepted:
        {
            theme = Theme.create(mainWindow, settingsDialog.getThemeName());
            mainMenu.symbolSize = settingsDialog.getMenuSymbolSize();
        }

        onRejected:
        {
            // TODO Revert changes
        }
    }

    AboutDialog
    {
        id: aboutDialog

        anchors.centerIn: parent
    }

    Component.onCompleted:
    {
        if (!settingsDialog.isRestorePreviousSessionEnabled())
        {
            // set main window into center of the screen with a size of 800x600 pixels
            mainWindow.width = 800;
            mainWindow.height = 600;
            mainWindow.x = Screen.width / 2 - mainWindow.width / 2;
            mainWindow.y = Screen.height / 2 - mainWindow.height / 2;

            // set bright theme
            theme = Theme.create(mainWindow, "Default");

            // clear expression string at magic dialog
            magicDialog.clearFilter();
        }
        else
        {
            theme = Theme.create(mainWindow, settingsDialog.getThemeName());
            mainMenu.symbolSize = settingsDialog.getMenuSymbolSize();
        }

        mainWindow.visible = true;
    }

    Settings
    {
        category: "MainWindow"

        property alias x: mainWindow.x
        property alias y: mainWindow.y
        property alias width: mainWindow.width
        property alias height: mainWindow.height
    }
}
