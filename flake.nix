{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
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
