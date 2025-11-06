{ config, lib, pkgs, ... }:

let
  # Sway configuration with path substitutions
  swayConfig = pkgs.substituteAll {
    src = ../../configs/sway/config.template;
    ALACRITTY = "${pkgs.alacritty}/bin/alacritty";
    FUZZEL = "${pkgs.fuzzel}/bin/fuzzel";
    GRIM = "${pkgs.grim}/bin/grim";
    SLURP = "${pkgs.slurp}/bin/slurp";
    WL_COPY = "${pkgs.wl-clipboard}/bin/wl-copy";
    WL_PASTE = "${pkgs.wl-clipboard}/bin/wl-paste";
    WAYBAR = "${pkgs.waybar}/bin/waybar";
    MAKO = "${pkgs.mako}/bin/mako";
    SWAYIDLE = "${pkgs.swayidle}/bin/swayidle";
    SWAYLOCK = "${pkgs.swaylock}/bin/swaylock";
    CLIPMAN = "${pkgs.clipman}/bin/clipman";
    NM_APPLET = "${pkgs.networkmanagerapplet}/bin/nm-applet";
  };

  # Waybar configuration
  waybarConfig = pkgs.writeText "waybar-config.json" (builtins.readFile ../../configs/waybar/config.json);
  waybarStyle = pkgs.writeText "waybar-style.css" (builtins.readFile ../../configs/waybar/style.css);

  # Mako configuration
  makoConfig = pkgs.writeText "mako-config" (builtins.readFile ../../configs/mako/config);

  # Fuzzel configuration
  fuzzelConfig = pkgs.writeText "fuzzel.ini" (builtins.readFile ../../configs/fuzzel/fuzzel.ini);

  # Swaylock configuration
  swaylockConfig = pkgs.writeText "swaylock-config" (builtins.readFile ../../configs/swaylock/config);

  # Create wrapped sway with all configurations
  swayWrapped = pkgs.symlinkJoin {
    name = "sway-wrapped";
    paths = [ pkgs.swayfx ];  # Using swayfx as specified in the original config
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mkdir -p $out/etc/sway
      cp ${swayConfig} $out/etc/sway/config
      
      wrapProgram $out/bin/sway \
        --set XDG_CONFIG_HOME "$out/etc" \
        --set SDL_VIDEODRIVER wayland \
        --set QT_QPA_PLATFORM wayland \
        --set QT_WAYLAND_DISABLE_WINDOWDECORATION 1 \
        --set _JAVA_AWT_WM_NONREPARENTING 1 \
        --set MOZ_ENABLE_WAYLAND 1 \
        --set XDG_SESSION_TYPE wayland \
        --set XDG_CURRENT_DESKTOP sway
    '';
  };

in
{
  userEnvironment.users.matt = {
    wrappedPackages = [
      # Sway window manager
      {
        package = swayWrapped;
        name = "sway";
      }

      # Waybar
      {
        package = pkgs.waybar;
        configDir = pkgs.symlinkJoin {
          name = "waybar-config";
          paths = [
            (pkgs.writeTextDir "waybar/config" (builtins.readFile waybarConfig))
            (pkgs.writeTextDir "waybar/style.css" (builtins.readFile waybarStyle))
          ];
        };
      }

      # Mako notifications
      {
        package = pkgs.mako;
        configDir = pkgs.writeTextDir "mako/config" (builtins.readFile makoConfig);
      }

      # Fuzzel launcher
      {
        package = pkgs.fuzzel;
        configDir = pkgs.writeTextDir "fuzzel/fuzzel.ini" (builtins.readFile fuzzelConfig);
      }

      # Swaylock
      {
        package = pkgs.swaylock;
        configDir = pkgs.writeTextDir "swaylock/config" (builtins.readFile swaylockConfig);
      }
    ];

    # Packages that don't need wrapping
    packages = with pkgs; [
      # Sway utilities
      swayidle
      swaybg
      swaytools
      sway-contrib.grimshot
      
      # Screenshot tools
      grim
      slurp
      
      # Clipboard
      wl-clipboard
      clipman
      
      # Display management
      wdisplays
      kanshi
      
      # Notifications
      libnotify
      
      # Screen recording
      wf-recorder
      
      # Utilities needed by sway config
      light  # For brightness control
      networkmanagerapplet
    ];
  };
}
