{
  pkgs,
  services,
  ...
}:
{
  programs.gpg = {
    enable = if pkgs.stdenv.isLinux then false else true;
  };

  services.gpg-agent = {
      enable = if pkgs.stdenv.isLinux then false else true;

  };
}
