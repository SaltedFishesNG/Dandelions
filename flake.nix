{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    nixy.url = "github:cuskiy/nixy";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    { nixpkgs, nixy, ... }@inputs:
    let
      cluster =
        system:
        nixy.eval {
          inherit (nixpkgs) lib;
          imports = [
            ./traits
            ./nodes
          ];
          args = { inherit inputs system; };
        };
      mkSystem = node: nixpkgs.lib.nixosSystem { modules = [ node.module ]; };
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed f;
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: mkSystem) (cluster null).nodes;
      packages = forAllSystems (s: {
        diskoImage = (mkSystem (cluster s).nodes.Image).config.system.build.diskoImages;
        iso = (mkSystem (cluster s).nodes.iso).config.system.build.isoImage;
      });
      formatter = forAllSystems (s: nixpkgs.legacyPackages.${s}.nixfmt-tree);
    };
}
