// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root
  screen: root.modelData

  anchors {
    bottom: true
    left: true
    right: true
  }

  implicitHeight: 25
  color: "black"

  // Workspaces
  Item {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 12
    height: parent.height - 8
    width: workspaces.width

    Rectangle{
      anchors.fill: parent
      color: "green"
    }

    Workspaces {
      id: workspaces
      anchors.leftMargin: 2
      anchors.rightMargin: 0
    }
  }
  Item {
    anchors.centerIn: parent
    width: text.width + 30
    height: 50
    Rectangle{
      anchors.fill: parent
      color: "white"
      Text{
        id: text
        anchors.centerIn: parent
        text: "This sucks I know"
        color: "black"
      }
    }
  }

  //Clock
  Item {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 12
    height: parent.height - 8
    width: clock.width + 6

    Rectangle{
      anchors.fill: parent
      color: "red"
      Text {
        id: clock
        anchors.centerIn: parent
        color: "white"
        Process {
          id: dateProc
          command: ["date"]
          running: true

          stdout: StdioCollector {
            onStreamFinished: clock.text = this.text.trim()
          }
        }

        Timer {
          interval: 1000
          running: true
          repeat: true
          onTriggered: dateProc.running = true
        }
      }
    }
  }
}
