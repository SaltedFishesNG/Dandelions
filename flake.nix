{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      username = "alice";
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
      formatter = builtins.mapAttrs (system: pkgs: pkgs.nixfmt-tree) nixpkgs.legacyPackages;
    };
}
