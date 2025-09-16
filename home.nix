{
  pkgs,
  pkgs-stable,
  pkgs-25,
  nixGL,
  config,
  lib,
  inputs,
  ...
}:
{

  home.username = "hani";
  home.homeDirectory = "/home/hani";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

  nixGL = {
    packages = nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = false;
  };

  imports = [
    ./hyprland.nix
    ./kanshi.nix
    ./zsh.nix
  ];

  programs.fzf.enable = true;
  programs.bat.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language-server.terraform-ls = {
        command = "terraform-ls";
        arg = [ "serve" ];
      };

      language = [
        {
          name = "nix";
          file-types = [ "nix" ];
          formatter = {
            command = "nixfmt";
          };
        }
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform";
        }
        {
          name = "tfvars";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform-vars";
        }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    package = (config.lib.nixGL.wrap pkgs.kitty);
  };

  programs.chromium = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.chromium;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
    ];
  };

  # programs.obs-studio = {
  #   enable = true;
  #   package = config.lib.nixGL.wrap pkgs.obs-studio;
  # };

  programs.go = {
    enable = true;
    env = {
      # GOPATH = "go";
      GOPRIVATE = [
        "github.com/elastisys"
      ];
    };
    packages = {
      "github.com/elastisys/releaser" = builtins.fetchGit "https://github.com/elastisys/releaser/";
    };
  };

  home.packages = [
    pkgs.direnv
    pkgs.zoxide
    pkgs.git
    pkgs.nixfmt-rfc-style
    pkgs.nil
    pkgs.pre-commit
    pkgs.kubie
    pkgs.kind
    pkgs.gh
    pkgs.sops
    pkgs.starship
    pkgs-stable.yq-go
    pkgs-stable.jq
    pkgs.bitwarden-cli
    pkgs.bash-language-server
    pkgs.clusterctl
    pkgs.openstackclient-full
    pkgs-stable.kubernetes-helm
    pkgs-stable.helmfile
    pkgs.rbw
    pkgs.kubecolor
    pkgs.kubectl
    pkgs.kubelogin-oidc
    pkgs.eza
    pkgs.awscli2
    pkgs-25.azure-cli
    pkgs.azure-storage-azcopy
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.sonobuoy
    pkgs.yaml-language-server
    pkgs.helm-ls
    pkgs.velero
    pkgs.marksman
    pkgs.glow
    pkgs.jq-lsp
    pkgs.tenv
    pkgs.hugo
    pkgs.nodejs_24
    pkgs.superhtml
    pkgs.nautilus
    pkgs.upcloud-cli
    pkgs.vscode-json-languageserver
    pkgs.terraform-ls
    pkgs.cmctl
    pkgs.socat

    pkgs.grim
    pkgs.slurp
    pkgs.swaybg
    pkgs.wdisplays
    pkgs.hyprland-qtutils
    pkgs.hyprutils
  ];

  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".kube/kubie.yaml".source = ./kubie.yaml;
  home.file.".config/starship.toml".source = ./starship.toml;
  home.file.".config/rbw/config.json".source = ./rbw-config.json;
  home.file.".config/ck8s-devbox/credentials-helper.bash".source = ./credentials-helper.bash;
  home.file.".config/fontconfig/conf.d/10-nix-fonts.conf".source = ./10-nix-fonts.conf;

}
