{ inputs, currentSystemName, ... }:

{ config, lib, pkgs, pkgs-unstable, legacy-dotfiles, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  # gopath = "${config.home.homeDirectory}/Developer/go";
  gnome_accent_color = "yellow";
  # TODO: Fix this this.
  username = "conor";

  shellAliases = {
    gs = "git status";
  } // (if isLinux then {
    # Two decades of using a Mac has made this such a strong memory
    # that I'm just going to keep it consistent.
    pbcopy = "xclip";
    pbpaste = "xclip -o";
    zed = "zeditor";
  } else {});

in {
  # imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  #---------------------------------------------------------------------
  # Files
  #---------------------------------------------------------------------


  home.file = {
    ".face".source = ./icon.png;
    ".zshrc".source = "${legacy-dotfiles}/link/.zshrc";
    "dotfiles".source = "${legacy-dotfiles}";

  # home.file.".config/zed".source = "${legacy-dotfiles}/zed";
    ".config/starship.toml".source = "${legacy-dotfiles}/config/starship.toml";
    ".config/zed/settings.json".source = "${legacy-dotfiles}/config/zed/settings.json";
    ".config/zed/keymap.json".source = "${legacy-dotfiles}/config/zed/keymap.json";
    ".config/yazi".source = "${legacy-dotfiles}/config/yazi";
    ".config/ghostty".source = "${legacy-dotfiles}/config/ghostty";

    "/var/lib/AccountService/icons/${username}/icon.png".source = ./icon.png;
  };
  # programs.dconf = {
  #   enable = true;
  #   profiles.user.databases = [
  #     {
  #       lockAll = true; # prevents overriding
  #       settings = {
  #         "org/gnome/desktop/interface" = {
  #           accent-color = "${gnome_accent_color}";
  #         };
  #         "org/gnome/desktop/background" = {
  #           picture-uri =
  #             "file://${./wallpaper.jpg}";
  #           picture-uri-dark =
  #             "file://${./wallpaper.jpg}";
  #           # picture-options = "zoom";
  #         };
  #         "org/gnome/desktop/input-sources" = {
  #           xkb-options = [ "ctrl:nocaps" ];
  #         };
  #         "org/gnome/desktop/peripherals/touchpad" = {
  #           natural-scroll = false;
  #         };
  #       };
  #     }
  #   ];
  # };

  # Disabled for now since we mismatch our versions. See flake.nix for details.
  home.enableNixpkgsReleaseCheck = false;
  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------
  home.packages = [
    pkgs.bat
    pkgs.yazi
    pkgs.obsidian
    pkgs.qbittorrent
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
    pkgs.zed-editor
    pkgs.mullvad-vpn
    pkgs.niri
  ];
  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  # home.sessionPath = [
  #   "$HOME/.local/bin"
  # ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";

  } // (if isDarwin then {
    # See: https://github.com/NixOS/nixpkgs/issues/390751
    DISPLAY = "nixpkgs-390751";
  } else {});

#   xdg = {
#     enable = true;
#     configFile = {
#       "i3/config".text = builtins.readFile ./i3;
#       "nvim/init.lua".force = true;
#       "rofi/config.rasi".text = builtins.readFile ./rofi;
#     } // (if isDarwin then {
#       # Rectangle.app. This has to be imported manually using the app.
#       "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
#     } else {}) // (if isLinux then {
#       "ghostty/config".text = builtins.readFile   ;
#     } else {});
#   };
#
  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  # programs.gpg.enable = !isDarwin;

  programs.zsh = {
    enable = true;
    shellAliases = shellAliases;

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];
  };

  programs.git = {
    enable = true;
    extraConfig = {
      user.name = "Conor Manning";
      user.email = "conormanning13@gmail.com";
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      # credential.helper = "store"; # want to make this more secure
      github.user = "conorwithonen";
      init.defaultBranch = "main";
    };
  };

  # home.backupFileExtension = "backup";
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
     	settings = {
     	  "browser.startup.homepage"      = "https://wiki.conorwithonen.com";
     	  "privacy.resistFingerprinting"  = true;
     	};
    };
  	policies = {
     DisableTelemetry = true;
     DisablePocket = true;
     EnableTrackingProtection = {
       Value = true;
       Locked = true;
       Cryptomining = true;
       Fingerprinting = true;
     };
  	};
  };

  # Yazi
  programs.yazi.enable = true;
  # programs.neovim = {
  #   enable = true;
  #   package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  #   withPython3 = true;
  #   withRuby = true;
  #   initLua = ''
  #     require("config.lazy")
  #   '';
  # };
}
