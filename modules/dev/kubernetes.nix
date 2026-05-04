{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
let
  helmWithPlugins = pkgs.kubernetes-helm.withPlugins (p: [
    p.helm-diff
    p.helm-secrets
    p.helm-secrets-getter
    p.helm-secrets-post-renderer
  ]);
  helmPluginsPath = "${helmWithPlugins}";
in
{
  config = lib.mkIf config.dotfiles.dev.kubernetes.enable {

    home.packages = [
      pkgs.kubie
      pkgs.kind
      # pkgs-stable.clusterctl
      helmWithPlugins
      pkgs.helmfile
      pkgs.kubecolor
      pkgs.kubectl
      pkgs.kubelogin-oidc
      pkgs.sonobuoy
      pkgs.velero
      pkgs.popeye
      pkgs.krew
      pkgs.crossplane-cli
      pkgs.kubectl-view-secret
    ];

    home.file.".kube/kubie.yaml".source = ../../kubie.yaml;

    # Helm v4 uses XDG directories for plugin detection, but helmfile uses
    # the Helm library which doesn't respect HELM_PLUGINS env var.
    # Create a symlink so Helm v4's PluginsDirectory resolves correctly.
    home.activation.helmPluginsLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "''${HOME}/.local/share/helm"
      if [ -e "''${HOME}/.local/share/helm/plugins" ]; then
        $DRY_RUN_CMD rm -f $VERBOSE_ARG "''${HOME}/.local/share/helm/plugins"
      fi
      $DRY_RUN_CMD ln -sf $VERBOSE_ARG "${helmPluginsPath}" "''${HOME}/.local/share/helm/plugins"
    '';
  };
}
