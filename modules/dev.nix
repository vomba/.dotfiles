{
  pkgs,
  pkgs-stable,
  pkgs-25,
  config,
  ...
}:
{

  services.podman = {
    enable = if pkgs.stdenv.isLinux then false else true;
  };

  programs.go = {
    enable = true;
    telemetry.mode = "off";
    env = {
      GOPATH = "${config.home.homeDirectory}/.go";
      GOPRIVATE = [
        "github.com/elastisys"
      ];
    };
  };

  programs.opencode = {
    enable = if pkgs.stdenv.isLinux then false else true;
    settings = {
      provider = {
        mistral = {
          npm = "@ai-sdk/openai-compatible";
          name = "Mistral AI";
          options = {
            baseURL = "https://api.mistral.ai/v1";

          };
        };
        google = {
          models = {
            "gemini-2.5-pro" = { };
          };
        };
        lmstudio = {
          npm = "@ai-sdk/openai-compatible";
          name = "LM Studio (local)";
          options = {
            baseURL = "http://localhost:1234/v1";
          };
          models = {
            "essentialai/rnj-1" = {
              name = "rnj1";
            };
          };
        };
      };
    };
  };

  home.packages = [
    pkgs-stable.lmstudio
    pkgs.direnv
    pkgs.nixfmt
    pkgs.nil
    pkgs.pre-commit
    pkgs.gh
    pkgs.sops
    pkgs-stable.yq-go
    pkgs-stable.jq
    pkgs.bitwarden-cli
    pkgs.bash-language-server
    pkgs.openstackclient-full
    pkgs.rbw
    pkgs-25.awscli2
    pkgs-25.azure-cli
    pkgs.azure-storage-azcopy
    pkgs.yaml-language-server
    pkgs.helm-ls
    pkgs.marksman
    pkgs.glow
    pkgs.jq-lsp
    pkgs.tenv
    pkgs.hugo
    pkgs.nodejs_24
    pkgs.superhtml
    pkgs.upcloud-cli
    pkgs.vscode-json-languageserver
    pkgs.terraform-ls
    pkgs.cmctl
    pkgs.socat
    pkgs.mpls
    pkgs.cidr
    pkgs.act
    pkgs.yubikey-manager
    pkgs.gopls
    pkgs.delve
  ]
  ++ (
    if pkgs.stdenv.isLinux then
      [
        pkgs.powershell
      ]
    else
      [ ]
  );

  home.file.".config/rbw/config.json".source = ../rbw-config.json;
  home.file.".config/ck8s-devbox/credentials-helper.bash".source = ../credentials-helper.bash;
}
