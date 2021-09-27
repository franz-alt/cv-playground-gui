// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0

import AppInfo 1.0

BaseDialog
{
    title: qsTr("About")

    width: 300
    height: 200

    dialogIcon: "../../images/help-svgrepo-com.svg"

    dialogButtons: BaseDialog.DialogButtons.Ok

    contentItem: Item
    {
        Column
        {
            Row
            {
                height: 30

                Text
                {
                    text: qsTr("cv-playground Editor ")

                    height: 20

                    font.bold: true
                    font.pixelSize: 15

                    verticalAlignment: Text.AlignBottom
                }

                Text
                {
                    text: AppInfo.version

                    height: 20

                    verticalAlignment: Text.AlignBottom
                }
            }

            Row
            {
                height: 25

                Text
                {
                    text: qsTr("Build at ");
                }

                Text
                {
                    text: AppInfo.buildTimestamp
                }
            }

            Text
            {
                text: qsTr("Copyright ") + "\u00a9 2021 Franz Alt"
            }
        }
    }
}
