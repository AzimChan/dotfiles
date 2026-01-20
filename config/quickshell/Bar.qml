// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import QtQuick.Controls
import Quickshell.Services.UPower

PanelWindow {
  id: root
  screen: root.modelData

  anchors {
    bottom: true
    left: true
    top: true
  }

  implicitWidth: 35
  color: Config.bgColor
  // Left side
  // Workspaces
  Item {
    anchors.topMargin: 10
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width
    height: workspaces.height + 10

    Workspaces {
      id: workspaces
    }
  }
  // Cente
  // Right side
  Item {
    id: rightSide
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 10
    width: parent.width - 8
    height: 500

    // TODO: FIX SYS TRAY
    
    /* // Sys tray
    Rectangle {
      id: sysTrayContainter
      color: "purple"
      width: parent.width
      height: 50
      anchors.bottom: battery.top
      SysTray{
        id: sysTray
      }
    }*/

    // Battery percentage
    Rectangle {
      id: battery
      color: "black"
      anchors.bottom: kbLayout.top
      height: 50
      width: parent.width
      ProgressBar{
        rotation: -90
        width: parent.height - 8
        height: parent.width - 8
        anchors.centerIn: parent
        value: UPower.displayDevice.percentage
      }
      Column{
        anchors.centerIn: parent
        Text{
          anchors.horizontalCenter: parent.horizontalCenter
          text: UPower.displayDevice.percentage * 100
        }
        Text{
          anchors.horizontalCenter: parent.horizontalCenter
          text: UPower.displayDevice.state == 1 ? "\udb80\udc84" : "\udb85\udfe4"
        }
      }
    }
    // Keyboard layout
    Rectangle{
      id: kbLayout

      width: parent.width
      height: kbLayoutText.height + 5
      anchors.bottom: audio.top
      color: "black"

      function parseText(text){
        text = text.trim();
        if(text == "English (US)") return "en";
        if(text == "Russian") return "ru";
        if(text == "Kazakh") return "kz";
        return "na";
      }

      // Procs only on restart because Hyprland IPC dont have proper way to do that
      Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl devices -j | jq -r \'.keyboards[] | select(.main == true) | .active_keymap\'"]
        running: true

        stdout: StdioCollector {
          onStreamFinished: kbLayoutText.text = kbLayout.parseText(this.text)
        }
      }

      Text {
        id: kbLayoutText
        color: "white"
        anchors.centerIn: parent
        text: "na"
      }

      Connections {
        target: Hyprland
        function onRawEvent(event){
          if(event.name == "activelayout"){
            kbLayoutText.text = kbLayout.parseText(event.data.split(",")[1])
          }
        }
      }
    }

    Rectangle{
      id: audio

      PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
      }
      property var pw: Pipewire.defaultAudioSink.audio

      anchors.bottom: clockWidget.top
      color: "black"
      height: 30
      width: parent.width
      Text {
        id: audioText
        color: "white"
        anchors.centerIn: parent
        text: parent.pw.muted ? "\udb81\udf5f" : Math.round(parent.pw.volume * 100) + "%"
      }
    }
    
    // Clock
    Rectangle{
      anchors.bottom: parent.bottom
      id: clockWidget
      height: 50
      width: parent.width
      color: "black"

      Column{
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          id: dateText
          color: "white"
          SystemClock {
            id: clock
            precision: SystemClock.Minutes
          }
          text: Qt.formatDateTime(clock.date, "hh\nmm\n")
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: "white"
          font.pixelSize: 10
          text: Qt.formatDateTime(clock.date, "MM-dd")
        }
      }
    }

  }
}
