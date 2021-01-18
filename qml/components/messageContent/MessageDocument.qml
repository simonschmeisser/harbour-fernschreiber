/*
    Copyright (C) 2020 Sebastian J. Wolf and other contributors

    This file is part of Fernschreiber.

    Fernschreiber is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Fernschreiber is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Fernschreiber. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0

MessageContentBase {

    id: documentPreviewItem
    height: Theme.itemSizeLarge

    property var documentData: rawMessage.content.document
    property bool openRequested: false;

    Component.onCompleted: {
        updateDocument();
    }

    function updateDocument() {
        if (documentData) {
            if (documentData.document.local.is_downloading_completed) {
                downloadDocumentButton.visible = false;
                openDocumentArea.visible = true;
            } else {
                openDocumentArea.visible = false;
                downloadDocumentButton.visible = true;
            }
        }
    }

    Connections {
        target: tdLibWrapper
        onFileUpdated: {
            if (documentData) {
                if (!fileInformation.remote.is_uploading_active && fileId === documentData.document.id && fileInformation.local.is_downloading_completed) {
                    downloadingProgressBar.visible = false;
                    documentData.document = fileInformation;
                    downloadDocumentButton.visible = false;
                    openDocumentArea.visible = true;
                    if (documentPreviewItem.openRequested) {
                        documentPreviewItem.openRequested = false;
                        tdLibWrapper.openFileOnDevice(documentData.document.local.path);
                    }
                }
                if (fileId === documentData.document.id) {
                    downloadingProgressBar.maximumValue = fileInformation.size;
                    downloadingProgressBar.value = fileInformation.local.downloaded_size;
                }
            }
        }
    }

    Button {
        id: downloadDocumentButton
        preferredWidth: Theme.buttonWidthMedium
        anchors.centerIn: parent
        text: qsTr("Download Document")
        visible: false
        highlighted: documentPreviewItem.highlighted || down
        onClicked: {
            downloadDocumentButton.visible = false;
            downloadingProgressBar.visible = true;
            tdLibWrapper.downloadFile(documentData.document.id);
        }
    }

    ProgressBar {
        id: downloadingProgressBar
        minimumValue: 0
        maximumValue: 100
        value: 0
        visible: false
        width: parent.width
        anchors.centerIn: parent
    }

    Column {
        id: openDocumentArea
        visible: false
        spacing: Theme.paddingMedium
        width: parent.width

        onVisibleChanged: {
            visible ? (documentPreviewItem.height = openDocumentArea.height) : (documentPreviewItem.height = Theme.itemSizeLarge);
        }

        Button {
            id: openDocumentButton
            preferredWidth: Theme.buttonWidthMedium
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Open Document")
            highlighted: documentPreviewItem.highlighted || down
            onClicked: {
                documentPreviewItem.openRequested = true;
                tdLibWrapper.openFileOnDevice(documentData.document.local.path);
            }
        }

        Button {
            id: copyDocumentButton
            preferredWidth: Theme.buttonWidthMedium
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Copy Document to Downloads")
            highlighted: documentPreviewItem.highlighted || down
            onClicked: {
                tdLibWrapper.copyFileToDownloads(documentData.document.local.path);
            }
        }
    }
}