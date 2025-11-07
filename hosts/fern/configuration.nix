{ config, pkgs, inputs, ... }:

{
  imports = [ ];

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

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
    options = "ctrl:nocaps";
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
      mako
      fuzzel
      waybar
      light
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
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
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.printing.enable = false;

  system.stateVersion = "24.05";
}
