{ inputs, currentSystemName, ... }:

{ config, lib, pkgs, pkgs-unstable, legacy-dotfiles, hunk, sops-nix, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  gnome_accent_color = "yellow";
  # TODO: Fix this this.
  username = "conor";

  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    vim = "nvim";
    gs = "jj st";
    gshow = "git show";
    gshowf = "git show --name-only";
    sshconfig = "vim ~/.ssh/config";

  } // (if isLinux then {
    # Two decades of using a Mac has made this such a strong memory
    # that I'm just going to keep it consistent.
    pbcopy = "xclip";
    pbpaste = "xclip -o";
    zed = "zeditor";
  } else {});

in {
  imports = [ sops-nix ./nvim];

  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  #---------------------------------------------------------------------
  # Secrets
  #---------------------------------------------------------------------
  sops = {
    defaultSopsFile = ./secrets.enc.yaml;
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/nixbook-sops" ];
      secrets = {
        "syncthing/key" = { };
        "syncthing/cert" = { };
        "syncthing/password" = { };
      };
  };

  #---------------------------------------------------------------------
  # Files
  #---------------------------------------------------------------------


  home.file = {
    ".face".source = ./icon.png;
    ".zshrc".source = "${legacy-dotfiles}/link/.zshrc";
    "dotfiles".source = "${legacy-dotfiles}";
    "/var/lib/AccountService/icons/${username}/icon.png".source = ./icon.png;
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
    };
  };

  # # Disabled for now since we mismatch our versions. See flake.nix for details.
  # home.enableNixpkgsReleaseCheck = false;
  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------
  home.packages = [
    inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.hunk
    pkgs.fzf
    pkgs.fd
    pkgs.ripgrep
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
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

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    # TODO: Fix prompt sourcing with dotfiles
    DOTFILES = "$HOME/dotfiles";
    BROWSER = "firefox";

  } // (if isDarwin then {
    # See: https://github.com/NixOS/nixpkgs/issues/390751
    DISPLAY = "nixpkgs-390751";
  } else {});

  xdg = {
    enable = true;
    configFile = {
      "yazi".source = "${legacy-dotfiles}/config/yazi";
      "starship.toml".source = "${legacy-dotfiles}/config/starship.toml";
      "zed/settings.json".source = "${legacy-dotfiles}/config/zed/settings.json";
      "zed/keymap.json".source = "${legacy-dotfiles}/config/zed/keymap.json";
      "jj/config.toml".text = builtins.readFile ./jj-config.toml;
      "jj/conf.d/personal.toml".text = builtins.readFile ./jj-personal.toml;
      "jj/conf.d/work.toml".text = builtins.readFile ./jj-work.toml;
    } // (if isDarwin then {
      # Rectangle.app. This has to be imported manually using the app.
      # "ghostty".source = "${legacy-dotfiles}/config/ghostty";
      # "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
    } else {}) // (if isLinux then {
      "ghostty/config".text = builtins.readFile ./ghostty.linux  ;
    } else {});
    mimeApps = {
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

#
  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs.jujutsu = {
    enable = true;
    # settings = {
    # };
  };
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };
  # Email
  accounts.email.accounts = {
    # TODO: Better password setup
    "conor@conormanning.com" = {
      primary = true;
      address = "conor@conormanning.com";
      userName = "conor@conormanning.com";
      realName = "Conor Manning";
      flavor = "plain";
      imap = {
        host = "witcher.mxrouting.net";
        port = 993;
        tls.enable = true;
      };
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
      signature = {
        text =  ''
          Conor Manning (He/Him)
          conormanning.com
        '';
      };
    };
    "conormanning13@gmail.com" = {
      address = "conormanning13@gmail.com";
      userName = "conormanning13@gmail.com";
      realName = "Conor Manning";
      flavor = "gmail.com";
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    shellAliases = shellAliases;
    dotDir = "${config.xdg.configHome}/zsh";

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];
    # Legacy dotfile sourcing for aliases, functions, etc...
    initContent = ''
      autoload -Uz +X bashcompinit && bashcompinit
      eval "$(starship init zsh)"
      for file in ${legacy-dotfiles}/source/*; do
          source "$file"
      done
      unset file;

      # Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
      [ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;
      complete -C '${pkgs.awscli2}/bin/aws_completer' aws

    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Conor Manning";
      user.email = "conormanning13@gmail.com";
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      # credential.helper = "store"; # want to make this more secure
      github.user = "conorwithonen";
      init.defaultBranch = "main";
      aliases = {
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };
  };

  # Browser
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
     	settings = {
     	  "browser.startup.homepage"      = "https://wiki.conorwithonen.com";
     	  "privacy.resistFingerprinting"  = true;
     	};
      extensions = {
        packages = with pkgs.firefoxAddons; [
          bitwarden-password-manager
        ];
      };

      # optional: without this the addons need to be enabled manually after first install
      settings = {
        "extensions.autoDisableScopes" = 0;
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

  # Syncthing
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    guiCredentials = {
     username = "conor";
     passwordFile = config.sops.secrets."syncthing/password".path;
    };
  	settings = {
      devices = {
        "imac" = { id = "W4PLFOQ-MMAODQT-N64HU77-CGNKD4K-65JGV4A-JHCIURF-SBUCRGT-4HA33QC"; autoAcceptFolders = true; };
        "phone" = { id = "WGPWB7E-B5F3BHR-2OQOSSH-K2BT37H-ZZSVC4B-VHATR7U-UGY4OFS-LI72IQO"; };
      };
    };
  };

  # Yazi
  programs.yazi.enable = true;
  programs.yazi.shellWrapperName = "y";

  # Notes
  programs.obsidian = {
    enable = true;
    package = pkgs.obsidian;
    defaultSettings.app = {
      vimMode = true;
      alwaysUpdateLinks = true;
      showRibbon = true;
      newFileLocation = "folder";
      attachmentFolderPath = "_assets";
      showUnsupportedFiles = false;
      promptDelete = false;
      propertiesInDocument = "visible";
      newFileFolderPath = "Intake";
    };
    vaults = {
      notes = {
        enable = true;
        target = "Notes-Synced";
        };
      };
    };
}
