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
}
