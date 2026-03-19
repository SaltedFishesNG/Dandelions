{ lib, mkOpt, ... }:
{
  schema.font = {
    extra = mkOpt lib.types.bool false;
  };

  traits.font =
    {
      lib,
      node,
      pkgs,
      ...
    }:
    let
      cfg = node.schema.font;
    in
    {
      fonts = {
        enableDefaultPackages = false;
        packages =
          with pkgs;
          [
            fira-code
            font-awesome
            iosevka
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
            sarasa-gothic
          ]
          ++ lib.optionals cfg.extra [
            jetbrains-mono
            maple-mono.NF-CN
            nerd-fonts.fira-code
            source-code-pro
          ];
        fontconfig.defaultFonts = {
          serif = [
            "Noto Serif"
            "Noto Serif CJK TC"
          ];
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK TC"
          ];
          monospace = [
            "Fira Code"
            "Iosevka"
            "Sarasa Mono CL"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
