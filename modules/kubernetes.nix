{
  pkgs,
  pkgs-stable,
  pkgs-25,
  ...
}:
{

  home.packages = [
    pkgs.kubie
    pkgs.kind
    # pkgs-25.clusterctl
    (pkgs.kubernetes-helm.withPlugins (p: [
      p.helm-diff
      p.helm-secrets
      p.helm-secrets-getter
      p.helm-secrets-post-renderer
    ]))
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

  home.file.".kube/kubie.yaml".source = ../kubie.yaml;
}
