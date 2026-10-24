{ inputs, currentSystemName, ... }:

{ config, lib, pkgs, pkgs-unstable, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  # gopath = "${config.home.homeDirectory}/Developer/go";

  shellAliases = {
#     ga = "git add";
#     gc = "git commit";
#     gco = "git checkout";
#     gcp = "git cherry-pick";
#     gdiff = "git diff";
#     gl = "git prettylog";
#     gp = "git push";
    gs = "git status";
#     gt = "git tag";
#
#     jd = "jj desc";
#     jf = "jj git fetch";
#     jn = "jj new";
#     jp = "jj git push";
#     js = "jj st";
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

  # Disabled for now since we mismatch our versions. See flake.nix for details.
  home.enableNixpkgsReleaseCheck = false;

  xdg.enable = true;

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

  # home.file = {
  #   ".gdbinit".source = ./gdbinit;
  #   ".inputrc".source = ./inputrc;
  # };

  # xdg.configFile = {
  #   "i3/config".text = builtins.readFile ./i3;
  #   "nvim/init.lua".force = true;
  #   "rofi/config.rasi".text = builtins.readFile ./rofi;
  # } // (if isDarwin then {
  #   # Rectangle.app. This has to be imported manually using the app.
  #   "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
  # } else {}) // (if isLinux then {
  #   "ghostty/config".text = builtins.readFile ./ghostty.linux;
  # } else {});

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
      # core.askPass = ""; # needs to be empty to use terminal for ask pass
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
  	# policies = {
   #   DisableTelemetry = true;
   #   DisablePocket = true;
   #   EnableTrackingProtection = {
   #     Value = true;
   #     Locked = true;
   #     Cryptomining = true;
   #     Fingerprinting = true;
   #   };
  	# };
  };
  # programs.neovim = {
  #   enable = true;
  #   package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  #   withPython3 = true;
  #   withRuby = true;
  #   initLua = ''
  #     require("config.lazy")
  #   '';
  # };

  # programs.npm = {
  #   enable = isLinux;
  # };


  # xresources.extraConfig = builtins.readFile ./Xresources;

  # # Make cursor not tiny on HiDPI screens
  # home.pointerCursor = lib.mkIf (isLinux && !isWSL) {
  #   name = "Vanilla-DMZ";
  #   package = pkgs.vanilla-dmz;
  #   size = 128;
  #   x11.enable = true;
  # };
}
