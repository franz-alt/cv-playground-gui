// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.0

import QtQml.Models 2.15

import com.cvpg.viewer 1.0

Item
{
    id: filterEditor

    property string filter

    function filterText()
    {
        return textArea.text;
    }

    property bool showLineNumbers: true
    property bool enableSyntaxHighlighting: true

    property string fontFamily: "Arial"
    property int fontSize: 10

    Item
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

                        font.family: fontFamily
                        font.pixelSize: fontSize

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

                text: documentHandler.text

                font.family: fontFamily
                font.pixelSize: fontSize

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

                Component.onCompleted:
                {
                    documentHandler.setDocument(textArea.textDocument);
                }

                onVisibleChanged:
                {
                    if (visible)
                    {
                        // set syntax highlighting colors
                        documentHandler.setSyntaxHighlightingColor(DocumentHandler.Comment, theme.filterEditorSyntaxHighlightingComment);
                        documentHandler.setSyntaxHighlightingColor(DocumentHandler.Function, theme.filterEditorSyntaxHighlightingFunction);
                        documentHandler.setSyntaxHighlightingColor(DocumentHandler.Keyword, theme.filterEditorSyntaxHighlightingKeyword);
                        documentHandler.setSyntaxHighlightingColor(DocumentHandler.Quotation, theme.filterEditorSyntaxHighlightingQuotation);

                        // set/unset syntax highlighting state
                        documentHandler.setSyntaxHighlightingState(enableSyntaxHighlighting);
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

        MenuItem
        {
            text: qsTr("Enable Syntax Highlighting");

            checked: enableSyntaxHighlighting

            onTriggered:
            {
                enableSyntaxHighlighting = !enableSyntaxHighlighting;
            }
        }

        MenuSeparator {}

        Menu
        {
            id: fontFamilySubMenu

            title: qsTr("Font Family")

            Instantiator
            {
                model: Qt.fontFamilies()

                delegate: MenuItem
                {
                    text: modelData

                    checkable: true
                    checked: false

                    onTriggered:
                    {
                        fontFamily = modelData;

                        for (var i = 0; i < fontFamilySubMenu.count; ++i)
                        {
                            fontFamilySubMenu.itemAt(i).checked = false;
                        }

                        checked = true;
                    }
                }

                onObjectAdded:
                {
                    fontFamilySubMenu.insertItem(index, object);
                }

                onObjectRemoved:
                {
                    fontFamilySubMenu.removeItem(object);
                }
            }
        }

        Menu
        {
            id: fontSizeSubMenu

            title: qsTr("Font Size")

            Instantiator
            {
                model: ListModel
                {
                    Component.onCompleted:
                    {
                        for (var i = 5; i <= 40; ++i)
                        {
                            append({ value: i });

                            if (fontSize === i)
                            {
                                fontSizeSubMenu.itemAt(i - 5).checked = true;
                            }
                        }
                    }
                }

                delegate: MenuItem
                {
                    text: modelData

                    checkable: true
                    checked: false

                    onTriggered:
                    {
                        fontSize = modelData;

                        for (var i = 0; i < fontSizeSubMenu.count; ++i)
                        {
                            fontSizeSubMenu.itemAt(i).checked = false;
                        }

                        checked = true;
                    }
                }

                onObjectAdded:
                {
                    fontSizeSubMenu.insertItem(index, object);
                }

                onObjectRemoved:
                {
                    fontSizeSubMenu.removeItem(object);
                }
            }
        }

        MenuSeparator {}

        MenuItem
        {
            text: qsTr("Import Filter Script")

            FileDialog
            {
                id: fileImportDialog

                title: qsTr("Import filter script to file")

                nameFilters: [ qsTr("cv-playground files (*.pg)"), qsTr("All files (*)") ]

                selectExisting: false

                onSelectionAccepted:
                {
                    var url = fileImportDialog.fileUrl.toString();
                    url = url.replace(/^(file:\/{2})/,"");
                    url = decodeURIComponent(url);

                    textArea.text = fileIo.read(url);
                }
            }

            onTriggered:
            {
                fileImportDialog.open();
            }
        }

        MenuItem
        {
            text: qsTr("Export Filter Script")

            FileDialog
            {
                id: fileExportDialog

                title: qsTr("Export filter script to file")

                nameFilters: [ qsTr("cv-playground files (*.pg)"), qsTr("All files (*)") ]

                selectExisting: false

                onSelectionAccepted:
                {
                    var url = fileExportDialog.fileUrl.toString();
                    url = url.replace(/^(file:\/{2})/,"");
                    url = decodeURIComponent(url);

                    if (!fileIo.write(url, textArea.text))
                    {
                        console.log("Error while writing filter to file '" + url + "'.");
                    }
                }
            }

            onTriggered:
            {
                fileExportDialog.open();
            }
        }
    }

    onShowLineNumbersChanged:
    {
        lineNumbersView.visible = showLineNumbers;
        lineNumbersView.width = showLineNumbers ? 30 : 0;
    }

    onEnableSyntaxHighlightingChanged:
    {
        documentHandler.setSyntaxHighlightingState(enableSyntaxHighlighting);
    }

    Settings
    {
        category: "FilterEditor";

        property alias showLineNumbersEnabled: filterEditor.showLineNumbers
        property alias enableSyntaxHighlighting: filterEditor.enableSyntaxHighlighting
        property alias fontFamily: filterEditor.fontFamily
        property alias fontSize: filterEditor.fontSize
    }

    Component.onCompleted:
    {
        textArea.text = filter;

        // check menu item for persisted font family
        for (var i = 0; i < fontFamilySubMenu.count; ++i)
        {
            if (fontFamilySubMenu.itemAt(i).text === fontFamily)
            {
                fontFamilySubMenu.itemAt(i).checked = true;
                break;
            }
        }
    }
}
