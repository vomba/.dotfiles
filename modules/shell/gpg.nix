{
  pkgs,
  lib,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  programs.gpg = {
    enable = isDarwin;
    settings = {
      trust-model = "tofu+pgp";
    };
  };

  services.gpg-agent = {
    enable = isDarwin;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = if isDarwin then pkgs.pinentry_mac else null;
  };

  home.packages = lib.optional isDarwin pkgs.pinentry_mac;

  # Shell integration (applies to both systems to ensure env vars are set)
  programs.zsh.initContent = ''
    export GPG_TTY="$(tty)"
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
  '';
}
