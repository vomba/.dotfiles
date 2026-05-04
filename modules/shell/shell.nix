{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.shell.enable {

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      # config = { ... }; # Add themes or config here if needed
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ]; # Replace cd with zoxide
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    programs.fd = {
      enable = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      # Load settings from the existing toml file
      settings = builtins.fromTOML (builtins.readFile ../../starship.toml);
    };
  };
}
