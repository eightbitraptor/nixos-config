{ config, lib, pkgs, ... }:

let
  # Vim configuration from external file
  vimrc = pkgs.writeText "vimrc" (builtins.readFile ../../configs/vim/vimrc);


  # Create wrapped vim with plugins
  vimWrapped = pkgs.vim-full.customize {
    name = "vim";
    vimrcConfig = {
      customRC = builtins.readFile vimrc;
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          vim-sensible
          vim-polyglot
          
          tokyonight-nvim
          vim-airline
          vim-airline-themes
          
          fern-vim
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
          vim-racer
          
          vim-ruby
          vim-rails
          vim-bundler
          vim-endwise
          
          vim-cpp-modern
          
          python-mode
          
          vim-go
          
          vim-javascript
          typescript-vim
          vim-jsx-typescript
          
          vim-markdown
          
          vim-nix
          
          vim-tmux-navigator
          vim-test
          vim-dispatch
          vim-vinegar
          vim-which-key
          vim-startify
          vim-devicons
          bufkill-vim
          scratch-vim
          
          ultisnips
          vim-snippets
        ];
      };
    };
  };

  # Create wrapped neovim that sources vim config
  neovimConfig = pkgs.writeText "init.vim" ''
    " Source the common vim configuration
    source ${vimrc}
    
    " Additional neovim-specific configuration
    if has('nvim')
      " Enable lua plugins if needed
      lua << EOF
      -- Neovim specific lua config
      EOF
    endif
  '';

  neovimWrapped = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    viAlias = false;
    vimAlias = false;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
    configure = {
      customRC = builtins.readFile neovimConfig;
      packages.myNeovimPackage = with pkgs.vimPlugins; {
        start = [
          # Same plugins as vim
          vim-sensible
          vim-polyglot
          tokyonight-nvim
          vim-airline
          vim-airline-themes
          fern-vim
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
          vim-racer
          vim-ruby
          vim-rails
          vim-bundler
          vim-endwise
          vim-cpp-modern
          python-mode
          vim-go
          vim-javascript
          typescript-vim
          vim-jsx-typescript
          vim-markdown
          vim-nix
          vim-tmux-navigator
          vim-test
          vim-dispatch
          vim-vinegar
          vim-which-key
          vim-startify
          vim-devicons
          bufkill-vim
          scratch-vim
          ultisnips
          vim-snippets
        ];
      };
    };
  };

  # VSCodium wrapper with extensions
  vscodiumWithExtensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      rust-lang.rust-analyzer
      golang.go
      vscodevim.vim
      eamodio.gitlens
      pkief.material-icon-theme
      dracula-theme.theme-dracula
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "tokyonight";
        publisher = "enkia";
        version = "1.0.0";
        sha256 = "sha256-0000000000000000000000000000000000000000000="; # Replace with actual
      }
    ];
  };

in
{
  userEnvironment.users.matt = {
    wrappedPackages = [
      # Vim with full configuration
      {
        package = vimWrapped;
        name = "vim";
      }

      # Neovim with shared vim configuration
      {
        package = neovimWrapped;
        name = "nvim";
      }

      # VSCodium with extensions
      {
        package = vscodiumWithExtensions;
        name = "codium";
      }
    ];

    # Other editors and tools (unwrapped)
    packages = with pkgs; [
      # Alternative editors
      helix
      kakoune
      micro
      
      # Editor support tools
      editorconfig-core-c
      tree-sitter
      ctags
      
      # Language servers and formatters (for editor integration)
      nodePackages.prettier
      nodePackages.eslint
      rustfmt
      nixfmt-classic
      black
      gofmt
    ];
    
    # Activation script to create vim directories
    activationScripts = {
      vimDirs = ''
        # Create vim directories
        mkdir -p $HOME/.vim/{undo,backup,swap}
      '';
    };
  };
}
