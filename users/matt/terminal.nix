{ config, lib, pkgs, ... }:

let
  # Alacritty configuration with path substitution
  alacrittyConfig = pkgs.substituteAll {
    src = ../../configs/alacritty/alacritty.toml.template;
    FISH = "${pkgs.fish}/bin/fish";
  };

  # Tmux configuration with path substitutions
  tmuxConf = pkgs.substituteAll {
    src = ../../configs/tmux/tmux.conf.template;
    FISH = "${pkgs.fish}/bin/fish";
    TMUX_CONF = "$out"; # This will be replaced with the actual config path
  };


  # Create a wrapped tmux with plugins pre-configured
  tmuxWrapped = pkgs.symlinkJoin {
    name = "tmux-wrapped";
    paths = [ 
      pkgs.tmux 
      # Include some useful tmux-related utilities
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.pain-control
      pkgs.tmuxPlugins.tmux-fzf
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Wrap tmux to use our config
      wrapProgram $out/bin/tmux \
        --add-flags "-f ${tmuxConf}"
      
      # Create helper scripts for tmux plugin functionality
      cat > $out/bin/tmux-resurrect-save <<EOF
      #!${pkgs.bash}/bin/bash
      ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh
      EOF
      chmod +x $out/bin/tmux-resurrect-save
      
      cat > $out/bin/tmux-resurrect-restore <<EOF
      #!${pkgs.bash}/bin/bash
      ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh
      EOF
      chmod +x $out/bin/tmux-resurrect-restore
    '';
  };

in
{
  userEnvironment.users.matt = {
    wrappedPackages = [
      # Alacritty with config
      {
        package = pkgs.alacritty;
        envVars = {
          ALACRITTY_CONFIG = toString alacrittyConfig;
        };
        wrapperFlags = [
          "--add-flags \"--config-file ${alacrittyConfig}\""
        ];
      }

      # Tmux with config and plugins
      {
        package = tmuxWrapped;
        name = "tmux";
      }
    ];

    # Other terminal-related packages (unwrapped)
    packages = with pkgs; [
      zellij
      screen
    ];
  };
}
