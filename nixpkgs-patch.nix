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
      (builtins.fetchurl {
        name = "xray-fix-TUN-functionality-with-DeviceAllow";
        url = "https://github.com/NixOS/nixpkgs/pull/482023.patch";
        sha256 = "sha256-tX95NFUe3Sp0dhKHJkjNI/n1cKrjf0TWpFm2aJVnOpA=";
      })
    ];
  });

  nixpkgs-patched = (import "${patched}/flake.nix").outputs {
    self = (import "${patched}/flake.nix" // { outPath = patched; });
  };
in
nixpkgs-patched
