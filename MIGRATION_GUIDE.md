# NixOS Configuration Migration Guide

## Overview
This configuration has been refactored to use a hybrid approach that directly links configuration files from the `configs/` directory instead of generating them through Home Manager. This gives you more direct control over your dotfiles while still leveraging NixOS/Home Manager for package management and some plugin systems.

## What Changed

### Before (Home Manager Native)
- Configurations were generated using Home Manager modules (e.g., `programs.fish.enable`)
- Config content was embedded in Nix files using `extraConfig` or similar options
- Less direct control over exact config file format

### After (Direct Linking)
- Config files are stored in `configs/` directory as actual dotfiles
- Home Manager links these files using `home.file` and `xdg.configFile`
- Direct control over config file content
- Templates for files needing Nix paths (kitty, tmux)

## File Structure

```
configs/
├── fish/
│   ├── config.fish         # Fish shell configuration
│   ├── fish_plugins        # Fish plugin list
│   └── themes/            # Fish themes
├── git/
│   └── gitconfig          # Git configuration
├── gpg/
│   └── gpg.conf          # GPG configuration
├── kitty/
│   └── kitty.conf.template # Kitty terminal config (template)
├── nvim/
│   └── init.lua          # Neovim configuration
├── ssh/
│   └── config            # SSH client configuration
├── sway/
│   ├── config            # Sway window manager config
│   └── swayexit          # Sway exit script
├── tmux/
│   └── tmux.conf.template # Tmux config (template)
├── vim/
│   ├── autoload/
│   │   └── plug.vim      # Vim plugin manager
│   └── vimrc             # Vim configuration
└── waybar/
    ├── config            # Waybar configuration
    ├── style.css         # Waybar styling
    └── modules/
        └── battery.py    # Custom battery module
```

## Usage

### To Use the Refactored Configuration

1. **Update your flake.nix or configuration.nix** to use the new home files:
   ```nix
   # Instead of:
   imports = [ ./users/mattvh/home.nix ];
   
   # Use:
   imports = [ ./users/mattvh/home-refactored.nix ];
   ```

2. **Rebuild your system**:
   ```bash
   sudo nixos-rebuild switch --flake .#hostname
   ```

### Editing Configurations

Now you can directly edit files in the `configs/` directory:

```bash
# Edit fish config
vim configs/fish/config.fish

# Edit vim config
vim configs/vim/vimrc

# Edit sway config
vim configs/sway/config
```

After editing, rebuild your NixOS configuration to apply changes.

## Templates

Some files use templates with variable substitution:

### kitty.conf.template
- `@FISH@` → Replaced with fish binary path from Nix

### tmux.conf.template
- `@FISH@` → Replaced with fish binary path from Nix
- `@TMUX_CONF@` → Replaced with tmux config path

These are processed during the Home Manager build.

## Key Benefits

1. **Direct Control**: Edit actual config files, not Nix expressions
2. **Version Control**: Config files tracked directly in git
3. **Portability**: Easier to share configs with non-NixOS systems
4. **Transparency**: See exact config file content
5. **Flexibility**: Mix Home Manager features with direct configs

## Plugin Management

Some programs still use Home Manager for plugin management:

- **Vim/Neovim**: Plugins installed via Nix packages
- **Tmux**: Plugins managed through tmuxPlugins
- **Fish**: Some plugins through fishPlugins

This hybrid approach gives you the best of both worlds:
- Direct config file control
- Declarative plugin management through Nix

## Customization

### Adding New Config Files

1. Place your config file in the appropriate `configs/` subdirectory
2. Add linking in `home-refactored.nix`:

```nix
# For home directory files
home.file.".myconfig".source = ../../configs/myapp/myconfig;

# For XDG config directory files
xdg.configFile."myapp/config.toml".source = ../../configs/myapp/config.toml;
```

### Creating Templates

If you need Nix paths in a config:

1. Name the file with `.template` extension
2. Use placeholders like `@VARIABLE@`
3. Process in home-refactored.nix:

```nix
let
  myConfig = pkgs.replaceVars ../../configs/myapp/config.template {
    VARIABLE = "${pkgs.mypackage}/bin/mybin";
  };
in
{
  xdg.configFile."myapp/config" = {
    text = builtins.readFile myConfig;
  };
}
```

## Rollback

If you need to rollback to the original configuration:

1. Change your imports back to the original home.nix
2. Rebuild your system

Both configurations can coexist during the transition period.
