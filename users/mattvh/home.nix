{ config, lib, pkgs, ... }:

let
  gitConfig = builtins.readFile ../../configs/git/gitconfig;
  vimrc = builtins.readFile ../../configs/vim/vimrc;
  fishConfig = builtins.readFile ../../configs/fish/config.fish;
  kittyConfig = pkgs.replaceVars ../../configs/kitty/kitty.conf.template {
    FISH = "${pkgs.fish}/bin/fish";
  };
  tmuxConf = pkgs.replaceVars ../../configs/tmux/tmux.conf.template {
    FISH = "${pkgs.fish}/bin/fish";
    TMUX_CONF = "$out";
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
    VISUAL = "vim";  # Some programs use VISUAL instead of EDITOR
    BROWSER = "firefox";
    TERMINAL = "kitty";
    # XDG variables removed - home-manager sets these automatically

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
    #mtr

    # Archive tools
    zip
    unzip
    p7zip
    unrar

    # Data processing
    jq

    # Version control
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
    # direnv is configured via programs.direnv below
    nix-diff
    nixpkgs-fmt
    nixfmt-classic
    statix
    deadnix

    # Performance analysis
    flamegraph
    linuxPackages.perf

    # Security tools (only those available in nixpkgs)
    wireshark
    tcpdump
    nmap
    mitmproxy

    # Other utilities
    neofetch
    tmux

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
    pavucontrol  # Works with PipeWire

    # Additional languages
    zig
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "eightbitraptor";
    userEmail = "matt@eightbitraptor.com";
    extraConfig = {
      core = {
        editor = "vim";
        pager = "delta";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.tool = "vimdiff";
      diff.colorMoved = "default";

      # Delta configuration
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Tokyo Night";
      };

      interactive.diffFilter = "delta --color-only";

      # Include the external gitconfig
      include.path = toString (pkgs.writeText "gitconfig-external" gitConfig);
    };
  };

  # Fish shell
  programs.fish = {
    enable = true;
    interactiveShellInit = fishConfig;

    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "foreign-env"; src = pkgs.fishPlugins.foreign-env.src; }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.3";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
    ];
  };

  # Kitty terminal
  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile kittyConfig;
  };

  # Tmux
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    shortcut = "a";
    terminal = "screen-256color";

    extraConfig = builtins.readFile tmuxConf;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      yank
      pain-control
      tmux-fzf
    ];
  };

  # Vim
  programs.vim = {
    enable = true;
    extraConfig = vimrc;

    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-polyglot
      tokyonight-nvim
      vim-airline
      vim-airline-themes
      vim-fern
      fzf-vim
      vim-rooter
      vim-fugitive
      vim-gitgutter
      vim-rhubarb
      vim-surround
      vim-commentary
      vim-unimpaired
      vim-repeat
      vim-abolish
      vim-sleuth
      tabular
      vim-multiple-cursors
      vim-easymotion
      vim-sneak
      tagbar
      supertab
      rust-vim
      vim-ruby
      vim-rails
      vim-endwise
      vim-go
      vim-javascript
      typescript-vim
      vim-jsx-pretty
      vim-markdown
      vim-nix
      vim-tmux-navigator
      vim-test
      vim-dispatch
      vim-vinegar
      vim-which-key
      vim-startify
      vim-devicons
      ultisnips
      vim-snippets
    ];
  };

  # Neovim
  programs.neovim = {
    enable = true;
    viAlias = false;
    vimAlias = false;
    withPython3 = true;
    withNodeJs = false;
    withRuby = true;

    extraConfig = ''
      " Source vim configuration
      ${vimrc}

      " Additional neovim-specific configuration
      if has('nvim')
        " Enable lua plugins if needed
        lua << EOF
        -- Neovim specific lua config
        EOF
      endif
    '';

    plugins = with pkgs.vimPlugins; [
      # Same plugins as vim, already listed above
      vim-sensible
      vim-polyglot
      tokyonight-nvim
      vim-airline
      vim-airline-themes
      vim-fern
      fzf-vim
      vim-rooter
      vim-fugitive
      vim-gitgutter
      vim-rhubarb
      vim-surround
      vim-commentary
      vim-unimpaired
      vim-repeat
      vim-abolish
      vim-sleuth
      tabular
      vim-multiple-cursors
      vim-easymotion
      vim-sneak
      tagbar
      supertab
      rust-vim
      vim-ruby
      vim-rails
      vim-endwise
      vim-go
      vim-javascript
      typescript-vim
      vim-jsx-pretty
      vim-markdown
      vim-nix
      vim-tmux-navigator
      vim-test
      vim-dispatch
      vim-vinegar
      vim-which-key
      vim-startify
      vim-devicons
      ultisnips
      vim-snippets
    ];
  };

  programs.ssh = {
    enable = true;
    extraConfig = builtins.readFile ../../configs/ssh/config;
  };

  # GPG
  programs.gpg = {
    enable = true;
    settings = {
      # Cipher preferences
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";

      # Algorithm settings
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";

      # Display settings
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      keyid-format = "0xlong";
      with-fingerprint = true;
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";

      # Security
      require-cross-certification = true;
      use-agent = true;
    };
  };

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

  programs.fzf = {
    enable = true;
    # enableFishIntegration is automatically set when fish is enabled
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color=dark"
      "--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f"
      "--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      italic-text = "always";
      style = "numbers,changes,header";
    };
  };



  xdg = {
    enable = true;
    configFile = {
      # You can add additional config files here
      # "app/config".source = ./configs/app;
    };
  };
}
