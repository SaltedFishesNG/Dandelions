{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      username = "alice";
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed f;
    in
    {
      nixosConfigurations.NixOS = nixpkgs.lib.nixosSystem {
        modules = [
          ./modules
          ./resource
          ./software
          ./configuration.nix
          ./hardware.nix
        ];
        specialArgs = { inherit inputs username; };
      };
      formatter = forAllSystems (s: nixpkgs.legacyPackages.${s}.nixfmt-tree);
    };
}
