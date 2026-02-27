{
  nodes.Image = {
    includes = [ ../platform/Image.nix ];

    traits = [
      "base"
      "software"
      "disko"
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
