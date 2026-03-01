{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      userName = "alice";
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forSystems = f: nixpkgs.lib.genAttrs systems f;
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
        specialArgs = { inherit inputs userName; };
      };
      formatter = forSystems (s: nixpkgs.legacyPackages.${s}.nixfmt-tree);
    };
}
