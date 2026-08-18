{
  lib,
  pkgs,
  username,
  ...
}:
let
  useNetworkManager = true;
in
{
  time.timeZone = "UTC";
  i18n.defaultLocale = "C.UTF-8";
  i18n.extraLocales = "all";
  console.keyMap = "us";

  boot = {
    kernelParams = [ "drm.panic_screen=qr_code" ];
    zfs.forceImportRoot = false;
    plymouth.enable = false;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.systemd-boot.configurationLimit = 25;
    loader.efi.canTouchEfiVariables = true;
  };
  systemd.enableEmergencyMode = false;
  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;

  networking = {
    hostName = "NixOS";
    hostId = "00000000";
    dhcpcd.enable = false;
    resolvconf.enable = false;
    networkmanager.enable = useNetworkManager;
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
    nftables.enable = true;
    useNetworkd = (!useNetworkManager);
    useDHCP = (!useNetworkManager);
  };
  systemd.network.enable = (!useNetworkManager);
  services.resolved.enable = false;
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 2606:4700:4700::1111
    nameserver 8.8.8.8
    nameserver 2001:4860:4860::8888
  '';
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  users.mutableUsers = false;
  users.users.${username} = {
    password = "";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_color_command blue
      bind ctrl-w backward-kill-bigword
    '';
  };

  security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  services = {
    # logind.settings.Login = {
    #   HandlePowerKey = "hibernate";
    #   HandleLidSwitch = "suspend-then-hibernate";
    # };
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkForce "prohibit-password";
        X11Forwarding = true;
      };
    };
    kmscon = {
      enable = true;
      extraOptions = "--term xterm-256color";
    };
    zram-generator = {
      enable = true;
      settings.zram0 = {
        compression-algorithm = "zstd";
        zram-size = "ram";
      };
    };
    userborn.enable = true;
    dbus.implementation = "broker";
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  documentation.nixos.enable = false;
  documentation.man.cache.enable = false; # Slow build due to fish enabling caches

  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      allowed-users = [ "@wheel" ];
      auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      download-attempts = 15;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      pure-eval = true;
      stalled-download-timeout = 15;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      use-cgroups = true;
      warn-dirty = false;
    };
  };
}
