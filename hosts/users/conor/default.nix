{  config, pkgs, pkgs-unstable, ...}:
let
  username = "conor";
  gnome_accent_color = "yellow";
in
{
  users.users.${username} = {
    isNormalUser = true;
    description = "Conor Manning";
    home = "/home/${username}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];

    packages = with pkgs; [
    #  thunderbird
      yazi
      lazygit
      obsidian
      qbittorrent
      pkgs.syncthing
      pkgs.nodejs_22
      pkgs.go-task
      pkgs.ghostty
      pkgs.gcc
      pkgs.starship
      pkgs.terraform
      pkgs.mpv
      pkgs.firefox
      pkgs.vlc
      pkgs.clamav
      pkgs.ijq
      pkgs.abcde
      pkgs.mixxx
      pkgs.nicotine-plus
      pkgs.bitwarden-desktop
      pkgs.ansible
      pkgs.jujutsu
      pkgs.terraform-ls
      pkgs-unstable.zed-editor
      pkgs.mullvad-vpn
      pkgs.niri
    ];
    shell = pkgs.zsh;
  };

  # User picture hack
  system.activationScripts.setUserIcon = ''
    cp ${./icon.png} /var/lib/AccountsService/icons/${username}
    chmod 644 /var/lib/AccountsService/icons/${username}
  '';

  # Theme settings stuff
  # TODO: Profile picture stuff
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "${gnome_accent_color}";
        };
        "org/gnome/desktop/background" = {
          picture-uri =
            "file://${./wallpaper.jpg}";
          picture-uri-dark =
            "file://${./wallpaper.jpg}";
          # picture-options = "zoom";
        };
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
      };
    }
  ];
  # Syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "${username}";
    dataDir = "/home/${username}/syncthing";
  	settings = {
      devices = {
        "imac" = { id = "JDF4MHN-IFKO35B-VJUZCA2-R34QAWZ-C5JCYWB-VZGX2BT-M2VKR7A-AV34GQC"; };
        "phone" = { id = "WGPWB7E-B5F3BHR-2OQOSSH-K2BT37H-ZZSVC4B-VHATR7U-UGY4OFS-LI72IQO"; };
      };
    };
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
  	preferences = {
  	  "browser.startup.homepage"      = "https://wiki.conorwithonen.com";
  	  "privacy.resistFingerprinting"  = true;
  	};
  	policies = {
  	  DisableTelemetry = true;
  	};
  };

  # Niri
  programs.niri.enable = false;

  # Yazi
  programs.yazi.enable = true;

  # Default shell to zsh
  programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    zed = "zeditor";
  };
}
