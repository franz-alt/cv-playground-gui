// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

import QtQml.Models 2.15

Item
{
    id: filterEditor

    property string filter

    function filterText()
    {
        return textArea.text;
    }

    property bool showLineNumbers: true

    Row
    {
        anchors.fill: parent

        Rectangle
        {
            anchors.fill: parent

            color: theme.textInputBackground
        }

        Flickable
        {
            id: lineNumbersView

            width: 30

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            clip: true

            boundsBehavior: Flickable.StopAtBounds

            contentWidth: 30
            contentHeight: textArea.contentHeight

            Item
            {
                anchors.fill: parent

                ListView
                {
                    id: lineNumbers

                    anchors.fill: parent

                    model: ListModel { ListElement { number: "" } }

                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Text
                    {
                        text: number

                        width: lineNumbersView.width

                        horizontalAlignment: Text.AlignRight

                        color: theme.textInputColor
                    }
                }
            }
        }

        Flickable
        {
            id: expressionView

            anchors.left: lineNumbersView.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            clip: true

            boundsBehavior: Flickable.StopAtBounds

            contentWidth: Math.max(textArea.placeholderText.length * fontSize, textArea.contentWidth + verticalScrollBar.width + textArea.font.pixelSize)
            contentHeight: Math.max(fontSize, textArea.contentHeight + horizontalScrollBar.height)

            ScrollBar.horizontal: horizontalScrollBar
            ScrollBar.vertical: verticalScrollBar

            TextArea
            {
                id: textArea

                anchors.fill: parent

                topPadding: 0
                leftPadding: 10

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

                onLineCountChanged:
                {
                    lineNumbers.model.clear();

                    for (var i = 1; i <= lineCount; i++)
                    {
                        lineNumbers.model.append({"number": Number(i).toString()});
                    }
                }

                MouseArea
                {
                    anchors.fill: textArea

                    propagateComposedEvents: true

                    onClicked:
                    {
                        textArea.cursorPosition = textArea.positionAt(mouse.x, mouse.y);
                        textArea.forceActiveFocus();
                    }
                }
            }
        }

        ScrollBar
        {
            id: verticalScrollBar

            active: true

            policy: ScrollBar.AlwaysOn

            anchors.right: expressionView.right
            anchors.top: expressionView.top
            anchors.bottom: expressionView.bottom

            orientation: Qt.Vertical

            z: 1

            stepSize: 0.05

            onPositionChanged:
            {
                expressionView.contentY = position * textArea.height;

                lineNumbersView.contentHeight = textArea.height;
                lineNumbersView.contentY = position * textArea.height;
            }
        }

        ScrollBar
        {
            id: horizontalScrollBar

            active: true

            policy: ScrollBar.AsNeeded

            anchors.left: expressionView.left
            anchors.right: expressionView.right
            anchors.bottom: expressionView.bottom

            orientation: Qt.Horizontal

            z: 1

            onPositionChanged:
            {
                expressionView.contentX = position * textArea.width;
            }
        }

        MouseArea
        {
            anchors.fill: parent

            propagateComposedEvents: true

            acceptedButtons: Qt.RightButton

            onClicked:
            {
                contextMenu.x = mouse.x;
                contextMenu.y = mouse.y;
                contextMenu.open();
            }

            onWheel:
            {
                wheel.accepted = false;

                if (wheel.angleDelta.y < 0)
                {
                    verticalScrollBar.increase();
                }
                else
                {
                    verticalScrollBar.decrease();
                }
            }
        }
    }

    Component.onCompleted:
    {
        textArea.text = filter;
    }

    Menu
    {
        id: contextMenu

        MenuItem
        {
            text: qsTr("Show Line Numbers")

            checked: showLineNumbers

            onTriggered:
            {
                showLineNumbers = !showLineNumbers;
            }
        }
    }

    onShowLineNumbersChanged:
    {
        lineNumbersView.visible = showLineNumbers;
        lineNumbersView.width = showLineNumbers ? 30 : 0;
    }

    Settings
    {
        category: "FilterEditor";

        property alias showLineNumbersEnabled: filterEditor.showLineNumbers
    }
}
