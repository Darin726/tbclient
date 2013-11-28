import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script
import "../../js/Utils.js" as Utils

MyPage {
    id: page;

    title: qsTr("Create a new thread");

    PostHeader {
        id: viewHeader;
        visible: app.inPortrait;
        text: page.title;
    }

    TextField {
        id: titlefield;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: viewHeader.bottom;
        anchors.margins: constant.paddingMedium;
        platformInverted: tbsettings.whiteTheme;
        KeyNavigation.down: contentArea;
        Keys.onPressed: {
            if (event.key == Qt.Key_Select
                    ||event.key == Qt.Key_Enter
                    ||event.key == Qt.Key_Return){
                contentArea.forceActiveFocus();
                contentArea.openSoftwareInputPanel();
                event.accepted = true;
            }
        }
        onTextChanged: {
            var max = 60;
            if (Utils.TextSlicer.textLength(text) > max){
                text = Utils.TextSlicer.slice(text, max);
            }
        }
    }

    TextArea {
        id: contentArea;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: titlefield.bottom;
        anchors.bottom: toolsBanner.top;
        anchors.margins: constant.paddingMedium;
        platformInverted: tbsettings.whiteTheme;
    }

    Item {
        id: toolsBanner;
        anchors {
            left: parent.left; leftMargin: constant.paddingMedium;
            right: parent.right; rightMargin: constant.paddingMedium;
            bottom: attachedArea.top;
        }
        height: childrenRect.height;
        Row {
            id: toolsRow;
            spacing: constant.paddingSmall;
            ToolButton {
                platformInverted: tbsettings.whiteTheme;
                iconSource: "../../gfx/btn_insert_face"+constant.invertedString+".png"
            }
            ToolButton {
                platformInverted: tbsettings.whiteTheme;
                iconSource: "../../gfx/btn_insert_at"+constant.invertedString+".png";
            }
            ToolButton {
                id: picBtn;
                checkable: true;
                platformInverted: tbsettings.whiteTheme;
                iconSource: "../../gfx/btn_insert_pics"+constant.invertedString+".png";
                onClicked: attachedArea.state = attachedArea.state == "Image" ? "" : "Image";
            }
            ToolButton {
                id: voiBtn;
                checkable: true;
                platformInverted: tbsettings.whiteTheme;
                iconSource: "../../gfx/btn_insert_voice"+constant.invertedString+".png";
                onClicked: attachedArea.state = attachedArea.state == "Voice" ? "" : "Voice";
            }
        }
        ToolButton {
            anchors.top: app.inPortrait ? toolsRow.bottom : parent.top;
            anchors.right: parent.right;
            platformInverted: tbsettings.whiteTheme;
            text: qsTr("Post");
        }
    }

    AttachedArea {
        id: attachedArea;
        onStateChanged: {
            picBtn.checked = state === "Image";
            voiBtn.checked = state === "Voice";
        }
    }

    states: [
        State {
            name: "VKBOpened";
            PropertyChanges { target: viewHeader; visible: false; }
            PropertyChanges { target: contentArea; anchors.bottom: page.bottom; }
            PropertyChanges { target: toolsBanner; visible: false; }
            PropertyChanges { target: attachedArea; visible: false; }
            when: app.platformSoftwareInputPanelEnabled && inputContext.visible;
        }
    ]

    onStatusChanged: {
        if (status === PageStatus.Activating){
            app.showToolBar = false;
        } else if (status === PageStatus.Deactivating){
            app.showToolBar = true;
        } else if (status === PageStatus.Active){
            if (titlefield.visible){
                titlefield.forceActiveFocus();
                titlefield.openSoftwareInputPanel();
            } else {
                contentArea.forceActiveFocus();
                contentArea.openSoftwareInputPanel();
            }
        }
    }
}