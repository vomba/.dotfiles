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
      yq4 = "yq";
    };
    initContent = ''
      export GOPATH=$HOME/.go
      export PATH=$PATH:$GOPATH/bin
      export KREW_ROOT=$HOME/.krew
      export PATH="$KREW_ROOT/bin:$PATH"
      export GOOGLE_CLOUD_PROJECT=elastisys-vertex-poc
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
