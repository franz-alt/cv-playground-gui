// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0

BaseDialog
{
    id: dialog

    title: qsTr("Settings")

    dialogIcon: "../../images/settings-svgrepo-com.svg"

    function isRestorePreviousSessionEnabled()
    {
        return restorePreviousSessionCheckBox.checked;
    }

    function getThemeName()
    {
        if (blueTheme.checked)
        {
            return "Blue";
        }
        else if (brightTheme.checked)
        {
            return "Bright";
        }
        else if (darkTheme.checked)
        {
            return "Dark";
        }
        else
        {
            return "Default";
        }
    }

    function getMenuSymbolSize()
    {
        return applicationMenuSymbolSize.value;
    }

    contentItem: Flickable
    {
        id: settingsFlickable

        contentWidth: dialog.availableWidth
        contentHeight: col.implicitHeight

        flickableDirection: Qt.Vertical

        clip: true

        ScrollBar.vertical: ScrollBar
        {
            width: 10

            contentItem: Rectangle
            {
                color: "darkgray"
            }
        }

        ColumnLayout
        {
            id: col

            anchors.fill: parent

            spacing: 5

            GroupBox
            {
                title: qsTr("Startup")

                ColumnLayout
                {
                    anchors.fill: parent

                    CheckBox
                    {
                        id: restorePreviousSessionCheckBox

                        text: qsTr("Restore previous session")
                    }
                }
            }

            GroupBox
            {
                title: qsTr("Appearance");

                ColumnLayout
                {
                    GroupBox
                    {
                        title: qsTr("Application Menu")

                        ColumnLayout
                        {
                            RowLayout
                            {
                                Text
                                {
                                    text: qsTr("Size Of Symbols");
                                }

                                Slider
                                {
                                    id: applicationMenuSymbolSize

                                    from: 16
                                    value: 24
                                    to: 32

                                    stepSize: 1.0
                                }

                                Text
                                {
                                    text: qsTr("Pixels");
                                }
                            }
                        }
                    }

                    GroupBox
                    {
                        title: qsTr("Theme")

                        ColumnLayout
                        {
                            anchors.fill: parent

                            RadioButton
                            {
                                id: blueTheme

                                text: qsTr("Blue")
                            }

                            RadioButton
                            {
                                id: brightTheme

                                checked: true

                                text: qsTr("Bright")
                            }

                            RadioButton
                            {
                                id: darkTheme

                                text: qsTr("Dark")
                            }
                        }
                    }
                }
            }
        }
    }

    Settings
    {
        category: "GlobalSettings";

        property alias restorePreviousSession: restorePreviousSessionCheckBox.checked
        property alias blueTheme: blueTheme.checked
        property alias brightTheme: brightTheme.checked
        property alias darkTheme: darkTheme.checked
        property alias applicationMenuSymbolSize: applicationMenuSymbolSize.value
    }
}
