// Copyright (c) 2021 Franz Alt
// This code is licensed under MIT license (see LICENSE.txt for details).

import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

import com.cvpg.viewer 1.0

Item
{
    function selectInput()
    {
        fileDialog.open();
    }

    function setFilter(expression)
    {
        image.setFilter(expression);
    }

    function setImageUrl(url)
    {
        image.setUrl(url);
    }

    function clearURL()
    {
        image.setUrl("");
    }

    signal urlChanged(string url)

    Flickable
    {
        id: flickarea

        anchors.fill: parent

        contentWidth: image.width
        contentHeight: image.height

        clip: true

        boundsBehavior: Flickable.StopAtBounds

        transform: Scale
        {
            id: scale

            // transformation origin and scale values will be set every time the wheel is used in
            // combination with the ctrl-key
        }

        FilterImageItem
        {
            id: image

            width: originalWidth
            height: originalHeight
        }

        MouseArea
        {
            anchors.fill: parent

            hoverEnabled: true

            onWheel:
            {
                if (wheel.modifiers & Qt.ControlModifier)
                {
                    if (wheel.angleDelta.y > 0)
                    {
                        scale.xScale = scale.xScale + 0.1;
                        scale.yScale = scale.yScale + 0.1;
                    }
                    else
                    {
                        if (scale.xScale > 1.0)
                        {
                            scale.xScale = scale.xScale - 0.1;
                            scale.yScale = scale.yScale - 0.1;
                        }
                    }

                    var mapped = mapToItem(flickarea, mouseX, mouseY)

                    flickarea.resizeContent(image.originalWidth * scale.xScale, image.originalHeight * scale.yScale, mapped);
                    flickarea.returnToBounds();
                }
                else
                {
                    wheel.accepted = false
                }
            }
        }
    }

    ScrollBar
    {
        active: true

        policy: ScrollBar.AlwaysOn

        anchors.right: flickarea.right
        anchors.top: flickarea.top
        anchors.bottom: flickarea.bottom

        orientation: Qt.Vertical

        position: flickarea.contentY / image.height
        size: flickarea.height / flickarea.contentHeight

        z: 1

        onPositionChanged:
        {
            flickarea.contentY = position * image.height;
        }
    }

    ScrollBar
    {
        active: true

        policy: ScrollBar.AlwaysOn

        anchors.left: flickarea.left
        anchors.right: flickarea.right
        anchors.bottom: flickarea.bottom

        orientation: Qt.Horizontal

        position: flickarea.contentX / image.width
        size: flickarea.width / flickarea.contentWidth

        z: 1

        onPositionChanged:
        {
            flickarea.contentX = position * image.width;
        }
    }

    FileDialog
    {
        id: fileDialog
        title: qsTr("Select Input")
        nameFilters: [ qsTr("Image files (*.jpg *.png)"), qsTr("All files (*)") ]

        onSelectionAccepted:
        {
            image.setUrl(fileDialog.fileUrl);

            urlChanged(fileDialog.fileUrl);
        }
    }

    Rectangle
    {
        anchors.fill: parent

        color: theme.primaryBackground

        visible: image.status !== FilterImageItem.Success

        Item
        {
            anchors.centerIn: parent

            width: statusIndicatorSymbol.width
            height: statusIndicatorSymbol.height

            ColumnLayout
            {
                id: statusIndicatorSymbol

                spacing: 15

                Rectangle
                {
                    width: 50
                    height: 50

                    BusyIndicator
                    {
                        anchors.fill: parent

                        visible: image.status === FilterImageItem.Loading

                        running: image.status === FilterImageItem.Loading
                    }

                    Rectangle
                    {
                        anchors.fill: parent

                        color: theme.primaryBackground

                        visible: image.status === FilterImageItem.NoImage | image.status === FilterImageItem.Failed

                        Image
                        {
                            id: statusIndicatorImage

                            source:
                            {
                                switch (image.status)
                                {
                                    case FilterImageItem.NoImage:
                                        return "../images/file-svgrepo-com.svg";

                                    case FilterImageItem.Failed:
                                        return ""; // TODO add an image for failed state

                                    default:
                                    case FilterImageItem.Success:
                                        return "";
                                }
                            }
                        }

                        ColorOverlay
                        {
                            anchors.fill: statusIndicatorImage

                            source: statusIndicatorImage

                            color: theme.primaryForeground
                        }
                    }
                }

                Text
                {
                    id: statusIndicatorLabel

                    color: theme.primaryForeground

                    text:
                    {
                        switch (image.status)
                        {
                            case FilterImageItem.NoImage:
                                return qsTr("No Image");

                            case FilterImageItem.Loading:
                                return qsTr("Loading ...");

                            case FilterImageItem.Failed:
                                return qsTr("Failed");

                            default:
                            case FilterImageItem.Success:
                                return "";
                        }
                    }
                }
            }

            MouseArea
            {
                anchors.fill: parent

                onClicked:
                {
                    filterImage.selectInput();
                }
            }
        }
    }
}
