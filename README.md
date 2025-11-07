# NixOS Configuration for Fern (ThinkPad X1 Carbon Gen 6)

A modern, flakes-based NixOS configuration featuring SwayFX window manager, comprehensive development environment, and direct dotfile management through linked configuration files.

## Features

- **Window Manager**: SwayFX with visual effects (blur, shadows, gaps, rounded corners)
- **Shell**: Fish with plugins and custom configuration
- **Development**: Full development environment with various language toolchains
- **Container Support**: Podman with Docker compatibility
- **Audio**: PipeWire with WirePlumber
- **Editor**: Vim and Neovim with extensive configurations
- **Direct Config Management**: Actual dotfiles in `configs/` directory, linked via Home Manager

## Directory Structure

```
nixos-config/
├── flake.nix                 # Main flake configuration
├── flake.lock               # Locked dependencies
├── configs/                 # Actual configuration files
│   ├── bat/                # Bat (cat alternative) config
│   ├── fish/               # Fish shell configuration
│   ├── git/                # Git configuration
│   ├── gpg/                # GPG configuration
│   ├── kitty/              # Kitty terminal config
│   ├── nvim/               # Neovim configuration
│   ├── ssh/                # SSH client configuration
│   ├── sway/               # Sway window manager config
│   ├── tmux/               # Tmux configuration
│   ├── vim/                # Vim configuration
│   └── waybar/             # Waybar configuration
├── hosts/
│   └── fern/
│       ├── configuration.nix # System-level configuration
│       └── hardware.nix     # Hardware-specific configuration
├── modules/
│   └── nixos/
│       └── common.nix      # Common NixOS configurations
├── overlays/
│   └── swayfx.nix          # SwayFX package overlay
├── users/
│   └── mattvh/
│       ├── home.nix        # Home Manager configuration
│       └── sway-home.nix   # Sway-specific home config
└── MIGRATION_GUIDE.md      # Guide for config migration
```

## Installation

### Prerequisites

- Fresh NixOS installation with networking configured
- Git access

### Step 1: Enable Flakes and Install Git

```bash
# Temporarily enable flakes for this session
nix-shell -p git --experimental-features 'nix-command flakes'

# Or permanently enable flakes first (recommended)
sudo nano /etc/nixos/configuration.nix
# Add: nix.settings.experimental-features = [ "nix-command" "flakes" ];
sudo nixos-rebuild switch
```

### Step 2: Clone This Repository

```bash
cd /tmp
git clone https://github.com/eightbitraptor/nixos-config.git
cd nixos-config
```

### Step 3: Prepare Hardware Configuration

```bash
# Copy your system's hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix hosts/fern/hardware.nix

# Or create a new host
cp -r hosts/fern hosts/yourhostname
sudo cp /etc/nixos/hardware-configuration.nix hosts/yourhostname/hardware.nix
```

### Step 4: Customize Configuration

Edit `hosts/fern/configuration.nix` (or your new host) to verify:
- Hostname (`networking.hostName`)
- Timezone (`time.timeZone`)
- Locale settings
- Username (currently set to "mattvh")

### Step 5: Build and Switch

```bash
# Test the configuration
sudo nixos-rebuild test --flake .#fern

# If successful, make it permanent
sudo nixos-rebuild switch --flake .#fern

# Move to /etc/nixos for convenience
sudo cp -r . /etc/nixos/
cd /etc/nixos
```

### Step 6: Set User Password

```bash
# Set password for your user
sudo passwd mattvh
```

### Step 7: Reboot

```bash
sudo reboot
```

## Configuration Details

### System Configuration (`hosts/fern/configuration.nix`)

- **Networking**: NetworkManager enabled
- **Boot**: systemd-boot with EFI support
- **Bluetooth**: Enabled with Blueman
- **Keyboard**: UK layout with Caps Lock as Ctrl
- **SSH**: OpenSSH server enabled (password auth disabled)
- **Fonts**: JetBrains Mono, Noto fonts, Font Awesome
- **Shell**: Fish as default for user

