import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire

Scope{
  id: osd

  PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
      }
  property var pw: Pipewire.defaultAudioSink.audio

  Connections {
    target: Pipewire.defaultAudioSink?.audio

    function onVolumeChanged() {
      osd.shouldShowOsd = true;
      hideTimer.restart()
    }
  }

  property bool shouldShowOsd: false

  Timer {
    id: hideTimer
    interval: 1000
    onTriggered: osd.shouldShowOsd = false
  }



  LazyLoader{
    active: shouldShowOsd

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
      width: 15
      
      
      mask: Region {}
      ProgressBar{
        anchors.centerIn: parent
        rotation: -90
        value: osd.pw.volume
      }
     }
  }
}
