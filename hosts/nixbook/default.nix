# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking = {
    hostName = "nixbook"; # Define your hostname.
    networkmanager.enable = true;
  };
  # Enable networking


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.mullvad-vpn = {
  enable = true;
  package = pkgs.mullvad-vpn;
};

  programs.dconf.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Niri
  programs.niri.enable = false;

  # Yazi
  programs.yazi.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    dig
    zsh
    unzip
    yazi
    lazygit
    obsidian
    docker-compose
    pkgs.mullvad-vpn
    qbittorrent
    pkgs.zed-editor
    # inputs.zed.packages.${system}.default
    pkgs.nodejs_22
    pkgs.go-task
    pkgs.ghostty
    pkgs.gcc
    pkgs.starship
    pkgs.terraform
    pkgs.cargo
    pkgs.rustc
    pkgs.niri
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
