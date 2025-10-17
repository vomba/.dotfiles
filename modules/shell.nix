{
  pkgs, ...
}: {

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.bat.enable = true;

  home.packages = [
    pkgs.zoxide
    pkgs.starship
    pkgs.eza
  ];

  home.file.".config/starship.toml".source = ../starship.toml;
}
