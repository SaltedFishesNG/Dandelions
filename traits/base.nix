{
  schema.base = {
    useLix = false; # bool
    nixSubstituters = [ ]; # listOf str

    username = "alice"; # str
    password = null; # null or str
    hashedPassword = null; # null or str
    authorizedKeys = [ ]; # listOf singleLineStr

    useSudo-rs = false; # bool
    useTPM2 = true; # bool
    useBluetooth = true; # bool
    useAudio = true; # bool
  };

  traits.base =
    {
      config,
      lib,
      node,
      pkgs,
      ...
    }:
    let
      cfg = node.schema.base;
    in
    {
      time.timeZone = "UTC";
      i18n.defaultLocale = "C.UTF-8";
      console.keyMap = "us";

      boot = {
        kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
        zfs.forceImportRoot = false;
        binfmt.emulatedSystems = builtins.filter (s: s != pkgs.stdenv.hostPlatform.system) [
          "aarch64-linux"
          "riscv64-linux"
          "x86_64-linux"
        ];
        plymouth.enable = false;
        initrd.systemd.enable = true;
        loader.systemd-boot.enable = lib.mkDefault true;
        loader.systemd-boot.configurationLimit = 25;
        loader.efi.canTouchEfiVariables = true;
      };
      system.nixos-init.enable = true;
      system.etc.overlay.enable = true;

      users.mutableUsers = false;
      users.users.${cfg.username} = {
        password = if (cfg.hashedPassword != null || cfg.password != null) then cfg.password else "";
        hashedPassword = cfg.hashedPassword;
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
        isNormalUser = true;
        extraGroups = [
          "audio"
          "input"
          "video"
          "wheel"
        ];
        shell = pkgs.fish;
      };
      programs.fish = {
        enable = true;
        shellAbbrs = {
          sudo = lib.mkIf (!cfg.useSudo-rs) "doas";
        };
        interactiveShellInit = "set fish_color_command blue";
      };

      security = {
        doas = {
          enable = true;
          extraConfig = "permit persist keepenv :wheel";
        };
        rtkit.enable = true;
        sudo.enable = false;
        sudo-rs = {
          enable = cfg.useSudo-rs;
          execWheelOnly = true;
          wheelNeedsPassword = false;
        };
        tpm2 = {
          enable = cfg.useTPM2;
          pkcs11.enable = true;
          tctiEnvironment.enable = true;
        };
      };

      hardware.bluetooth = {
        enable = cfg.useBluetooth;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      services = {
        logind.settings.Login = {
          HandlePowerKey = "hibernate";
          HandleLidSwitch = "suspend-then-hibernate";
        };
        openssh = {
          enable = true;
          ports = [ 22 ];
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = lib.mkForce "prohibit-password";
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
          enable = cfg.useAudio;
          alsa.enable = true;
          pulse.enable = true;
        };
      };

      documentation.nixos.enable = false;
      documentation.man.cache.enable = false; # Slow build due to fish enabling caches

      nix = {
        package = if cfg.useLix then pkgs.lixPackageSets.stable.lix else pkgs.nixVersions.latest;
        channel.enable = false;
        settings = {
          allowed-users = [ "root" ] ++ config.nix.settings.trusted-users;
          auto-allocate-uids = true;
          auto-optimise-store = true;
          builders-use-substitutes = true;
          download-attempts = 15;
          experimental-features = [
            "auto-allocate-uids"
            "cgroups"
            "flakes"
            "nix-command"
          ]
          ++ lib.optionals cfg.useLix [ "pipe-operator" ]
          ++ lib.optionals (!cfg.useLix) [
            "ca-derivations"
            "pipe-operators"
          ];
          pure-eval = true;
          stalled-download-timeout = 15;
          substituters = cfg.nixSubstituters ++ [
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          trusted-users = [
            "${cfg.username}"
            "@wheel"
          ];
          use-cgroups = true;
          warn-dirty = false;
        };
      };

      system.stateVersion = lib.mkDefault "26.05";
    };
}
