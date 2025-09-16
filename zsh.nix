{
  pkgs,
  config,
  ...
}:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    shellAliases = {
      cat = "bat";
    };
    initContent = ''
      compdef kubecolor=kubectl
      eval "$(starship init zsh)"
    '';
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      custom = "$HOME/.dotfiles/oh-my-zsh";
      plugins = [
        "git"
        "fzf"
        "gh"
        "helm"
        "zsh-kubecolor"
        "golang"
        "terraform"
        "aws"
        "pip"
        "python"
        "docker"
        "zoxide"
        "eza"
        "azure"
      ];
    };
  };
}
