# This function creates a NixOS system based on our VM setup for a
# particular architecture.
# Shamefully ripped from mitchellh
{ nixpkgs, overlays, inputs, legacy-dotfiles, hunk }:

name:
{
  system,
  user,
  username ? user,
  darwin ? false,
}:

let
  # True if Linux, which is a heuristic for not being Darwin.
  isLinux = !darwin;

  # The config files for this system.
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if darwin then "darwin" else "nixos" }.nix;
  userHMConfig = ../users/${user}/home.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  sops-nix = inputs.sops-nix.homeManagerModules.sops;
  sopsSystemModule = if darwin then inputs.sops-nix.darwinModules.sops else inputs.sops-nix.nixosModules.sops;

  inherit (nixpkgs.lib);
in systemFunc rec {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }
    { nixpkgs.config.allowUnfree = true; }
  ] ++ [
    sopsSystemModule
    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit legacy-dotfiles user; };
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = import userHMConfig {
        inputs = inputs;
        currentSystemName = name;
      };
    }
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        currentSystemUsername = username;
        inputs = inputs;
      };
    }

  ];
}
