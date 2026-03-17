{ super }:

super.kubernetes-helm.overrideAttrs (oldAttrs: rec {
  pname = "kubernetes-helm";
  version = "4.1.3";

  src = super.fetchFromGitHub {
    owner = "helm";
    repo = "helm";
    rev = "v${version}";
    hash = "sha256-9a8Tuv3VtGeQXZTEf/xo+u6+OpQYLrJNYIFzO2/iiZs=";
  };

  proxyVendor = true;
  vendorHash = "sha256-Xst69X7tqIsiABItWFQRHz4qmiUxRyPQttPqmX1Ko1w=";

  doCheck = false;

  ldflags = [
    "-w"
    "-s"
    "-X helm.sh/helm/v4/internal/version.version=v${version}"
    "-X helm.sh/helm/v4/internal/version.gitCommit=${src.rev}"
  ];

  preBuild = ''
    # set k8s version to client-go version, to match upstream
    K8S_MODULES_VER="$(go list -f '{{.Version}}' -m k8s.io/client-go)"
    K8S_MODULES_MAJOR_VER="$(($(cut -d. -f1 <<<"$K8S_MODULES_VER") + 1))"
    K8S_MODULES_MINOR_VER="$(cut -d. -f2 <<<"$K8S_MODULES_VER")"
    old_ldflags="''${ldflags}"
    ldflags="''${ldflags} -X helm.sh/helm/v4/pkg/lint/rules.k8sVersionMajor=''${K8S_MODULES_MAJOR_VER}"
    ldflags="''${ldflags} -X helm.sh/helm/v4/pkg/lint/rules.k8sVersionMinor=''${K8S_MODULES_MINOR_VER}"
    ldflags="''${ldflags} -X helm.sh/helm/v4/pkg/chartutil.k8sVersionMajor=''${K8S_MODULES_MAJOR_VER}"
    ldflags="''${ldflags} -X helm.sh/helm/v4/pkg/chartutil.k8sVersionMinor=''${K8S_MODULES_MINOR_VER}"
  '';
})
