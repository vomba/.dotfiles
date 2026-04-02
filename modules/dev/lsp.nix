{ pkgs, pkgs-stable, ... }:
{
  home.packages = [
    # Nix
    pkgs.nixfmt
    pkgs.nil

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
}
