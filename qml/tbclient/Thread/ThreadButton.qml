import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root;

    property Item tab;
    property bool checked: tab === internal.tabGroup.currentTab;
    signal clicked;

    QtObject {
        id: internal;

        property Item tabGroup: findParent(tab, "currentTab");
        function press(){
            privateStyle.play(Symbian.BasicButton);
        }
        function click(){
            root.clicked();
            privateStyle.play(Symbian.BasicButton);
            if (internal.tabGroup){
                if (internal.tabGroup.currentTab == tab){
                    tab.positionAtTop();
                } else {
                    internal.tabGroup.currentTab = tab;
                }
            }
        }
        function findParent(child, propertyName) {
            if (!child)
                return null
            var next = child.parent
            while (next && !next.hasOwnProperty(propertyName))
                next = next.parent
            return next
        }
        function getMask(){
            if (tab.loading)
                return busyIndicator;
            if (sectionMouseArea.pressed)
                return pressingIndicator;
            if (!root.checked)
                return inactiveIndicator;
        }
    }

    Label {
        anchors { fill: parent; margins: platformStyle.paddingSmall; }
        elide: Text.ElideRight;
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        textFormat: Text.PlainText;
        wrapMode: Text.WrapAnywhere;
        maximumLineCount: 1;
        text: tab.title;
    }

    Loader {
        anchors.fill: parent;
        sourceComponent: internal.getMask();
        Component {
            id: busyIndicator;
            Rectangle {
                id: indBg;
                anchors.fill: parent;
                color: "black";
                opacity: 0;
                BusyIndicator {
                    opacity: 1;
                    anchors.centerIn: parent;
                    running: true;
                }
                Component.onCompleted: PropertyAnimation {
                    target: indBg;
                    property: "opacity";
                    from: 0;
                    to: 0.75;
                    duration: 250;
                }
            }
        }
        Component {
            id: pressingIndicator;
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: 0.5;
            }
        }
        Component {
            id: inactiveIndicator;
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: 0.3;
            }
        }
    }
    MouseArea {
        id: sectionMouseArea;
        anchors.fill: parent;
        onPressed: internal.press();
        onClicked: internal.click();
    }
}
