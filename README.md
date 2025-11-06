# NixOS Configuration for Fern (Thinkpad X1 Carbon Gen 6)

This is a modern, flakes-based NixOS configuration that mirrors your existing Arch Linux setup on the fern machine. It includes SwayFX with visual effects, a comprehensive development environment, and all your familiar tools and workflows.

## Features

- **Window Manager**: SwayFX with blur, shadows, gaps, and rounded corners
- **Shell**: Fish with plugins (pure prompt, fzf, ssh-agent, etc.)
- **Development**: Hybrid approach with rustup, chruby, and full C/C++ toolchain
- **Container Ready**: Podman with Docker compatibility for future workflows
- **Audio**: PipeWire with WirePlumber
- **Editor**: Vim with extensive plugin ecosystem
- **Theme**: Consistent TokyoNight theme across all applications

## Directory Structure

```
nixos-config/
├── flake.nix                 # Main flake configuration
├── flake.lock               # Locked dependencies (auto-generated)
├── hosts/
│   └── fern/
│       ├── configuration.nix # System-level configuration
│       └── hardware.nix     # Hardware-specific configuration
├── home/
│   └── matt/
│       ├── home.nix         # Main home-manager configuration
│       ├── sway.nix         # SwayFX and Wayland setup
│       ├── shell.nix        # Fish shell configuration
│       ├── dev.nix          # Development tools
│       ├── terminal.nix     # Alacritty and tmux
│       └── editors.nix      # Vim configuration
└── overlays/
    └── swayfx.nix          # SwayFX package overlay
```

## Installation

### Prerequisites

1. Boot into a NixOS installer ISO
2. Partition and format your disk as desired
3. Mount your partitions (root to `/mnt`, boot to `/mnt/boot`, etc.)

### Generate Hardware Configuration

After mounting your partitions, generate the hardware configuration:

```bash
nixos-generate-config --root /mnt --show-hardware-config > hardware-config.nix
```

Copy the generated configuration to this repository, replacing the placeholder `hardware.nix`:

```bash
cp hardware-config.nix /path/to/nixos-config/hosts/fern/hardware.nix
```

### Installation Steps

1. Clone your dotfiles repository to the mounted system:
```bash
mkdir -p /mnt/home/matt/git
cd /mnt/home/matt/git
git clone <your-dotfiles-repo> dotfiles
cd dotfiles/nixos-config
```

2. Update the hardware configuration with your actual disk UUIDs (from the generated config)

3. Update user-specific settings in `home/matt/home.nix`:
   - Git user name and email
   - SSH configuration
   - Any personal preferences

4. Enable flakes for the installer:
```bash
nix-shell -p nixFlakes
```

5. Install NixOS:
```bash
nixos-install --flake .#fern
```

6. Set the root password when prompted

7. Reboot into your new NixOS system:
```bash
reboot
```

## Post-Installation

### First Boot

1. Log in as root and set your user password:
```bash
passwd matt
```

2. Log out and log back in as your user

3. Your system should automatically start SwayFX

### Development Environment Setup

Run the included setup script to initialize development environments:

```bash
dev-setup
```

This will:
- Install Ruby 3.3.0 via ruby-install
- Set up Rust toolchain via rustup
- Configure language servers and tools

### Managing Your System

#### Rebuild Configuration

After making changes to the configuration:

```bash
# From the nixos-config directory
sudo nixos-rebuild switch --flake .#fern

# Or use the alias from anywhere
rebuild
```

#### Update System

Update all flake inputs (nixpkgs, home-manager, etc.):

```bash
# Update flake.lock
nix flake update /path/to/nixos-config

# Then rebuild
sudo nixos-rebuild switch --flake /path/to/nixos-config#fern
```

#### Garbage Collection

Clean up old generations:

```bash
# Remove old generations
sudo nix-collect-garbage -d

# Or use the alias
clean
```

## Key Differences from Arch Setup

### Package Management
- Packages are declared in configuration files rather than installed imperatively
- System packages in `configuration.nix`, user packages in `home/*.nix`
- No AUR - packages come from nixpkgs or are built from source

### Plugin Management
- Fish plugins managed via Nix packages (not fisher)
- Vim plugins managed via Nix packages (not vim-plug)
- Tmux plugins managed via Nix packages (not TPM)

### Service Management
- Services declared in configuration (no systemctl commands needed)
- User services managed by Home Manager
- System services managed by NixOS

### Development Tools
- **Hybrid approach**: System provides base tools, but rustup/chruby still available
- Container support via Podman for future container-based workflows
- All build dependencies available in Nix shell environments

## Customization

### Adding System Packages

Edit `hosts/fern/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your package here
  package-name
];
```

### Adding User Packages

Edit `home/matt/home.nix`:

```nix
home.packages = with pkgs; [
  # Add your package here
  package-name
];
```

### Modifying SwayFX

Edit `home/matt/sway.nix` to change:
- Key bindings
- Visual effects (blur, shadows, gaps)
- Waybar configuration
- Input device settings

### Changing Development Tools

Edit `home/matt/dev.nix` to add or modify:
- Programming languages
- Development tools
- Language servers
- Build tools

## Troubleshooting

### SwayFX Won't Start

1. Check that you're in the `seat` group:
```bash
groups
```

2. Ensure seatd is running:
```bash
systemctl status seatd
```

3. Check Wayland environment variables:
```bash
echo $XDG_SESSION_TYPE  # Should be "wayland"
```

### Audio Issues

1. Check PipeWire status:
```bash
systemctl --user status pipewire
systemctl --user status wireplumber
```

2. Use pavucontrol to manage audio devices:
```bash
pavucontrol
```

### Development Tools Not Found

1. For Rust tools, ensure rustup is initialized:
```bash
rustup default stable
```

2. For Ruby, check chruby paths:
```bash
ls ~/.rubies/
```

3. Run the setup script:
```bash
dev-setup
```

## Migration Notes

### From Your Arch Setup

Your configuration has been translated to maintain familiarity:

- **Sway config**: Now in `home/matt/sway.nix` (declarative)
- **Fish config**: Now in `home/matt/shell.nix` (declarative)
- **Git config**: Now in `home/matt/home.nix` (declarative)
- **Vim config**: Now in `home/matt/editors.nix` (declarative)

All your keybindings, aliases, and customizations have been preserved.

### Background Image

You'll need to add your background image:
```bash
sudo mkdir -p /usr/share/backgrounds
sudo cp /path/to/fern.jpg /usr/share/backgrounds/
```

Or update the path in `home/matt/sway.nix`:
```nix
output = {
  "eDP-1" = {
    bg = "/path/to/your/background.jpg fill";
  };
};
```

### PyWal Support

Install pywal via pipx:
```bash
pipx install pywal
```

Then generate colorschemes as before:
```bash
wal -i /path/to/image.jpg
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [SwayFX Documentation](https://github.com/WillPower3309/swayfx)

## Support

For NixOS-specific questions:
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://reddit.com/r/NixOS)
- [NixOS Matrix/IRC](https://nixos.org/community/)

## License

This configuration is provided as-is for personal use.