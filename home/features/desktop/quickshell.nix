{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.quickshell;
  scheme = config.lib.stylix.colors;
  hexToRgb =
    color:
    let
      r = builtins.substring 0 2 color;
      g = builtins.substring 2 2 color;
      b = builtins.substring 4 2 color;
    in
    {
      r = (builtins.fromTOML "v = 0x${r}").v;
      g = (builtins.fromTOML "v = 0x${g}").v;
      b = (builtins.fromTOML "v = 0x${b}").v;
    };
  rgba =
    color: alpha:
    let
      rgb = hexToRgb color;
    in
    "rgba(${toString rgb.r}, ${toString rgb.g}, ${toString rgb.b}, ${toString alpha})";
in
{
  options.features.desktop.quickshell.enable = mkEnableOption "quickshell";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      quickshell
    ];

    home.file.".config/quickshell/shell.qml" = {
      text = ''
        import Quickshell
        import Quickshell.Wayland
        import Quickshell.Io
        import Quickshell.Hyprland
        import QtQuick
        import QtQuick.Layouts

        PanelWindow {
            id: root

            // Theme
            property color colBg: "#${scheme.base01}"
            property color colFg: "#${scheme.base05}"
            property color colMuted: "#${scheme.base03}"
            property color colCyan: "#${scheme.base0C}"
            property color colBlue: "#${scheme.base0D}"
            property color colYellow: "#${scheme.base0A}"
            property string fontFamily: "JetBrainsMono Nerd Font"
            property int fontSize: 14

            // System data
            property int cpuUsage: 0
            property int memUsage: 0
            property var lastCpuIdle: 0
            property var lastCpuTotal: 0

            // Processes and timers here...

            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 30
            color: root.colBg

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Workspaces
                Repeater {
                    model: 9
                    Text {
                        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                        text: index + 1
                        color: isActive ? root.colCyan : (ws ? root.colBlue : root.colMuted)
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // CPU
                Text {
                    text: "CPU: " + cpuUsage + "%"
                    color: root.colYellow
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                }

                Rectangle { width: 1; height: 16; color: root.colMuted }

                // Memory
                Text {
                    text: "Mem: " + memUsage + "%"
                    color: root.colCyan
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                }

                Rectangle { width: 1; height: 16; color: root.colMuted }

                // Clock
                Text {
                    id: clock
                    color: root.colBlue
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                    }
                }
            }
        }'';

    };
  };
}
