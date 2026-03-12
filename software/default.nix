{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./fcitx5.nix
    ./font.nix
    ./proxy.nix
  ];

  environment.systemPackages = with pkgs; [
    file
    gnupg
    ncdu
    nh
    nix-output-monitor
    nixfmt-tree
    parted
    p7zip
    tree
    unrar-free
    unzip
    wget
    zip
  ];

  programs = {
    git = {
      enable = true;
      config = {
        core.autocrlf = "input";
        core.editor = "vim";
        merge.autoStash = true;
        pull.autoStash = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "*";
      };
    };
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-tty;
    };
    htop = {
      enable = true;
      settings = {
        color_scheme = 6;
        hide_userland_threads = true;
        highlight_base_name = true;
        highlight_changes = true;
        shadow_other_users = true;
        show_cpu_temperature = true;
        show_program_path = false;
        tree_view = true;
      };
    };
    nix-ld.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };

  services = {
    envfs.enable = true;
    flatpak.enable = true;
  };
}
