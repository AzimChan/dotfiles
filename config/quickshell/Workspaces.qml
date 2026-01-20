import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts


// TODO: Borrowed code :p

ColumnLayout {
    id: workspaces
    spacing: 1
    anchors.top: parent.top
    anchors.topMargin: 5
    anchors.bottomMargin: 5
    anchors.horizontalCenter: parent.horizontalCenter

    property var currentWorkspaces: Hyprland.workspaces.values.filter(w => w.monitor.name == screen.name)


    Repeater { 
        model: 10
        //model: Hyprland.workspaces.values.filter(w => w.monitor.name == taskbar.screen.name)
        Button {
            id: control
            anchors.centerIn: parent.centerIn
            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData < 9 ? modelData + 1 : 0
                font.pixelSize: 18
                font.bold: true
                width: parent.width
                height: 20
                color: getColor()
            }
            onPressed: event => {
                if((modelData + 1) != Hyprland.focusedWorkspace.id){
                    Hyprland.dispatch(`workspace ` + (modelData + 1));
                }
            }
            property int focusedWindowId: 0

            function getColor() {
                focusedWindowId = Hyprland.focusedWorkspace.id;
                if (((modelData + 1) == focusedWindowId) || mouse.hovered) {
                    return "cyan";
                }

                // TODO: awkward
                for(let i = 0; i < parent.currentWorkspaces.length; i++){
                    if(parent.currentWorkspaces[i].id == (modelData + 1)){
                        if(parent.currentWorkspaces[i].urgent){
                            return "red"
                        }
                        return "white"
                    }
                }
                return "gray";
            }

            background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                border.width: 1
                border.color: "black"
                width: parent.width
                height: 20
                color: "black"
            }

            HoverHandler {
                id: mouse
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
