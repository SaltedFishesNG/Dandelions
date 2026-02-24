{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    nixy.url = "github:cuskiy/nixy";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, nixy, ... }:
    let
      lib = nixpkgs.lib;
      overlay = import ./pkgs;
      cluster =
        system:
        nixy.eval {
          inherit lib;
          imports = [
            ./traits
            ./hosts
          ];
          args = { inherit inputs system; };
        };
      mkSystem =
        node:
        lib.nixosSystem {
          modules = [
            node.module
            { nixpkgs.overlays = [ overlay ]; }
          ];
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      flake.nixosConfigurations = lib.mapAttrs (_: mkSystem) (cluster null).nodes;

      perSystem =
        { system, ... }:
        let
          nodes = (cluster system).nodes;
        in
        {
          formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
          packages = {
            diskoImage = (mkSystem nodes.Image).config.system.build.diskoImages;
            iso = (mkSystem nodes.iso).config.system.build.isoImage;
          };
        };
    };
}
