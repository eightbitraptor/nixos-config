{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ];

  # Performance optimization overlay for frequently used programs
  nixpkgs.overlays = [
    (final: prev: {
      # Optimize terminal emulator with Skylake-specific instructions
      kitty = prev.kitty.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -O3 -march=skylake -mtune=skylake";
      });

      # Optimize compositor for smooth performance
      swayfx = prev.swayfx.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -O3 -march=skylake -mtune=skylake";
      });

      # Optimize frequently used CLI tools
      ripgrep = prev.ripgrep.overrideAttrs (old: {
        RUSTFLAGS = (old.RUSTFLAGS or "") + " -C target-cpu=skylake -C opt-level=3";
      });

      fd = prev.fd.overrideAttrs (old: {
        RUSTFLAGS = (old.RUSTFLAGS or "") + " -C target-cpu=skylake -C opt-level=3";
      });

      bat = prev.bat.overrideAttrs (old: {
        RUSTFLAGS = (old.RUSTFLAGS or "") + " -C target-cpu=skylake -C opt-level=3";
      });
    })
  ];

  networking.hostName = "fern";
  # Time zone and locale settings inherited from modules/nixos/common.nix

  console = {
    useXkbConfig = true;
  };

  nix = {
    # Basic settings inherited from modules/nixos/common.nix
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";  # Override common.nix's 30d default
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;  # Hide boot menu unless key is pressed
    };

    # Silent boot configuration for clean boot experience
    consoleLogLevel = 3;
    initrd.verbose = false;

    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  networking.networkmanager.enable = true;

  # Disable network-online blocking for faster boot
  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
    options = "ctrl:nocaps";
  };

  # Japanese Input Method Editor (IME) configuration
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc           # Japanese input using Google's Mozc engine
        fcitx5-gtk            # GTK integration
        qt6Packages.fcitx5-configtool     # GUI configuration tool
      ];
      waylandFrontend = true;  # Better Wayland support
    };
  };

  users.users.mattvh = {
    isNormalUser = true;
    description = "Matt Valentine-House";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "docker"
    ];
    shell = pkgs.fish;
  };

  # Fish is now enabled through the user configuration
  programs.fish.enable = true;  # System-wide fish support
  environment.shells = [ pkgs.fish ];

  # PipeWire base configuration inherited from modules/nixos/common.nix
  services.pipewire.wireplumber.enable = true;  # Additional for desktop

  # Polkit enabled in modules/nixos/common.nix

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      swaybg
      grim
      slurp
      wl-clipboard
      fuzzel
      waybar
    ];
    extraSessionCommands = ''
      # Initialize DBus first to prevent startup delays
      systemctl --user import-environment
      dbus-update-activation-environment --systemd --all

      # Wayland environment variables
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway

      # Input Method Editor (IME) environment variables for fcitx5
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export XMODIFIERS=@im=fcitx
      export INPUT_METHOD=fcitx
      export GLFW_IM_MODULE=ibus  # Some apps work better with ibus module
    '';
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Base packages inherited from modules/nixos/common.nix:
    # vim, wget, curl, git, htop, tree, file, unzip, zip, gnumake, tmux

    # Desktop-specific packages
    btop  # Enhanced htop for desktop use
    pkg-config
    openssl

    kitty  # Terminal emulator
    fzf
    ripgrep
    fd
    bat

    # Hardware monitoring
    lm_sensors
    acpi
    powertop

    # Media tools
    imagemagick
    ffmpeg

    # Fonts (also specified in fonts.packages below)
    pkgs.jetbrains-mono
    (pkgs.nerd-fonts.jetbrains-mono)
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
    pkgs.font-awesome
    pkgs.cascadia-code

    # Development
    python3
    python3Packages.pip
    pipx

    # Browser
    firefox

    # Waybar battery monitor script
    (pkgs.python3.pkgs.buildPythonApplication rec {
      pname = "waybar-battery";
      version = "1.0.0";
      format = "other";

      propagatedBuildInputs = with pkgs.python3.pkgs; [
        pydbus
        pygobject3
      ];

      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/waybar-battery << 'EOF'
#!/usr/bin/python3

import json
import os
import sys

from gi.repository import GLib
from pydbus import SystemBus

bat_levels = {
        9: 'critical',
        12: 'warning'
        }

bat_states = {
        0: 'unknown',
        1: 'charging',
        2: 'discharging',
        3: 'empty',
        4: 'full',
        5: 'charge_pending',
        6: 'discharge_pending'
        }

CSS_CLASS_DISCONNECTED = 'disconnected'

class BatteryWatcher:
    loop = None
    dbus = None
    upower = None
    bat_name = None
    bat_obj_path = None
    bat = None
    bat_design_capacity = None
    bat_percentage_of_design = None
    bat_percentage_of_current = None
    bat_state = None

    def __init__(self, battery_name="BAT0"):
        self.loop = GLib.MainLoop()
        self.bat_name = battery_name
        self.dbus = SystemBus()
        self.upower = self.dbus.get('org.freedesktop.UPower',
                '/org/freedesktop/UPower')
        self.bat_obj_path = '/org/freedesktop/UPower/devices/battery_{}'.format(self.bat_name)

    def run(self):
        if self.bat_obj_path in self.upower.EnumerateDevices():
            self.upower.onDeviceRemoved = self.onDeviceRemoved
            self.add_battery()
        else:
            self.upower.onDeviceAdded = self.onDeviceAdded

        self.export_state()
        self.loop.run()

    def add_battery(self):
        self.bat = self.dbus.get(
           'org.freedesktop.UPower', self.bat_obj_path)

        self.bat.onPropertiesChanged = self.onPropertiesChanged

        self.bat_design_capacity = self.bat.EnergyFullDesign
        self.bat_percentage_of_design = \
           (self.bat.Energy / self.bat_design_capacity) * 100
        self.bat_percentage_of_current = self.bat.Percentage
        self.bat_state = self.bat.State

    def remove_battery(self):
        self.bat.onPropertiesChanged = None
        self.bat = None

    def export_state(self):
        if self.bat:
            percentage = int(round(self.bat_percentage_of_current))
            text = str(int(round(self.bat_percentage_of_design))) + "%"
            css_classes = [ bat_states[self.bat.State] ]

            for level in bat_levels.keys():
                if self.bat_percentage_of_design <= level:
                    css_classes.append(bat_levels[level])
                    break
        else:
            percentage = 0
            text = "N/A"
            css_classes = [ CSS_CLASS_DISCONNECTED ]

        output = { 'text': text,
                   'percentage': percentage,
                   'class' : css_classes }

        try:
            print(json.dumps(output), flush=True)
        except BrokenPipeError:
            self.loop.quit()

    def onPropertiesChanged(self, interface_name, changed_properties,
                            invalidated_properties):
        update = False

        if 'Energy' in changed_properties:
            self.bat_percentage_of_design = \
                    (changed_properties['Energy'] / self.bat_design_capacity) \
                    * 100
            update = True
        if 'Percentage' in changed_properties:
            self.bat_percentage_of_current = changed_properties['Percentage']
        if 'State' in changed_properties:
            self.bat_state = changed_properties['State']
            update = True

        if update:
            self.export_state()

    def onDeviceAdded(self, object_path):
        if object_path == self.bat_obj_path:
            self.upower.onDeviceAdded = None
            self.upower.onDeviceRemoved = self.onDeviceRemoved
            self.add_battery()
            self.export_state()

    def onDeviceRemoved(self, object_path):
        if object_path == self.bat_obj_path:
            self.upower.onDeviceAdded = self.onDeviceAdded
            self.upower.onDeviceRemoved = None
            self.remove_battery()
            self.export_state()

def main(argv=None):
    battery_name = "BAT0"

    if len(argv) == 2:
        battery_name = argv[1]
    elif len(argv) > 2:
        print("Error: Too many arguments!", file=sys.stderr)
        return os.EX_USAGE

    try:
        BatteryWatcher(battery_name).run()
    except KeyboardInterrupt:
        return 0
    except BrokenPipeError:
        return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
EOF
        chmod +x $out/bin/waybar-battery
      '';
    })
  ];

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      (nerd-fonts.jetbrains-mono)
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      cascadia-code
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
      # Optimize font cache for faster startup
      cache32Bit = true;
      allowBitmaps = false;
      useEmbeddedBitmaps = false;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ReGreet configuration for modern Wayland-native greeter
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = "/usr/share/backgrounds/fern.jpg";
        fit = "Cover";
      };
      GTK = {
        theme_name = lib.mkForce "Adwaita-dark";
        cursor_theme_name = "Adwaita";
        icon_theme_name = "Adwaita";
        font_name = lib.mkDefault "JetBrains Mono 11";
      };
    };
  };

  # Display Manager - Wayland-native greetd with ReGreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  # Enable dconf for GTK applications (including ReGreet)
  programs.dconf.enable = true;

  services.printing.enable = false;

  system.stateVersion = "24.05";
}
