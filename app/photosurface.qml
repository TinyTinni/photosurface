/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.6
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.1
import QtQuick.Controls 2.5

import QtLocation 5.12

import com.tyti.imageSelector 1.0
import com.tyti.exifReader 1.0
import com.tyti.gpxReader 1.0

Window {
    id: root
    visible: true
    width: 1024; height: 600
    color: "black"

    function switchFullScreen()
    {
        if (visibility == Window.FullScreen)
            visibility = Window.Windowed
        else
            visibility = Window.FullScreen
        update()
    }

    Shortcut {
        id: fullscreenShortcut
        sequence: StandardKey.FullScreen
        onActivated: root.switchFullScreen()
    }

    property int highestZ: 0

    FileDialog {
        id: imageFileDialog
        title: "Choose a folder with some images"
        selectFolder: true
        folder: imgSelector.folder
        onAccepted: imgSelector.changeFolder(fileUrl)
    }

    FileDialog {
        id: trackFileDialog
        title: "Choose a track file"
        selectFolder: false
        selectMultiple: false
        folder: imgSelector.folder
        nameFilters: ["GPS Exchange Format (*.gpx)"]
        onAccepted: gpx.parseURL(fileUrl)
    }

    Rectangle {
        id: mapFrame
        width: 0.5*root.width
        height: 0.5*root.height
        x: root.width - width
        y: root.height - height
        Plugin {
            id: googleMapsPlugin
            name: "googlemaps" // "mapboxgl", "esri", ...
            // specify plugin parameters if necessary
            // PluginParameter {
            //     name:
            //     value:
            // }

        }
        Plugin {
            id: esriPlugin
            name: "esri"
        }
        Plugin{
            id: osmPlugin
            name: "osm"
        }

        MouseArea {
            id: mapDragArea
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: parent.height//-map.height
            drag.target: parent
            acceptedButtons: Qt.RightButton

            //
            hoverEnabled: true
            onEntered:
            {
                parent.z = parent.parent.z + 2
            }
            onExited: parent.z = parent.parent.z
            onWheel: {
                mapFrame.scale += mapFrame.scale * wheel.angleDelta.y / 120 / 10;
            }
            onPressed:
            {
                if(mouse.button === Qt.RightButton)
                    map.gesture.enabled = false
                else
                    map.gesture.enabled = true
            }
            onReleased: map.gesture.enabled = true

            Map {
                id: map
                //anchors.fill: parent
                width: parent.width
                height: 1.0*parent.height
                anchors.bottom: parent.bottom
                plugin: googleMapsPlugin
                //center: QGeo coordinate(52.09, 7.60) // Greven
                zoomLevel: 15
                copyrightsVisible: false
                z:parent.z+1
                gesture.preventStealing: true

                //activeMapType: MapType.HybridMap

                MapQuickItem {
                    id: image_location
                    sourceItem: Rectangle { width: 10; height: 10; color: "red"; border.width: 2; border.color: "blue"; smooth: true; radius: 15 }
                    coordinate : exif.coord
                    opacity:1.0
                    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                }

                MapPolyline{
                    id: mapPath
                    line.width: 3
                    line.color: 'green'
                }

            }
        }



    }
    Image {
        id: image
        //anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: imgSelector.image
        antialiasing: true
        width: 0.7*parent.width
        height: 0.7*parent.height
        z: parent.z+2
        PinchArea {
            anchors.fill: parent
            pinch.target: image
            pinch.minimumRotation: -360
            pinch.maximumRotation: 360
            pinch.minimumScale: 1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis
            property real zRestore: 0
            onSmartZoom: {
                if (pinch.scale > 0) {
                    image.rotation = 0;
                    image.scale = Math.min(root.width, root.height) / Math.max(image.sourceSize.width, image.sourceSize.height) * 0.85
                    image.x = flick.contentX + (flick.width - photoFrame.width) / 2
                    image.y = flick.contentY + (flick.height - photoFrame.height) / 2
                    zRestore = photoFrame.z
                    image.z = ++root.highestZ;
                } else {
                    image.rotation = pinch.previousAngle
                    image.scale = pinch.previousScale
                    image.x = pinch.previousCenter.x - photoFrame.width / 2
                    image.y = pinch.previousCenter.y - photoFrame.height / 2
                    image.z = zRestore
                    --root.highestZ
                }
            }

            MouseArea {
                id: dragArea
                hoverEnabled: true
                anchors.fill: parent
                drag.target: image
                onEntered:
                {
                    image.z = image.parent.z +2
                }
                onExited: image.z = image.parent.z


                onWheel: {
                    image.scale += image.scale * wheel.angleDelta.y / 120 / 10;

                }

                acceptedButtons: Qt.AllButtons
                onClicked:
                {
                    if(mouse.button === Qt.RightButton)
                    {
                        imgSelector.previousImage();
                    }
                    else if (mouse.button === Qt.LeftButton)
                    {
                        imgSelector.nextImage();
                    }
                }
            }
        }
        //      }

    }

    Image {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        source: "resources/burger_menu.png"
        width: 56 //todo: need scaling
        height: 56
        property double defaultOpacity: 0.1
        opacity: defaultOpacity
        z:100

        Menu {
            id: mainMenu
            MenuItem {
                text: "Open Image Folder... (" + openShortcut.portableText + ")"
                onTriggered: imageFileDialog.open()
            }

            MenuSeparator{}
            MenuItem {
                text: "Open Track"
                onTriggered: trackFileDialog.open()
            }
//            Menu{
//                id: trackSelectionMenu
//                title: "Tracks:"
//                enabled: false
//                MenuItem{
//                    text: "Track 1"
//                }
//            }


//            Menu {
//                id: selectProvider
//                title: "Select Provider:"
//                MenuItem{
//                    text: "Googlemaps"
//                    onTriggered: createMap(googleMapsPlugin)//map.plugin = googleMapsPlugin
//                }
//                MenuItem{
//                    text: "OpenStreetMaps"
//                    onTriggered: createMap(osmPlugin)//map.plugin = osmPlugin
//                }
//                MenuItem{
//                    text: "ESRI"
//                    onTriggered: createMap(esriPlugin)//map.plugin = esriPlugin
//                }
//            }

            MenuSeparator{}
            MenuItem{
                text: "Fullscreen (" + fullscreenShortcut.portableText + ")"
                onTriggered: root.switchFullScreen()
            }

            MenuItem {
                text: "Quit (" + closeShortcut.portableText + ")"
                onTriggered: Qt.quit()
            }

        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10

            onClicked: mainMenu.popup()
            hoverEnabled: true
            onEntered: parent.opacity = 1
            onExited: {
                parent.opacity = parent.defaultOpacity
            }
        }
        Shortcut {
            id: openShortcut
            sequence: StandardKey.Open
            onActivated: imageFileDialog.open()
        }
        Shortcut{
            id: closeShortcut
            sequence: StandardKey.Close
            onActivated: Qt.quit()
        }
    }
    GpxReader
    {
        id: gpx
        onTrackChanged:
        {
            //if (!tracks.isEmpty())
                mapPath.setPath(track)
        }
    }

    ImageSelector
    {
        id: imgSelector
        onImageChanged: exif.imageChanged(imgSelector.image)
        onNewTrackFileFound: gpx.parseURL(track)
        Component.onCompleted: imgSelector.changeFolder(imgSelector.folder)
    }

    ExifReader
    {
        id: exif
        onDataChanged:
        {
            map.center = coord
        }
    }
}
