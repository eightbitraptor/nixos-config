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
│   ├── fern/
│   │   ├── configuration.nix # System-level configuration
│   │   └── hardware.nix     # Hardware-specific configuration
│   └── container/
│       ├── configuration.nix # Container test configuration
│       └── hardware.nix     # Container hardware stub
├── home/
│   └── matt/
│       ├── home.nix         # Main home-manager configuration
│       ├── sway.nix         # SwayFX and Wayland setup
│       ├── shell.nix        # Fish shell configuration
│       ├── dev.nix          # Development tools
│       ├── terminal.nix     # Alacritty and tmux
│       └── editors.nix      # Vim configuration
├── overlays/
│   └── swayfx.nix          # SwayFX package overlay
├── scripts/                 # Test environment scripts
├── Containerfile           # Container definition for testing
└── docker-compose.yml      # Container orchestration
```

## Installation

### Installing on a Fresh NixOS System (ThinkPad or Similar)

These instructions assume you've just installed NixOS using the minimal installer and have a working network connection.

#### Step 1: Enable Flakes and Install Git

After booting into your fresh NixOS installation, you need to enable flakes and install git:

```bash
# Temporarily enable flakes for this session
nix-shell -p git --experimental-features 'nix-command flakes'

# Or if you want to enable flakes permanently first (recommended)
sudo nano /etc/nixos/configuration.nix
# Add this line inside the configuration:
#   nix.settings.experimental-features = [ "nix-command" "flakes" ];
# Save and exit, then:
sudo nixos-rebuild switch
sudo nix-channel --update
nix-shell -p git
```

#### Step 2: Clone This Repository

```bash
# Clone to a temporary location first
cd /tmp
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config
```

#### Step 3: Prepare Your Hardware Configuration

The repository includes a configuration for a system called "fern". You'll need to adapt this for your ThinkPad:

```bash
# Option A: Use 'fern' configuration directly (if your hostname will be 'fern')
sudo cp /etc/nixos/hardware-configuration.nix hosts/fern/hardware.nix

# Option B: Create a new host configuration for your machine
# (Replace 'mythinkpad' with your desired hostname)
cp -r hosts/fern hosts/mythinkpad
sudo cp /etc/nixos/hardware-configuration.nix hosts/mythinkpad/hardware.nix
```

#### Step 4: Customize the Configuration

Edit the configuration to match your system:

```bash
# If using fern configuration
nano hosts/fern/configuration.nix

# Or if you created a new host
nano hosts/mythinkpad/configuration.nix
```

Key things to verify/modify:
- **Hostname**: Change `networking.hostName` to your desired hostname
- **Timezone**: Adjust `time.timeZone` if not in Europe/London
- **User**: The configuration assumes username "matt" - change if needed
- **Boot Loader**: Verify the bootloader configuration matches your setup (UEFI vs Legacy)

**IMPORTANT**: The hardware.nix you copied from `/etc/nixos/hardware-configuration.nix` already contains your correct filesystem configuration. However, you should verify it:

```bash
# Check your current partition setup
lsblk -f
# Compare with what's in the hardware.nix file
cat hosts/fern/hardware.nix
```

#### Step 5: Add New Host to Flake (if you created a new host)

If you created a new host configuration, add it to `flake.nix`:

```bash
nano flake.nix
```

Add your new host configuration after the 'fern' entry:
```nix
mythinkpad = nixpkgs.lib.nixosSystem {
  inherit system pkgs;
  modules = [
    ./hosts/mythinkpad/hardware.nix
    ./hosts/mythinkpad/configuration.nix
    ./modules/user-environment.nix
    ./users/matt
  ];
  specialArgs = { inherit inputs; };
};
```

#### Step 6: Test the Configuration

Before switching, test that the configuration builds:

```bash
# For fern configuration
sudo nixos-rebuild test --flake .#fern

# Or for your custom host
sudo nixos-rebuild test --flake .#mythinkpad
```

This will build and activate the configuration temporarily (until reboot) without making it the default.

#### Step 7: Switch to the New Configuration

If the test succeeds and everything works:

```bash
# Make the configuration permanent
sudo nixos-rebuild switch --flake .#fern
# Or: sudo nixos-rebuild switch --flake .#mythinkpad

# Move the configuration to /etc/nixos for easy access
sudo rm -rf /etc/nixos/*
sudo cp -r . /etc/nixos/
cd /etc/nixos
```

#### Step 8: Set Up User Password

If you're using the 'matt' user from the configuration:

```bash
# Set password for the matt user
sudo passwd matt
```

#### Step 9: Reboot

```bash
sudo reboot
```

After reboot, you should have a fully configured system with:
- SwayFX window manager (if on the fern configuration)
- Fish shell
- All development tools
- Your personalized environment

### Troubleshooting

#### If the build fails:
1. Check the error message - it usually indicates which package or option is problematic
2. Run with `--show-trace` for more details:
   ```bash
   sudo nixos-rebuild test --flake .#fern --show-trace
   ```

#### If you can't boot after switching:
1. NixOS keeps previous configurations. At the boot menu, select an older generation
2. Once booted into a working configuration, you can rollback:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

#### Common Issues:
- **"No such file or directory"**: Make sure all files referenced in imports exist
- **"undefined variable"**: A package name might have changed in nixpkgs
- **"option does not exist"**: The NixOS option might have been renamed or removed
- **Architecture mismatch**: Ensure the `system` in flake.nix matches your hardware (x86_64-linux for Intel, aarch64-linux for ARM)

### Post-Installation

After successful installation:

1. **Set up Git credentials:**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Generate SSH keys:**
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```

3. **Fork and track your configuration:**
   ```bash
   # Fork this repository on GitHub first, then:
   cd /etc/nixos
   git remote set-url origin https://github.com/yourusername/your-nixos-config.git
   git branch -M main
   git push -u origin main
   ```

4. **Commit your hardware configuration:**
   ```bash
   cd /etc/nixos
   git add hosts/
   git commit -m "Add my ThinkPad hardware configuration"
   git push
   ```

## Testing

Test your NixOS configuration changes before deploying:

```bash
./test.sh
```

This validates:
- Flake syntax and structure
- NixOS configuration evaluation
- Package availability
- Module compatibility

For detailed documentation, see [docs/TESTING.md](docs/TESTING.md).

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