{ config, inputs, ... }:
{
  flake.formatter = inputs.nixpkgs.lib.genAttrs config.systems (
    system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree
    # system: inputs.nixpkgs.legacyPackages.${system}.alejandra
  );

  flake.packages.x86_64-linux = {
    diskoImage = inputs.self.nixosConfigurations.Image.config.system.build.diskoImages;
    iso = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
    # iso = inputs.self.nixosConfigurations.iso.config.system.build.images.iso;
  };
}
