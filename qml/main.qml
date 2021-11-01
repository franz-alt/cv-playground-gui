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

        onUrlChanged:
        {
            sessionSettings.imageUrl = url;
        }
    }

    MagicDialog
    {
        id: magicDialog

        anchors.centerIn: parent

        onAccepted:
        {
            filterImage.setFilter(magicDialog.filter);

            sessionSettings.filterExpression = magicDialog.filter;
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

            restorePreviousSession = settingsDialog.restorePreviousSession;
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
        theme = Theme.create(mainWindow, settingsDialog.getThemeName());

        mainMenu.symbolSize = settingsDialog.getMenuSymbolSize();

        mainWindow.visible = true;
    }

    Settings
    {
        id: sessionSettings

        category: "SessionSettings"

        property alias restorePreviousSession: settingsDialog.restorePreviousSession

        property string imageUrl

        property string filterExpression

        property int mainWindowXPos
        property int mainWindowYPos
        property int mainWindowWidth
        property int mainWindowHeight

        Component.onCompleted:
        {
            if (restorePreviousSession)
            {
                filterImage.setImageUrl(imageUrl);

                magicDialog.setFilter(filterExpression);

                mainWindow.x = mainWindowXPos;
                mainWindow.y = mainWindowYPos;
                mainWindow.width = mainWindowWidth;
                mainWindow.height = mainWindowHeight;
            }
            else
            {
                // set session related data to default values
                imageUrl = "";

                magicDialog.clearFilter();

                mainWindow.width = 800;
                mainWindow.height = 600;
                mainWindow.x = Screen.width / 2 - mainWindow.width / 2;
                mainWindow.y = Screen.height / 2 - mainWindow.height / 2;
            }
        }

        Component.onDestruction:
        {
            if (restorePreviousSession)
            {
                mainWindowXPos = mainWindow.x;
                mainWindowYPos = mainWindow.y;
                mainWindowWidth = mainWindow.width;
                mainWindowHeight = mainWindow.height;
            }
        }
    }
}
