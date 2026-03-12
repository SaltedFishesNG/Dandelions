{
  nixpkgs,
  system ? "x86_64-linux",
}:
let
  applyPatches = nixpkgs.legacyPackages.${system}.applyPatches;

  patched = toString (applyPatches {
    name = "nixpkgs-patched";
    src = nixpkgs;
    patches = [
      (builtins.fetchurl {
        name = "cryptsetup-make-systemd-token-modules-discoverable.patch";
        url = "https://github.com/NixOS/nixpkgs/pull/487497.patch";
        sha256 = "sha256-GpEPAnJiVmntO7A3GYWFliwcWytwz7Z2o0iftEWbQ7k=";
      })
    ];
  });

  nixpkgs-patched = (import "${patched}/flake.nix").outputs {
    self = (import "${patched}/flake.nix" // { outPath = patched; });
  };
in
nixpkgs-patched
