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
    pkgs-25.clusterctl
    pkgs-stable.kubernetes-helm
    pkgs-stable.helmfile
    pkgs.kubecolor
    pkgs-25.kubectl
    pkgs.kubelogin-oidc
    pkgs.sonobuoy
    pkgs.velero
    pkgs.popeye
    pkgs.krew
  ];

  home.file.".kube/kubie.yaml".source = ../kubie.yaml;
}
