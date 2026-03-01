{
  nodes.Image = {
    includes = [ ../platform/Image.nix ];

    traits = [
      "base"
      "disko"
      "software"
    ];

    schema = {
      base = {
        hostName = "Image";
        userName = "saya";
        password = "";
        useSudo-rs = true;
        useWireless = false;
        useTPM2 = false;
        useBluetooth = false;
        useAudio = false;
      };
      software.extra = false;
      disko = {
        device = "/dev/vda";
        withLUKS = false;
        espSize = "100M";
        imageSize = "3G";
      };
    };
  };
}
