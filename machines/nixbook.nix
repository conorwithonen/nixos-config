# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware/latitude-intel.nix
      ./common.nix
    ];

  #---------------------------------------------------------------------
  # Secrets
  # #---------------------------------------------------------------------
  sops = {
    defaultSopsFile = ../users/conor/secrets.enc.yaml;
    age.sshKeyPaths = [ "/home/conor/.ssh/nixbook-sops" ];
      secrets = {
        "syncthing/key" = { owner = "conor"; };
        "syncthing/cert" = { owner = "conor"; };
        "syncthing/password" = { owner = "conor"; };
      };
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Enable networking
  networking = {
    hostName = "nixbook"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

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

  # Syncthing
  services.syncthing = {
    user = "conor";
    group = "users";
    dataDir = "/home/conor";
    configDir = "/home/conor/.config/syncthing";
    enable = true;
    guiAddress = "127.0.0.1:8384";
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    guiPasswordFile = config.sops.secrets."syncthing/password".path;
  	settings = {
     gui.user = "conor";
      devices = {
        "imac" = { id = "W4PLFOQ-MMAODQT-N64HU77-CGNKD4K-65JGV4A-JHCIURF-SBUCRGT-4HA33QC"; autoAcceptFolders = true; };
        "phone" = { id = "WGPWB7E-B5F3BHR-2OQOSSH-K2BT37H-ZZSVC4B-VHATR7U-UGY4OFS-LI72IQO"; };
      };
    };
  };

  services.mullvad-vpn = {
  enable = true;
  package = pkgs.mullvad-vpn;
  };

  programs.dconf.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    dig
    zsh
    unzip
    syncthing
    docker-compose
    pkgs.cargo
    pkgs.rustc
    pkgs.clamav
    pkgs.mixxx
    pkgs.mpv
    pkgs.qbittorrent
    pkgs.abcde
    pkgs.nicotine-plus
    pkgs.niri
    pkgs.mullvad-vpn
    pkgs.ghostty
    pkgs.vlc
    pkgs.bitwarden-desktop
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
