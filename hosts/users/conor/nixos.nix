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

  # User picture hack
  system.activationScripts.setUserIcon = ''
    cp ${./icon.png} /var/lib/AccountsService/icons/${username}
    chmod 644 /var/lib/AccountsService/icons/${username}
  '';

  # Theme settings stuff
  programs.dconf.enable = true;
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
  	policies = {
  	  DisableTelemetry = true;
  	};
  };

  # Niri
  programs.niri.enable = false;

  programs.zsh.enable = true;
}
