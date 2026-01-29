{
  pkgs,
  services,
  ...
}:
{
  programs.gpg = {
    enable = if pkgs.stdenv.isLinux then false else true;
    settings = {
      trust-model = "tofu+pgp";
    };
  };

  services.gpg-agent = {
    enable = if pkgs.stdenv.isLinux then false else true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  home.packages = [
    pkgs.pinentry_mac
  ];
}
