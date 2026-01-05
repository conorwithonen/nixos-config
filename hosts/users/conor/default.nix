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

  # Default shell to zsh
  programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    zed = "zeditor";
  };
}
