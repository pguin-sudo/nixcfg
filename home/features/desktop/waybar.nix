{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.desktop.waybar;
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
  options.features.desktop.waybar.enable = mkEnableOption "waybar";

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          margin = "0px 0px 0px 0px";
          spacing = 3;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "mpris" ];
          modules-right = [
            "cpu"
            "memory"
            "network"
            "custom/vpn"
            "pulseaudio"
            "backlight"
            "battery"
            "tray"
            "clock"
          ];
          "custom/vpn" = {
            exec = ''
              if nmcli -t -f name,type,state connection show --active | grep -E 'vpn|wireguard|openvpn' > /dev/null; then
                vpn_name=$(nmcli -t -f name,type,state connection show --active | grep -E 'vpn|wireguard|openvpn' | head -1 | cut -d: -f1)
                echo "{\"text\": \"󰖂\", \"class\": \"connected\"}"
              else
                echo "{\"text\": \"󰌙\", \"class\": \"disconnected\"}"
              fi
            '';
            return-type = "json";
            exec-if = "which nmcli";
            format = "{}";
            tooltip = false;
            on-click = ''
              if nmcli -t -f name,type,state connection show --active | grep -E "vpn|wireguard|openvpn" > /dev/null; then
                nmcli connection down $(nmcli -t -f name,type,state connection show --active | grep -E "vpn|wireguard|openvpn" | head -1 | cut -d: -f1)
              else
                vpn_list=$(nmcli -t -f name,type connection show | grep -E "vpn|wireguard|openvpn" | cut -d: -f1 | head -1)
                if [ -n "$vpn_list" ]; then
                  nmcli connection up "$vpn_list"
                fi
              fi
            '';
            max-length = 20;
            interval = 5;
          };
          "hyprland/workspaces" = {
            format = "{id}{icon}";
            all-outputs = true;
            on-click = "activate";
            format-icons = {
              active = "";
              default = "";
              urgent = " 󰈸";
            };
          };
          "tray" = {
            spacing = 6;
            icon-size = 16;
          };
          "clock" = {
            format = "{:%H:%M}";
            format-alt = "{:%d/%m}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt-click = "click-right";
          };
          "cpu" = {
            interval = 5;
            format = "󰻠 {usage}%";
            format-alt = "󰻠 {avg_frequency} GHz";
            max-length = 15;
            tooltip = false;
          };
          "memory" = {
            interval = 5;
            format = "󰍛 {percentage}%";
            format-alt = "󰍛 {used:0.1f}G";
            max-length = 15;
            tooltip = false;
          };
          "backlight" = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = [
              "󰃞"
              "󰃟"
              "󰃠"
            ];
            on-scroll-up = "brightnessctl set 1%+";
            on-scroll-down = "brightnessctl set 1%-";
            tooltip-format = "Brightness: {percent}%";
          };
          "network" = {
            format-wifi = "󰖩 {signalStrength}%";
            format-ethernet = "󰈀";
            format-disconnected = "󰖪";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            format-linked = "󰈀 {ifname} (No IP)";
            max-length = 20;
          };
          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = "󰖁";
            format-icons = {
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "pamixer -t";
            on-scroll-up = "pamixer -i 1";
            on-scroll-down = "pamixer -d 1";
            on-click-right = "pavucontrol";
            tooltip-format = "{desc} - {volume}%";
            scroll-step = 2;
          };
          "battery" = {
            bat = "BAT0";
            adapter = "AC";
            interval = 30;
            states = {
              warning = 20;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰚥 {capacity}%";
            format-full = "󰁹 {capacity}%";
            format-alt = "{time}";
            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          "mpris" = {
            format = "{player_icon} {title}";
            format-paused = "⏸️ {title}";
            format-stopped = "󰝛";
            max-length = 50;
            player-icons = {
              default = "▶️";
              spotify = "󰓇";
              firefox = "󰈹";
              chromium = "󰊯";
            };
            status-icons = {
              paused = "⏸️";
            };
            tooltip-format = "{title} - {artist}";
          };
        };
      };
      style =
        let
          fonts = config.stylix.fonts;
        in
        ''
          * {
            border: none;
            border-radius: 8px;
            font-size: 12px;
            min-height: 0;
            font-family: "${fonts.monospace.name}", monospace;
          }
          window#waybar {
            background: transparent;
            color: #${scheme.base05};
          }
          window#waybar > box {
              background: transparent;
              border: none;
              box-shadow: none;
              padding: 0;
              margin: 0px 4px 0px 4px;
          }
          #workspaces button {
              padding: 0 10px;
              background: ${rgba scheme.base01 0.6};
              color: #${scheme.base04};
              border: 2px solid #${scheme.base02};
              border-radius: 8px;
              margin: 4px 2px;
              transition: all 0.3s ease-in-out;
              font-weight: bold;
              min-width: 40px;
              box-shadow: none;
          }
          #workspaces button.active {
              background: ${rgba scheme.base0B 0.4};
              color: #${scheme.base0B};
              border-color: #${scheme.base0B};
              box-shadow: 0 2px 8px ${rgba scheme.base0B 0.4};
          }
          #workspaces button.urgent {
            background: ${rgba scheme.base08 0.3};
            color: #${scheme.base08};
            border-color: #${scheme.base08};
          }
          #workspaces button:hover {
              background: ${rgba scheme.base02 0.8};
              border-color: #${scheme.base0D};
              box-shadow: 0 4px 12px ${rgba scheme.base00 0.3};
          }
          #tray,
          #cpu,
          #memory,
          #network,
          #custom-vpn,
          #pulseaudio,
          #backlight,
          #battery,
          #clock,
          #mpris {
            padding: 0 12px;
            margin: 4px 2px;
            background: ${rgba scheme.base01 0.6};
            border: 2px solid #${scheme.base02};
            border-radius: 8px;
            color: #${scheme.base05};
            font-weight: bold;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          }
          #custom-vpn.disconnected {
            background: ${rgba scheme.base08 0.3};
            border-color: #${scheme.base08};
            color: #${scheme.base08};
            animation: blink 2s infinite;
          }
          #mpris {
            background: ${rgba scheme.base01 0.6};
            border-color: #${scheme.base02};
            color: #${scheme.base0B};
            min-width: 200px;
            box-shadow: 0 2px 8px ${rgba scheme.base0B 0.2};
          }
          #battery.warning {
            background: ${rgba scheme.base09 0.3};
            border-color: #${scheme.base09};
            color: #${scheme.base09};
          }
          #battery.critical {
            background: ${rgba scheme.base08 0.3};
            border-color: #${scheme.base08};
            color: #${scheme.base08};
            animation: blink 2s infinite;
          }
          #battery.charging {
            background: ${rgba scheme.base0B 0.3};
            border-color: #${scheme.base0B};
            color: #${scheme.base0B};
          }
          #network.disconnected {
            background: ${rgba scheme.base08 0.3};
            border-color: #${scheme.base08};
            color: #${scheme.base08};
          }
          #pulseaudio.muted {
            background: ${rgba scheme.base03 0.3};
            border-color: #${scheme.base03};
            color: #${scheme.base04};
          }
          /* Animation matching Hyprland smoothness */
          @keyframes blink {
            0% {
              opacity: 1;
            }
            50% {
              opacity: 0.6;
            }
            100% {
              opacity: 1;
            }
          }
          /* Tooltip styling */
          tooltip {
            background: ${rgba scheme.base00 0.95};
            border: 2px solid #${scheme.base0D};
            border-radius: 8px;
            color: #${scheme.base05};
            padding: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
          }
          tooltip label {
            color: #${scheme.base05};
            font-size: 11px;
          }
          /* Special hover effects */
          #tray > *:hover,
          #cpu:hover,
          #memory:hover,
          #network:hover,
          #custom-vpn:hover,
          #pulseaudio:hover,
          #backlight:hover,
          #battery:hover,
          #clock:hover,
          #mpris:hover {
            background: ${rgba scheme.base02 0.8};
            border-color: #${scheme.base0D};
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
          }
        '';
    };
  };
}
