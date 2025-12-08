{
  description = "The world's most basic NixOS configuration.";
  inputs = {
    nixpkgs.url =  "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Linux laptop
      nixbook = nixpkgs.lib.nixosSystem {
        modules = [./hosts/nixbook];
      };
    };
  };
}