### User Configuration (`users/mattvh/home.nix`)

The configuration uses a hybrid approach: dotfiles are stored as actual files in the `configs/` directory and linked to their proper locations using Home Manager's `home.file` and `xdg.configFile`.

Key configurations:
- **Git**: Personal settings with custom aliases (see `configs/git/gitconfig`)
- **Fish**: Custom prompt, plugins, and functions (see `configs/fish/`)
- **Vim/Neovim**: Full configurations with vim-plug (see `configs/vim/` and `configs/nvim/`)
- **Tmux**: Custom key bindings and theme (see `configs/tmux/`)
- **SSH**: Client configuration with agent forwarding (see `configs/ssh/config`)

### SwayFX Configuration (`users/mattvh/sway-home.nix`)

- Wayland native configuration
- Visual effects enabled (blur, shadows, rounded corners)
- Waybar status bar
- Fuzzel application launcher
- Custom key bindings (Mod4/Super key)
- Multi-monitor support ready

## Managing Your System

### Quick Commands (via direnv)

When in the nixos-config directory with direnv enabled:

```bash
rebuild        # Apply configuration changes
rebuild-test   # Test changes without making permanent
rebuild-boot   # Apply changes for next boot
update         # Update all flake inputs
check          # Check flake configuration
show           # Show flake outputs
clean          # Garbage collect old generations
optimize       # Optimize nix store
```

### Manual Commands

```bash
# Rebuild from any directory
sudo nixos-rebuild switch --flake /etc/nixos#fern

# Update packages
nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#fern

# Clean old generations
sudo nix-collect-garbage -d
```

## Customization Guide

### Adding Packages

#### System-wide packages
Edit `hosts/fern/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  # Add package here
];
```

#### User packages
Edit `users/mattvh/home.nix`:
```nix
home.packages = with pkgs; [
  # Add package here
];
```

### Modifying Configurations

All configuration files are in the `configs/` directory. Edit them directly:

- **Fish shell**: `configs/fish/config.fish`
- **Git**: `configs/git/gitconfig`
- **Vim**: `configs/vim/vimrc`
- **Neovim**: `configs/nvim/init.lua`
- **Sway**: `configs/sway/config`
- **Waybar**: `configs/waybar/config` and `style.css`
- **SSH**: `configs/ssh/config`

After editing, rebuild with `sudo nixos-rebuild switch --flake .#fern`

### Template Files

Some files use templates to inject Nix store paths:
- `configs/kitty/kitty.conf.template` → Uses Nix fish path
- `configs/tmux/tmux.conf.template` → Uses Nix fish path

## Installed Development Tools

The configuration includes:
- **Languages**: Python 3, Node.js, various compilers
- **Build Tools**: CMake, Make, pkg-config
- **Version Control**: Git with extensive aliases
- **Editors**: Vim, Neovim (with LSP support configured)
- **Container Tools**: Podman with Docker compatibility
- **Shell Tools**: fzf, ripgrep, fd, bat, htop, btop

## Troubleshooting

### SwayFX Issues

Check Wayland environment:
```bash
echo $XDG_SESSION_TYPE  # Should be "wayland"
```

### Audio Issues

Check PipeWire services:
```bash
systemctl --user status pipewire
systemctl --user status wireplumber
```

### Configuration Errors

Build with trace for detailed errors:
```bash
sudo nixos-rebuild test --flake .#fern --show-trace
```

### Rolling Back

Boot into previous generation from boot menu, or:
```bash
sudo nixos-rebuild switch --rollback
```

## Personal Information Note

This configuration contains personal information:
- Email addresses in `configs/git/gitconfig`
- Internal network details in git config
- Username and full name

Consider forking and customizing these values for your own use.

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [SwayFX Documentation](https://github.com/WillPower3309/swayfx)

## License

This configuration is provided as-is for personal use.