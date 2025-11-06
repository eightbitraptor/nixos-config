{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    checkConfig = false;  # Temporarily disable config validation

    config = {
      modifier = "Mod4";

      fonts = {
        names = [ "Noto Sans" ];
        size = 12.0;
      };

      terminal = "kitty";
      menu = "fuzzel";

      floating.modifier = "Mod4";
      focus.followMouse = false;

      gaps = {
        inner = 4;
        outer = 4;
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "ctrl:nocaps";
        };

        "18003:1:foostan_Corne" = {
          xkb_layout = "us";
        };

        "12901:5:Yushakobo_Cornelius" = {
          xkb_layout = "us";
        };

        "type:touchpad" = {
          dwt = "enabled";
          dwtp = "enabled";
          tap = "enable";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
        };
      };

      output = {
        eDP-1 = {
          pos = "0 0";
          scale = "1";
          bg = "/usr/share/backgrounds/fern.jpg fill";
        };
        "*" = {
          adaptive_sync = "on";
        };
      };

      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in {
        # Volume and brightness with Menu key
        "Menu+Left" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "Menu+Right" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "Menu+Up" = "exec light -T 1.4";
        "Menu+Down" = "exec light -T 0.72";

        # Basic bindings
        "${mod}+Return" = "exec kitty";
        "${mod}+q" = "kill";
        "${mod}+d" = "exec fuzzel";

        # Focus navigation
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        # Move windows
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        # Move workspace to output
        "${mod}+Shift+o" = "move workspace to output left";

        # Layout
        "${mod}+b" = "split h";
        "${mod}+v" = "split v";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+t" = "layout tabbed";
        "${mod}+s" = "layout stacked";
        "${mod}+e" = "layout toggle split";

        # Floating
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";

        # Workspaces
        "${mod}+1" = "workspace 1";
        "${mod}+2" = "workspace 2";
        "${mod}+3" = "workspace 3";
        "${mod}+4" = "workspace 4";
        "${mod}+5" = "workspace 5";
        "${mod}+6" = "workspace 6";
        "${mod}+7" = "workspace 7";
        "${mod}+8" = "workspace 8";
        "${mod}+9" = "workspace 9";
        "${mod}+0" = "workspace 10";

        "${mod}+Tab" = "workspace next";
        "${mod}+Shift+Tab" = "workspace prev";

        # Move to workspace
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9";
        "${mod}+Shift+0" = "move container to workspace 10";

        # Reload/restart
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";

        # Audio controls
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute 0 toggle";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";

        # Mode triggers
        "${mod}+Ctrl+v" = ''mode "Volume (d) down, (u) up, (m) toggle mute, (p) pavucontrol"'';
        "${mod}+r" = ''mode "resize"'';
        "${mod}+Ctrl+BackSpace" = ''mode "Screens (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown"'';
        "${mod}+p" = ''mode "1 selected, 2 whole, 3 selected clipboard, 4 whole clipboard"'';
      };

      modes = {
        "Volume (d) down, (u) up, (m) toggle mute, (p) pavucontrol" = {
          "d" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
          "u" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
          "m" = "exec --no-startup-id pactl set-sink-mute 0 toggle, mode default";
          "p" = "exec --no-startup-id pavucontrol, mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
        };

        "resize" = {
          "h" = "resize shrink width 10 px or 10 ppt";
          "j" = "resize grow height 10 px or 10 ppt";
          "k" = "resize shrink height 10 px or 10 ppt";
          "l" = "resize grow width 10 px or 10 ppt";
          "Left" = "resize shrink width 10 px or 10 ppt";
          "Down" = "resize grow height 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";
          "Return" = "mode default";
          "Escape" = "mode default";
        };

        "Screens (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown" = {
          "l" = "exec --no-startup-id $HOME/.config/sway/swayexit lock, mode default";
          "e" = "exec --no-startup-id $HOME/.config/sway/swayexit logout, mode default";
          "s" = "exec --no-startup-id $HOME/.config/sway/swayexit suspend, mode default";
          "h" = "exec --no-startup-id $HOME/.config/sway/swayexit hibernate, mode default";
          "r" = "exec --no-startup-id $HOME/.config/sway/swayexit reboot, mode default";
          "Shift+s" = "exec --no-startup-id $HOME/.config.sway/swayexit shutdown, mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
        };

        "1 selected, 2 whole, 3 selected clipboard, 4 whole clipboard" = {
          "1" = ''exec 'grim -g "$(slurp)" ~/Pictures/ps_$(date +"%Y%m%d%H%M%S").png', mode default'';
          "2" = ''exec 'grim ~/Pictures/ps_$(date +"%Y%m%d%H%M%S").png', mode default'';
          "3" = ''exec 'grim -g "$(slurp)" - | wl-copy', mode default'';
          "4" = ''exec 'grim - | wl-copy', mode default'';
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      bars = [{
        command = "waybar";
      }];

      window = {
        border = 2;
      };

      floating.criteria = [
        { app_id = "mpv"; }
        { window_role = "pop-up"; }
        { window_role = "About"; }
        { app_id = "Thunar"; title = "^Copying.*"; }
      ];

      startup = [
        { command = "wal -i /usr/share/backgrounds/senjougahara.jpg"; always = false; }
        { command = "dbus-update-activation-environment --all"; always = false; }
        {
          command = ''
            swayidle -w \
              idlehint 300 \
              timeout 300 'swaylock --daemonize' \
              timeout 300 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on, output * enable"' \
              before-sleep 'swaylock --daemonize' \
              lock 'swaylock --daemonize' \
              after-resume 'swaymsg "output * dpms on, output * enable"' \
              unlock 'swaymsg "output * dpms on, output * enable"'
          '';
          always = false;
        }
      ];
    };

    extraConfig = ''
      include /etc/sway/config.d/*

      blur enable
      shadows enable
      shadow_blur_radius 50
      shadow_offset 0 0
      corner_radius 6
      default_dim_inactive 0.25

      default_border pixel 2
    '';
  };

  # Waybar configuration - exactly as in waybar directory
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "bottom";
        position = "bottom";
        height = "20";
        spacing = 10;

        modules-left = ["sway/workspaces" "sway/mode"];
        modules-center = ["clock" "custom/weather"];
        modules-right = ["pulseaudio" "tray"];

        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };

        "sway/workspaces" = {
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        "mpd" = {
          server = "127.0.0.1";
          port = 6600;
          tooltip = false;
          exec-if = "pgrep mpd";
          format = "{stateIcon} {consumeIcon}{randomIcon}{artist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ";
          format-disconnected = "";
          format-stopped = "";
          unknown-tag = "N/A";
          interval = 2;
          max-length = 60;
          consume-icons = {
            on = " ";
          };
          random-icons = {
            on = "<span color=\"#f53c3c\"></span> ";
            off = " ";
          };
          repeat-icons = {
            on = " ";
          };
          single-icons = {
            on = "1 ";
          };
          state-icons = {
            paused = "";
            playing = "";
          };
        };

        "clock" = {
          timezone = "Europe/London";
          interval = 60;
          tooltip = false;
          format = "{:%A %d %B %Y %H:%M}";
          on-click-right = "gsimplecal";
        };

        "battery" = {
          tooltip = false;
          states = {
            good = 95;
            warning = 20;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        "custom/bat0" = {
          states = {
            good = 95;
            warning = 15;
            critical = 10;
          };
          exec = "~/.config/waybar/modules/battery.py BAT0";
          return-type = "json";
          format = "{} {percentage}% {icon}";
          format-icons = ["" "" "" "" ""];
          tooltip = false;
          on-click-right = "kitty --start-as normal bash -i bat";
        };

        "network" = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "Disconnected ⚠";
          on-click-right = "kitty --start-as normal bash -ci nmtui";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        "pulseaudio" = {
          tooltip = false;
          format = "{volume}% {icon}";
          format-muted = " {format_source}";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click-right = "pavucontrol";
          on-click-middle = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        "bluetooth" = {
          format = "{icon}";
          format-alt = "bluetooth: {status}";
          interval = 30;
          format-icons = {
            enabled = "";
            disabled = "";
          };
          tooltip-format = "{status}";
        };

        "custom/weather" = {
          format = "{}";
          interval = 300;
          return-type = "json";
          exec = "curl -s 'https://wttr.in/Canterbury?format=1' |jq --unbuffered --compact-output -M -R '{text:.}'";
          exec-if = "ping wttr.in -c1";
          on-click-right = "kitty -e bash -ci ~/bin/wttr";
        };

        "tray" = {
          # tray is configured through the style
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Cascadia Mono NF;
        font-weight: 600;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(12,13,12,0.9);
        color: white;
      }

      #workspaces {
        background-color: #1d202e;
        margin: 5px;
        margin-left: 6px;
        border-radius: 5px;
      }
      #workspaces button {
        padding: 2px 8px;
        color: #fff;
      }

      #workspaces button.focused {
        color: #24283b;
        background-color: #7aa2f7;
        border-radius: 5px;
      }

      #workspaces button:hover {
        background-color: #7dcfff;
        color: #24283b;
        border-radius: 5px;
      }

      #custom-date,
      #clock,
      #battery,
      #pulseaudio,
      #network {
        background-color: #1d202e;
        padding: 2px 10px;
        margin: 5px 0px;
      }

      #custom-date {
        color: #7dcfff;
      }

      #custom-power {
        color: #24283b;
        background-color: #db4b4b;
        border-radius: 5px;
        margin-right: 10px;
        margin-top: 5px;
        margin-bottom: 5px;
        margin-left: 0px;
        padding: 3px 10px;
      }

      #clock {
        color: #b48ead;
        border-radius: 0px 5px 5px 0px;
        margin-right: 6px;
      }

      #battery {
        color: #9ece6a;
      }

      #battery.charging {
        color: #9ece6a;
      }

      #battery.warning:not(.charging) {
        background-color: #f7768e;
        color: #24283b;
        border-radius: 5px 5px 5px 5px;
      }

      #network {
        color: #f7768e;
        border-radius: 5px 0px 0px 5px;
      }

      #pulseaudio {
        color: #e0af68;
      }

      #temperature {
        background-color: #24283b;
        margin: 5px 0;
        padding: 0 10px;
        border-top-left-radius: 5px;
        border-bottom-left-radius: 5px;
        color: #82e4ff;
      }

      #disk {
        color: #b9f27c;
        margin: 5px 0;
        padding-right: 10px;
        background-color: #24283b;
        border-top-right-radius: 5px;
        border-bottom-right-radius: 5px;
        margin-right: 3px;
      }

      #memory {
        margin-left: 5px;
        background: #2a3152;
        margin: 5px 0;
        padding: 0 10px;
        margin-left: 3px;
        border-top-left-radius: 5px;
        border-bottom-left-radius: 5px;
        color: #ff9e64;
      }

      #cpu {
        margin: 5px 0;
        padding: 0 10px;
        background-color: #2a3152;
        color: #ff7a93;
        border-top-right-radius: 5px;
        border-bottom-right-radius: 5px;
        margin-right: 6px;
      }

      #tray {
        background-color: #455085;
        margin: 5px;
        margin-left: 0px;
        margin-right: 6px;
        border-radius: 5px;
        padding: 0 10px;
      }

      #tray > * {
        padding: 0 2px;
        margin: 0 2px;
      }
    '';
  };

  # Copy the battery.py script to the waybar modules directory
  home.file.".config/waybar/modules/battery.py" = {
    source = ../../configs/waybar/modules/battery.py;
    executable = true;
  };
}
