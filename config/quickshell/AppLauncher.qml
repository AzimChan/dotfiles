//NOt finished
import Quickshell.Io
import Quickshell
import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

Scope{
  id: launcher
  IpcHandler {
    target: "launcher"

    function startLauncher(): void { shouldShowLauncher = !shouldShowLauncher}
  }

  property bool shouldShowLauncher: false

  LazyLoader{
    active: shouldShowLauncher

    PanelWindow {
      anchors{
        top: true
        bottom: true
        right: true
      }
      color: "transparent"
      exclusiveZone: 0
      margins.top: 10
      margins.bottom: 10
      margins.right: 3
      width: 500
      
      
      mask: Region {}
      Rectangle{
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        width: 500
        height: 500
        ColumnLayout{

          anchors.horizontalCenter: parent.horizontalCenter
          
          Rectangle{
            anchors.horizontalCenter: parent.horizontalCenter
            width: 400
            height: 20
            color: "black"
          }
        }
      }
     }
  }
}
