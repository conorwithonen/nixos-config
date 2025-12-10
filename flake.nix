{
  description = "The world's most basic NixOS configuration.";
  inputs = {
    nixpkgs.url =  "github:NixOS/nixpkgs/nixos-25.05";
    # zed = {
    #     url = "github:zed-industries/zed";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs = { self, nixpkgs, ... }@inputs:
  let
      system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      # Linux laptop
      nixbook = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/nixbook];
      };
    };
  };
}
