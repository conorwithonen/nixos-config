{  config, pkgs, inputs, currentSystemUsername, ...}:
let
  gnome_accent_color = "yellow";
  handy = inputs.handy.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  hardware.uinput.enable = true;
  users.users.${currentSystemUsername} = {
    isNormalUser = true;
    description = "Conor Manning";
    hashedPassword = "$6$bXsGPpJNJx99PuR8$wtSFCJPKIMFqHFEGye1hyRpWIcSphpuoXo1bMLm6c3nynask2jx/jQB7h8/kU1cMBqdiROFKIUfSldtCCwBeM1";
    home = "/home/${currentSystemUsername}";
    extraGroups = [ "networkmanager" "wheel" "docker" "uinput"];
    shell = pkgs.zsh;
  };

  # Theme settings stuff
  programs.dconf.enable = true;

  # Niri
  programs.niri.enable = false;

  programs.zsh.enable = true;
  # Email
  programs.thunderbird = {
    enable = true;
  };
  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
      };
    };
  };
  home-manager.users.${currentSystemUsername} = {

    home.packages = [ handy pkgs.dotool ];
    systemd.user.services.handy.Service.Environment = [
      "PATH=${pkgs.lib.makeBinPath [ pkgs.dotool ]}:/run/current-system/sw/bin"
    ];

    systemd.user.services.handy = {
      Unit = {
        Description = "Handy speech-to-text";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${handy}/bin/handy --start-hidden";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    dconf = {
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "${gnome_accent_color}";
          color-scheme = "prefer-dark";
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
        "org/gnome/desktop/peripherals/touchpad" = {
          natural-scroll = false;
        };
        "org/gnome/desktop/notifications/applications/thunderbird" = {
          application-id = "thunderbird.desktop";
          enable = false;
          # show-banners = false;
        };
      };
    };
  };
}
