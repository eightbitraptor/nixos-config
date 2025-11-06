{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./sway.nix
    ./dev.nix
    ./editors.nix
    ./terminal.nix
  ];

  # Main user configuration using our custom module
  userEnvironment.users.matt = {
    # Session variables
    sessionVariables = {
      EDITOR = "vim";
      BROWSER = "firefox";
      TERMINAL = "alacritty";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
    };

    # Base packages (unwrapped)
    packages = with pkgs; [
      # Browsers
      firefox
      chromium

      # Communication
      signal-desktop

      # File management
      xdg-utils
      ranger
      p7zip
      unrar

      # Media
      mpv
      feh
      spotify
      zathura

      # Audio/Display management
      pavucontrol
      brightnessctl
      wdisplays

      # Clipboard
      clipman
      wl-clipboard

      # Recording
      wf-recorder
      obs-studio

      # CD ripping
      abcde
      cdparanoia
      lame
      flac

      # Custom scripts
      (pkgs.writeShellScriptBin "install-pywal" ''
        pipx install pywal
      '')
    ];

    # Activation scripts for configs that must exist in specific locations
    activationScripts = {
      sshConfig = ''
        # Create SSH directory with correct permissions
        mkdir -p $HOME/.ssh
        chmod 700 $HOME/.ssh

        # Copy SSH config from external file
        cp ${../../configs/ssh/config} $HOME/.ssh/config
        chmod 600 $HOME/.ssh/config
      '';
      
      gpgConfig = let
        gpgAgentConf = pkgs.substituteAll {
          src = ../../configs/gpg/gpg-agent.conf.template;
          PINENTRY = "${pkgs.pinentry-gtk2}/bin/pinentry";
        };
      in ''
        # Create GPG directory with correct permissions
        mkdir -p $HOME/.gnupg
        chmod 700 $HOME/.gnupg

        # Copy GPG configs from external files
        cp ${../../configs/gpg/gpg.conf} $HOME/.gnupg/gpg.conf
        chmod 600 $HOME/.gnupg/gpg.conf

        cp ${gpgAgentConf} $HOME/.gnupg/gpg-agent.conf
        chmod 600 $HOME/.gnupg/gpg-agent.conf
      '';
      
      userDirs = ''
        # Create standard XDG directories
        mkdir -p $HOME/Documents
        mkdir -p $HOME/Downloads
        mkdir -p $HOME/Music
        mkdir -p $HOME/Pictures
        mkdir -p $HOME/Videos
        mkdir -p $HOME/Desktop
        mkdir -p $HOME/Public
        mkdir -p $HOME/Templates
        
        # Create user-dirs.dirs config
        cat > $HOME/.config/user-dirs.dirs << 'EOF'
        XDG_DESKTOP_DIR="$HOME/Desktop"
        XDG_DOWNLOAD_DIR="$HOME/Downloads"
        XDG_TEMPLATES_DIR="$HOME/Templates"
        XDG_PUBLICSHARE_DIR="$HOME/Public"
        XDG_DOCUMENTS_DIR="$HOME/Documents"
        XDG_MUSIC_DIR="$HOME/Music"
        XDG_PICTURES_DIR="$HOME/Pictures"
        XDG_VIDEOS_DIR="$HOME/Videos"
        EOF
      '';
      
      gitCredentials = ''
        # Setup git credentials helper
        # Note: actual credentials should be added manually
        touch $HOME/.git-credentials
        chmod 600 $HOME/.git-credentials
      '';
    };
  };
}
