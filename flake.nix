{
  description = "The world's most basic NixOS configuration.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
      system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      # Linux laptop
      nixbook = nixpkgs.lib.nixosSystem {
        specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
            };
        };
        modules = [./hosts/nixbook];
      };
    };
  };
}
