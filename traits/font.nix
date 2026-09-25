{
  schema.font = {
    extra = false; # bool
  };

  traits.font =
    {
      lib,
      node,
      pkgs,
      ...
    }:
    {
      fonts = {
        enableDefaultPackages = false;
        packages =
          with pkgs;
          [
            fira-code
            font-awesome
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
            sarasa-gothic
          ]
          ++ lib.optionals node.schema.font.extra [
            iosevka
            jetbrains-mono
            maple-mono.NF-CN
            nerd-fonts.fira-code
            source-code-pro
          ];
        fontconfig.defaultFonts = {
          serif = [ "Noto Serif" ] ++ [ "Noto Serif CJK TC" ];
          sansSerif = [ "Noto Sans" ] ++ [ "Noto Sans CJK TC" ];
          monospace = [ "Fira Code" ] ++ [ "Sarasa Mono CL" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
