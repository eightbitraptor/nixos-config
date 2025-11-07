# Common configuration for all NixOS hosts
{ config, lib, pkgs, inputs, ... }:

{
  # Nix configuration
  nix = {
    # Enable flakes
    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      # Optimization
      auto-optimise-store = true;

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Security
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "@wheel" ];

      # Performance
      max-jobs = "auto";
      cores = 0; # Use all cores

      # Cleanup
      min-free = 5 * 1024 * 1024 * 1024; # 5GB
      max-free = 10 * 1024 * 1024 * 1024; # 10GB

      # Flake configuration
      accept-flake-config = true;
      keep-derivations = true;
      keep-outputs = true;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Flake registry
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Nix path
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  # System packages available to all users
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    wget
    curl
    git
    tmux
    htop
    tree
    file
    which
    gnumake

    # System tools
    pciutils
    usbutils
    lsof
    iotop
    strace

    # Archive tools
    zip
    unzip

    # Nix tools
    nix-output-monitor
    nh # Nix helper
  ];

  # Default editor - removed, now set per-user in home-manager
  # environment.variables = { };

  # Basic networking
  networking = {
    # Enable NetworkManager by default
    networkmanager.enable = lib.mkDefault true;

    # Firewall
    firewall = {
      enable = lib.mkDefault true;
      allowPing = lib.mkDefault true;
    };
  };

  # Time and locale
  time.timeZone = lib.mkDefault "Europe/London";

  i18n = {
    defaultLocale = lib.mkDefault "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  # Console configuration
  console = {
    keyMap = lib.mkDefault "uk";
  };

  # Sound (PipeWire by default)
  # Note: sound.enable has been deprecated in NixOS
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
  };

  # Enable firmware updates
  services.fwupd.enable = lib.mkDefault true;

  # SSH (disabled by default, enable per-host)
  services.openssh = {
    enable = lib.mkDefault false;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
    };
  };

  # Documentation
  documentation = {
    enable = lib.mkDefault true;
    man.enable = lib.mkDefault true;
    info.enable = lib.mkDefault true;
    doc.enable = lib.mkDefault false; # Disable to save space
  };

  # Security
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkDefault true;
      extraConfig = ''
        Defaults lecture = never
        Defaults env_reset
        Defaults timestamp_timeout=30
      '';
    };

    # Polkit
    polkit.enable = true;

    # App sandboxing
    unprivilegedUsernsClone = lib.mkDefault true;
  };

  # Boot configuration
  boot = {
    # Clean /tmp on boot
    tmp.cleanOnBoot = lib.mkDefault true;

    # Kernel
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Kernel parameters
    kernelParams = lib.mkDefault [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    # Enable SysRq keys
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      # Performance tuning
      "vm.swappiness" = lib.mkDefault 10;
      "vm.vfs_cache_pressure" = lib.mkDefault 50;
    };
  };

  # Enable thermald on laptops
  services.thermald.enable = lib.mkDefault (
    config.hardware.cpu.intel.updateMicrocode or false
  );

  # Enable periodic TRIM for SSDs
  services.fstrim.enable = lib.mkDefault true;

  # System state version (DO NOT CHANGE)
  # This should be set in the host-specific configuration
  # system.stateVersion = "24.05";
}