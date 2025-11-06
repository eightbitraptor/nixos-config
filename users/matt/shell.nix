{ config, lib, pkgs, ... }:

let
  # Fish configuration from external file
  fishConfig = pkgs.writeText "config.fish" (builtins.readFile ../../configs/fish/config.fish);

  # Fish functions from external files
  fishFunctionsDir = ../../configs/fish/functions;

  # Create a comprehensive fish package with all plugins and configurations
  fishWrapped = pkgs.symlinkJoin {
    name = "fish-wrapped";
    paths = [ pkgs.fish ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Create config directory structure
      mkdir -p $out/etc/fish/{conf.d,functions,completions}
      
      # Copy main config
      cp ${fishConfig} $out/etc/fish/config.fish

      # Copy all functions from external directory
      cp -r ${fishFunctionsDir}/*.fish $out/etc/fish/functions/
      
      # Install and configure plugins
      # Pure prompt
      cp -r ${pkgs.fishPlugins.pure.src}/functions/* $out/etc/fish/functions/
      cp -r ${pkgs.fishPlugins.pure.src}/conf.d/* $out/etc/fish/conf.d/ 2>/dev/null || true
      
      # FZF integration
      cp -r ${pkgs.fetchFromGitHub {
        owner = "PatrickF1";
        repo = "fzf.fish";
        rev = "v10.3";
        sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
      }}/functions/* $out/etc/fish/functions/
      cp -r ${pkgs.fetchFromGitHub {
        owner = "PatrickF1";
        repo = "fzf.fish";
        rev = "v10.3";
        sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
      }}/conf.d/* $out/etc/fish/conf.d/ 2>/dev/null || true
      
      # SSH agent
      cp -r ${pkgs.fetchFromGitHub {
        owner = "danhper";
        repo = "fish-ssh-agent";
        rev = "v0.4.0";
        sha256 = "sha256-eCtNCaqEOLbP1c0X4OCCL2FvtLDcQGaFgnM0+tsxnJM=";
      }}/functions/* $out/etc/fish/functions/
      
      # Z directory jumping
      cp -r ${pkgs.fetchFromGitHub {
        owner = "jethrokuan";
        repo = "z";
        rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
        sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      }}/functions/* $out/etc/fish/functions/
      cp -r ${pkgs.fetchFromGitHub {
        owner = "jethrokuan";
        repo = "z";
        rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
        sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      }}/conf.d/* $out/etc/fish/conf.d/ 2>/dev/null || true
      
      # Git helpers
      cp -r ${pkgs.fetchFromGitHub {
        owner = "jhillyerd";
        repo = "plugin-git";
        rev = "v0.1";
        sha256 = "sha256-MfrRQdnDw0NeDCbK0lOIrcMH4tJm9wHheFzrANOglQY=";
      }}/functions/* $out/etc/fish/functions/
      
      # Colored man pages
      cp -r ${pkgs.fetchFromGitHub {
        owner = "patrickf1";
        repo = "colored_man_pages.fish";
        rev = "v1.1.0";
        sha256 = "sha256-ii9gdBPlC1/P1N9xJzqomrkyDqIdTg+iCg0mwNVq2EU=";
      }}/functions/* $out/etc/fish/functions/
      
      # Wrap fish to use our config directory
      wrapProgram $out/bin/fish \
        --set __fish_sysconf_dir $out/etc/fish \
        --set __fish_user_data_dir $out/share/fish
    '';
  };

in
{
  userEnvironment.users.matt = {
    # Set fish as the user's shell
    shell = fishWrapped;
    
    # Shell-related packages
    packages = with pkgs; [
      # Shell utilities that were in the original config
      fishPlugins.done
      fishPlugins.foreign-env
      fishPlugins.grc
      
      # Modern CLI tools
      fd
      ripgrep
      eza
      bat
      procs
      dust
      duf
      hyperfine
      tokei
      tealdeer
      
      # Data processing
      httpie
      jq
      yq-go
      fx
      
      # File management
      ranger
      tree
      ncdu
      
      # System monitoring
      htop
      btop
      iotop
      nethogs
      bandwhich
      
      # Fun stuff
      cowsay
      fortune
      lolcat
      neofetch
      
      # Required by fish config
      fzf
      direnv
    ];
  };
}
