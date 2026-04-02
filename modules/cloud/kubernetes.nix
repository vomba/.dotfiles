{
  pkgs,
  pkgs-stable,
  pkgs-25,
  lib,
  ...
}:
let
  # Get the helm package with plugins to reference the plugins path
  helmWithPlugins = pkgs.kubernetes-helm.withPlugins (p: [
    p.helm-diff
    p.helm-secrets
    p.helm-secrets-getter
    p.helm-secrets-post-renderer
  ]);
  # Extract the plugins directory path from the wrapped helm
  # The plugins are installed in the root of the package by the custom overlay
  helmPluginsPath = "${helmWithPlugins}";
in
{

  home.packages = [
    pkgs.kubie
    pkgs.kind
    # pkgs-25.clusterctl
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
}
