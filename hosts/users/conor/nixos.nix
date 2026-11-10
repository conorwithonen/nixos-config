{  config, pkgs, ...}:
let
  username = "conor";
in
{
  users.users.${username} = {
    isNormalUser = true;
    description = "Conor Manning";
    hashedPassword = "$6$bXsGPpJNJx99PuR8$wtSFCJPKIMFqHFEGye1hyRpWIcSphpuoXo1bMLm6c3nynask2jx/jQB7h8/kU1cMBqdiROFKIUfSldtCCwBeM1";
    home = "/home/${username}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
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
}
