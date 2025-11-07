{ config, lib, pkgs, ... }:

let
  # Template substitutions for files that need Nix paths
  kittyConfig = pkgs.replaceVars ../../configs/kitty/kitty.conf.template {
    FISH = "${pkgs.fish}/bin/fish";
  };
  tmuxConf = pkgs.replaceVars ../../configs/tmux/tmux.conf.template {
    FISH = "${pkgs.fish}/bin/fish";
    TMUX_CONF = "$HOME/.config/tmux/tmux.conf"; # Updated to point to final location
  };
in
{
  imports = [ ./sway-home.nix ];

  home.username = "mattvh";
  home.homeDirectory = "/home/mattvh";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";

    # Docker settings
    DOCKER_BUILDKIT = "1";
    COMPOSE_DOCKER_CLI_BUILD = "1";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
  ];

  home.packages = with pkgs; [
    # Shell utilities
    bat
    coreutils
    fd
    findutils
    fzf
    gawk
    gnugrep
    gnused
    ripgrep

    # File management
    ranger
    tree

    # System monitoring
    htop
    iotop
    lm_sensors
    acpi
    powertop

    # Network tools
    curl
    wget
    nmap
    whois
    dig
    traceroute

    # Archive tools
    zip
    unzip
    p7zip
    unrar

    # Data processing
    jq

    # Version control
    git
    git-lfs
    git-extras
    git-filter-repo
    lazygit
    tig
    delta

    # Build tools
    cmake
    gnumake
    ninja
    meson
    autoconf
    automake
    libtool
    pkg-config

    # Debugging
    gdb
    lldb
    valgrind
    strace
    ltrace

    # Documentation
    pandoc
    graphviz

    # Container tools
    docker-compose
    podman-compose

    # Database tools
    sqlite

    # Programming languages and tools
    # Python
    (python311.withPackages (ps: with ps; [
      pip
      virtualenv
      setuptools
    ]))
    pipx

    # Ruby
    ruby_3_4

    # Node.js
    nodejs_20
    yarn
    pnpm

    # Rust
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    # C/C++
    (lib.hiPrio clang)
    clang-tools
    gcc

    # Nix tools
    nix-diff
    nixpkgs-fmt
    nixfmt-classic
    statix
    deadnix

    # Performance analysis
    flamegraph
    linuxPackages.perf

    # Security tools
    wireshark
    tcpdump
    nmap
    mitmproxy

    # Other utilities
    neofetch
    tmux
    kitty
    fish

    # Multimedia
    imagemagick
    ffmpeg
    mpv

    # CD ripping tools
    abcde
    cdparanoia
    lame
    flac

    # Audio control
    pavucontrol

    # Additional languages
    zig

    # Vim/Neovim with plugins
    (vim.customize {
      name = "vim";
      vimrcConfig = {
        customRC = builtins.readFile ../../configs/vim/vimrc;
      };
    })

    # Fish plugins
    fishPlugins.pure
    fishPlugins.done
    fishPlugins.foreign-env
  ];

  # Direct config file linking using home.file and xdg.configFile
  # This gives you direct control over your dotfiles

  # Git config - directly link the gitconfig file
  home.file.".gitconfig".source = ../../configs/git/gitconfig;

  # GPG config
  home.file.".gnupg/gpg.conf".source = ../../configs/gpg/gpg.conf;

  # Vim config - link vimrc directly (plugins handled above via package)
  home.file.".vimrc".source = ../../configs/vim/vimrc;
  home.file.".vim/autoload/plug.vim".source = ../../configs/vim/autoload/plug.vim;

  # XDG config files
  xdg = {
    enable = true;

    configFile = {
      # Fish shell config and plugins
      "fish/config.fish".source = ../../configs/fish/config.fish;
      "fish/fish_plugins".source = ../../configs/fish/fish_plugins;

      # Kitty terminal (using processed template)
      "kitty/kitty.conf" = {
        text = builtins.readFile kittyConfig;
      };

      # Tmux (using processed template)
      "tmux/tmux.conf" = {
        text = builtins.readFile tmuxConf;
      };

      # Neovim config
      "nvim/init.lua".source = ../../configs/nvim/init.lua;

      # Sway and related configs (these will be handled in sway-home-refactored.nix)
      # Just linking the swayexit script here as it's referenced
      "sway/swayexit" = {
        source = ../../configs/sway/swayexit;
        executable = true;
      };

      # Waybar battery module
      "waybar/modules/battery.py" = {
        source = ../../configs/waybar/modules/battery.py;
        executable = true;
      };

      # Bat configuration
      "bat/config".source = ../../configs/bat/config;
    };
  };

  # Essential programs that need Home Manager configuration
  # (keeping minimal to retain functionality while using direct configs)

  # GPG agent
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    defaultCacheTtl = 600;
    maxCacheTtl = 7200;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # FZF is configured through shell config files

  # Bat is configured through config file
}
