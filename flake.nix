{
  description = "The world's most basic NixOS configuration.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    legacy-dotfiles = {
      url = "github:conorwithonen/dotfiles";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
      overlays = [
        (_final: prev: let
          system = prev.stdenv.hostPlatform.system;
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in {
          zed-editor = unstable.zed-editor;
        })
      ];
      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs overlays inputs;
      };
  in
  {
    nixosConfigurations = {
      nixbook = mkSystem "nixbook" {
       system = "x86_64-linux";
       user = "conor";
      };
    };
  };
}
