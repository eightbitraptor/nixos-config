{ config, lib, pkgs, ... }:

let
  # Git configuration from external file
  gitConfig = pkgs.writeText "gitconfig" (builtins.readFile ../../configs/git/gitconfig);

  # Common CLI tool configurations
  batConfig = pkgs.writeText "bat-config" ''
    --theme="ansi"
    --style="numbers,changes,header"
    --italic-text=always
    --wrap=never
    --pager="less -FR"
  '';

  ripgrepConfig = pkgs.writeText "ripgreprc" ''
    # Don't search in version control directories
    --glob=!{.git,.svn,.hg}
    
    # Don't search in node_modules
    --glob=!node_modules
    
    # Don't search in Python cache
    --glob=!__pycache__
    --glob=!*.pyc
    
    # Add colors
    --colors=line:fg:yellow
    --colors=line:style:bold
    --colors=path:fg:green
    --colors=path:style:bold
    --colors=match:fg:red
    --colors=match:style:bold
    
    # Smart case search
    --smart-case
  '';

  fdIgnore = pkgs.writeText "fd-ignore" ''
    .git/
    node_modules/
    __pycache__/
    *.pyc
    .DS_Store
    Thumbs.db
  '';

in
{
  userEnvironment.users.matt = {
    wrappedPackages = [
      # Git with config and delta
      {
        package = pkgs.symlinkJoin {
          name = "git-with-delta";
          paths = [ pkgs.git pkgs.git-lfs pkgs.delta ];
        };
        name = "git";
        envVars = {
          GIT_CONFIG_GLOBAL = toString gitConfig;
        };
      }

      # Version control tools
      {
        package = pkgs.gh;
        envVars = {
          EDITOR = "vim";
        };
      }
      
      {
        package = pkgs.lazygit;
        envVars = {
          EDITOR = "vim";
        };
      }

      # Better CLI tools
      {
        package = pkgs.bat;
        envVars = {
          BAT_CONFIG_PATH = toString batConfig;
        };
      }

      {
        package = pkgs.ripgrep;
        envVars = {
          RIPGREP_CONFIG_PATH = toString ripgrepConfig;
        };
      }

      {
        package = pkgs.fd;
        configFile = fdIgnore;
        envVars = {
          FD_OPTIONS = "--hidden --follow";
        };
      }

      {
        package = pkgs.eza;
        envVars = {
          EZA_COLORS = "ur=33:uw=31:ux=32:ue=32:gr=33:gw=31:gx=32:tr=33:tw=31:tx=32";
        };
      }

      # System monitoring tools
      {
        package = pkgs.btop;
        envVars = {
          # btop will create its own config on first run
        };
      }

      # JSON/YAML tools  
      {
        package = pkgs.jq;
      }
      
      {
        package = pkgs.yq-go;
      }

      # HTTP tools
      {
        package = pkgs.httpie;
      }

      # Other wrapped tools from the original config
      {
        package = pkgs.tig;
      }

      {
        package = pkgs.delta;
      }

      {
        package = pkgs.procs;
      }

      {
        package = pkgs.dust;
      }

      {
        package = pkgs.duf;
      }
    ];
  };
}
