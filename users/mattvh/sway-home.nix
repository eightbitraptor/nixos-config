{ config, lib, pkgs, ... }:

{
  # Install user-specific theming tools
  # Core sway packages are now in system configuration
  home.packages = with pkgs; [
    pywal  # User theming tool
  ];

  # Link the sway config directly
  xdg.configFile."sway/config".source = ../../configs/sway/config;

  # Waybar configuration - link config and style files directly
  xdg.configFile."waybar/config".source = ../../configs/waybar/config;
  xdg.configFile."waybar/style.css".source = ../../configs/waybar/style.css;

  # Battery script is now provided by system package 'waybar-battery'
}
