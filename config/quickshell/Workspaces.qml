import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts


// TODO: Borrowed code :p

RowLayout {
    id: workspaces
    spacing: 5
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    property bool usingHyprland: Hyprland.workspaces.values.length == 0 ? false : true

    property var currentWorkspaces: usingHyprland ? Hyprland.workspaces.values.filter(w => w.monitor.name == screen.name) : I3.workspaces.values.filter(w => w.monitor.name == screen.name)


    Repeater { 
        model: parent.currentWorkspaces
        //model: Hyprland.workspaces.values.filter(w => w.monitor.name == taskbar.screen.name)
        Button {
            id: control
            anchors.centerIn: parent.centerIn
            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: usingHyprland ? modelData.id : modelData.number
                width: 10
                height: 10
                color: "black"
            }
            onPressed: event => {
                if(usingHyprland) {
                    Hyprland.dispatch(`workspace ` + modelData.id);
                }else {
                  I3.dispatch(`workspace ` + modelData.number);
                }
                event.accepted = true;
            }
            property int focusedWindowId: 0
            function getColor() {
                if (usingHyprland == true) {
                  focusedWindowId = Hyprland.focusedWorkspace.id;
                }else {
                  focusedWindowId = I3.focusedWorkspace.number;
                }

                if (modelData.urgent) {
                    return "red";
                } else {
                    if ((usingHyprland && modelData.id == focusedWindowId) || mouse.hovered) {
                         return "blue"
                    }else if ((usingHyprland == false && modelData.number == focusedWindowId) || mouse.hovered) {
                         return "green"
                    }
                }
                return "gray";
            }

            background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                border.width: 1
                border.color: Config.colors.outline
                width: 22
                height: 22
                color: getColor()
            }

            HoverHandler {
                id: mouse
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
