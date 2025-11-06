{ config, lib, pkgs, ... }:

let
  # Python configuration for pipx
  pipxConfig = pkgs.writeText "pipx-config" ''
    # pipx will manage its own virtual environments
    # This is a placeholder for any pipx-specific config
  '';

  # Ruby configuration
  rubyConfig = pkgs.writeText "ruby-config" ''
    # Ruby configuration can be set via environment variables
    # or in individual project .ruby-version files
  '';

  # Node configuration
  nodeConfig = pkgs.writeText "npmrc" ''
    prefix=~/.npm-global
    //registry.npmjs.org/:_authToken=\${NPM_TOKEN}
  '';

in
{
  userEnvironment.users.matt = {
    # Development tools and language environments
    packages = with pkgs; [
      # Version control
      git-lfs
      git-extras
      git-filter-repo
      gitkraken
      
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
      doxygen
      graphviz
      pandoc
      
      # Containers
      docker-compose
      podman-compose
      dive
      lazydocker
      
      # Cloud tools
      awscli2
      google-cloud-sdk
      azure-cli
      terraform
      kubectl
      kubectx
      k9s
      helm
      minikube
      
      # Database tools
      postgresql
      mysql80
      redis
      sqlite
      dbeaver
      
      # API development
      postman
      insomnia
      grpcurl
      protobuf
      
      # Language-specific tools
      # Python
      (python311.withPackages (ps: with ps; [
        pip
        virtualenv
        setuptools
        wheel
        pytest
        black
        flake8
        mypy
        pylint
        ipython
        jupyter
        numpy
        pandas
        matplotlib
        requests
      ]))
      pipx
      poetry
      pyright
      ruff
      
      # Ruby
      ruby_3_2
      bundler
      rake
      rubocop
      solargraph
      
      # Node.js
      nodejs_20
      yarn
      pnpm
      nodePackages.npm
      nodePackages.typescript
      nodePackages.ts-node
      nodePackages.nodemon
      nodePackages.prettier
      nodePackages.eslint
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      
      # Rust
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      cargo-edit
      cargo-watch
      cargo-audit
      cargo-outdated
      cargo-expand
      cargo-generate
      sccache
      
      # Go
      go_1_21
      gopls
      golangci-lint
      delve
      go-tools
      gomodifytags
      gotests
      gore
      
      # C/C++
      gcc
      clang
      clang-tools
      ccls
      cppcheck
      include-what-you-use
      
      # Java/JVM
      jdk17
      gradle
      maven
      sbt
      metals
      
      # Haskell
      ghc
      cabal-install
      stack
      haskell-language-server
      ormolu
      hlint
      
      # Web development
      hugo
      jekyll
      
      # Mobile development
      android-tools
      flutter
      
      # Other languages
      elixir
      erlang
      ocaml
      zig
      nim
      julia
      
      # Language servers
      lua-language-server
      marksman
      taplo
      
      # Misc dev tools
      direnv
      lorri
      niv
      cachix
      hydra-check
      nix-prefetch-scripts
      nix-tree
      nix-diff
      nixpkgs-fmt
      statix
      deadnix
      
      # Performance analysis
      hyperfine
      flamegraph
      perf-tools
      
      # Security tools
      nmap
      nikto
      sqlmap
      metasploit
      burpsuite
      wireshark
      
      # Other utilities
      asciinema
      ngrok
      mitmproxy
      siege
      vegeta
      hey
      wrk
      jmeter
    ];
    
    wrappedPackages = [
      # NPM with custom config
      {
        package = pkgs.nodePackages.npm;
        name = "npm-configured";
        envVars = {
          NPM_CONFIG_USERCONFIG = toString nodeConfig;
        };
      }
    ];
    
    sessionVariables = {
      # Development environment variables
      GOPATH = "$HOME/go";
      CARGO_HOME = "$HOME/.cargo";
      RUSTUP_HOME = "$HOME/.rustup";
      
      # Path additions for development tools
      PATH = "$PATH:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$HOME/.local/bin";
      
      # Development settings
      DOCKER_BUILDKIT = "1";
      COMPOSE_DOCKER_CLI_BUILD = "1";
      
      # Editor integration
      EDITOR = "vim";
    };
    
    activationScripts = {
      devDirs = ''
        # Create development directories
        mkdir -p $HOME/{projects,go,src}
        mkdir -p $HOME/.npm-global
        mkdir -p $HOME/.cargo
        mkdir -p $HOME/.rustup
        mkdir -p $HOME/.local/bin
        
        # Setup git global hooks directory
        mkdir -p $HOME/.git-templates/hooks
      '';
    };
  };
}
