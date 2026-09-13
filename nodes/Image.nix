{
  nodes.Image = {
    includes = [ ../platform/Image.nix ];

    traits = [
      "base"
      "extra/disko"
      "network"
      "secrets"
      "software"
    ];

    schema = {
      base = {
        username = "saya";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObSiBahejD/fe1MOfbrW1XF29t/4yRAPcwphHEFVqET main@saltedfishes.com"
        ];
        bluetooth.enable = false;
        pipewire.enable = false;
        sudo-rs.enable = true;
        tpm2.enable = false;
      };
      extra.disko = {
        device = "/dev/null";
        withLUKS = false;
        espSize = "100M";
        imageSize = "3G";
      };
      network = {
        hostname = "Image";
        wireless.enable = false;
      };
      software.extra = false;
    };
  };
}
