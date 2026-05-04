{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.dev.lsp.enable {
    home.packages = [
      # Nix
      pkgs.nixfmt
      pkgs.nixd
      pkgs.nix-tree
      pkgs.typos-lsp

      # Bash
      pkgs.bash-language-server
      pkgs.shellcheck

      # Web / Config
      pkgs.yaml-language-server
      pkgs.vscode-json-languageserver
      pkgs-stable.jq # Required for jq-lsp often, but lsp is separate
      pkgs.jq-lsp

      # Markdown
      pkgs.marksman
      pkgs.mpls

      # Terraform
      pkgs.terraform-ls

      # Helm
      pkgs.helm-ls

      # Go
      pkgs.gopls
      pkgs.delve # Debugger, often goes with LSP
    ];
  };
}
