{
  description = "The world's most basic NixOS configuration.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-firefox-addons.url = "github:osipog/nix-firefox-addons";

    legacy-dotfiles = {
      url = "github:conorwithonen/dotfiles";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    home-manager,
    legacy-dotfiles,
    hunk, ... }@inputs:
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
          obsidian = unstable.obsidian;
          starship = unstable.starship;
          yazi = unstable.yazi;

        })
        inputs.nix-firefox-addons.overlays.default
      ];
      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs overlays inputs legacy-dotfiles hunk;
      };
  in
  {
    nixosConfigurations.nixbook = mkSystem "nixbook" {
       system = "x86_64-linux";
       user = "conor";
    };
    darwinConfigurations.work-machbook-pro = mkSystem "work-machbook-pro" {
          system = "aarch64-darwin";
          user   = "conor";
          username = "conor.manning";
          darwin = true;
    };
  };
}
