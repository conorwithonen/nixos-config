{  config, pkgs, ...}:{
  users.users.conor = {
    isNormalUser = true;
    description = "Conor Manning";
    home = "/home/conor";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # Default shell to zsh
  programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    zed = "zeditor";
  };
}
