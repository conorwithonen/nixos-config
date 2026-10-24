# This function creates a NixOS system based on our VM setup for a
# particular architecture.
# Shamefully ripped from mitchellh
{ nixpkgs, overlays, inputs }:

name:
{
  system,
  user,
  darwin ? false,
}:

let
  # True if Linux, which is a heuristic for not being Darwin.
  isLinux = !darwin;

  # The config files for this system.
  machineConfig = ../hosts/${name}/default.nix;
  userOSConfig = ../hosts/users/${user}/${if darwin then "darwin" else "nixos" }.nix;
  userHMConfig = ../hosts/users/${user}/home.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  inherit (nixpkgs.lib);
in systemFunc rec {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }
    { nixpkgs.config.allowUnfree = true; }
  ] ++ [
    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        inputs = inputs;
        currentSystemName = name;
      };
    }
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        inputs = inputs;
      };
    }

  ];
}
