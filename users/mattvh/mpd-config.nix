{ config, lib, pkgs, ... }:

{
  # MPD Configuration with Last.fm Scrobbling Support
  #
  # The password is stored securely outside Nix store at:
  # ~/.config/mpdscribble/lastfm-password

  # MPD - Music Player Daemon
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.xdg.dataHome}/mpd/playlists";

    # Network configuration
    network = {
      listenAddress = "127.0.0.1";  # Local only, change to "any" for network access
      port = 6600;
    };

    # PipeWire audio output
    extraConfig = ''
      # PipeWire output
      audio_output {
        type            "pipewire"
        name            "PipeWire Output"
      }

      # Database and state
      db_file            "~/.local/share/mpd/database"
      state_file         "~/.local/share/mpd/state"
      sticker_file       "~/.local/share/mpd/sticker.sql"

      # Logs
      log_level          "default"

      # Automatic music database update
      auto_update        "yes"
      auto_update_depth  "3"

      # Replaygain
      replaygain         "auto"
      replaygain_preamp  "0"
      volume_normalization "no"

      # Performance
      filesystem_charset "UTF-8"

      # Buffer settings for smooth playback
      audio_buffer_size  "4096"
      buffer_before_play "10%"
    '';
  };

  services.mpdscribble = {
    enable = false;  # Set to true after running setup script
    endpoints = {
      "last.fm" = {
        username = "theshadowaspect";
        passwordFile = "${config.xdg.configHome}/mpdscribble/lastfm-password";
      };
    };
  };

  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/Music 0755 ${config.home.username} users -"
    "d ${config.xdg.dataHome}/mpd 0755 ${config.home.username} users -"
    "d ${config.xdg.dataHome}/mpd/playlists 0755 ${config.home.username} users -"
    "d ${config.xdg.configHome}/mpdscribble 0700 ${config.home.username} users -"
  ];

  home.packages = with pkgs; [
    mpc
    rmpc
    cava
  ];

  xdg.configFile."rmpc/config.ron".source = ../../configs/rmpc/config.ron;
  xdg.configFile."rmpc/themes/theme.ron".source = ../../configs/rmpc/theme.ron;
 }
