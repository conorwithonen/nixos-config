{  config, pkgs, ...}:{
  users.users.conor = {
    isNormalUser = true;
    description = "Conor Manning";
    home = "/home/conor";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
      pkgs.vlc
      pkgs.ijq
      pkgs.abcde
    ];
    shell = pkgs.zsh;
  };

  # Theme settings stuff
  # TODO: Profile picture stuff
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "yellow";
        };
        "org/gnome/desktop/background" = {
          picture-uri =
            "file://" + ./kanagawa-wave.jpg;
          picture-uri-dark =
            "file://" + ./kanagawa-wave.jpg;
          # picture-options = "zoom";
        };
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
      };
    }
  ];

  # Default shell to zsh
  programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    zed = "zeditor";
  };
}
