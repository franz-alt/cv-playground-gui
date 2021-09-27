// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

function create(parent, name)
{
    var comp = Qt.createComponent("./" + name + ".qml");

    if (comp.status === Component.Ready)
    {
        try
        {
            return comp.createObject(parent);
        }
        catch (err)
        {
            console.log("Error loading theme '" + name + "'");
        }

        console.log("Theme error: " + comp.errorString());

        try
        {
            return Qt.createComponent("./Default.qml").createObject(parent);
        }
        catch (err)
        {
            console.log("Error loading default theme");
        }
    }
}
