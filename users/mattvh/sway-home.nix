{ config, lib, pkgs, ... }:

{
  # Install sway and waybar packages
  home.packages = with pkgs; [
    swayfx
    waybar
    fuzzel
    grim
    slurp
    wl-clipboard
    swaylock
    swayidle
    light
    pywal
  ];

  # Link the sway config directly
  xdg.configFile."sway/config".source = ../../configs/sway/config;

  # Waybar configuration - link config and style files directly
  xdg.configFile."waybar/config".source = ../../configs/waybar/config;
  xdg.configFile."waybar/style.css".source = ../../configs/waybar/style.css;

  # Ensure XDG runtime directory is set for Wayland
  systemd.user.sessionVariables = {
    WAYLAND_DISPLAY = "wayland-1";
  };
}
