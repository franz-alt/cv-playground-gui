// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.15
import QtQuick.Controls 2.15

import ".."

BaseDialog
{
    title: qsTr("Apply Filter")

    dialogIcon: "../../images/hat-and-magic-wand-svgrepo-com.svg"

    property string filter

    function setFilter(expression)
    {
        editor.filter = expression;
    }

    function clearFilter()
    {
        filter = "";
        editor.filter = "";
    }

    onAccepted:
    {
        filter = editor.filterText();
    }

    contentItem: FilterEditor
    {
        id: editor
    }
}
