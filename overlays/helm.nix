{ super }:

let
  helm = super.kubernetes-helm.overrideAttrs (oldAttrs: rec {
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
  });

  # A helper function to build custom helm plugins from source
  buildHelmPlugin =
    {
      pluginName,
      version,
      src,
      postPatch ? "",
      preFixup ? "",
      ...
    }@args:
    super.stdenv.mkDerivation (
      args
      // {
        pname = pluginName;
        inherit
          version
          src
          postPatch
          preFixup
          ;
        dontBuild = true;
        installPhase =
          args.installPhase or ''
            runHook preInstall
            install -d $out/${pluginName}
            cp -r * $out/${pluginName}/
            runHook postInstall
          '';
      }
    );

  customHelmPlugins = super.kubernetes-helmPlugins // {
    # Override helm-secrets to use the latest version split into 3 plugins for helm 4
    helm-secrets = buildHelmPlugin rec {
      pluginName = "helm-secrets";
      version = "4.7.5";
      src = super.fetchurl {
        url = "https://github.com/jkroepke/helm-secrets/releases/download/v${version}/secrets-${version}.tgz";
        hash = "sha256-DP5Qs0D+LJWdKz/23NtAXTX9mwiiSr7HqGjTPqtglJk=";
      };
    };

    helm-secrets-getter = buildHelmPlugin rec {
      pluginName = "helm-secrets-getter";
      version = "4.7.5";
      src = super.fetchurl {
        url = "https://github.com/jkroepke/helm-secrets/releases/download/v${version}/secrets-getter-${version}.tgz";
        hash = "sha256-Ul/FHm5eXamDfR1RCvLvxDxqK576kwN5TTWzzwy84p8=";
      };
    };

    helm-secrets-post-renderer = buildHelmPlugin rec {
      pluginName = "helm-secrets-post-renderer";
      version = "4.7.5";
      src = super.fetchurl {
        url = "https://github.com/jkroepke/helm-secrets/releases/download/v${version}/secrets-post-renderer-${version}.tgz";
        hash = "sha256-BH4UkzFgDjLU8a/GHrP/SbVk+6YSQuLowTr81kEER44=";
      };
    };

    # Example of a fully custom plugin from a repo using the helper function:
    # my-custom-plugin = buildHelmPlugin {
    #   pluginName = "my-custom-plugin";
    #   version = "1.0.0";
    #   src = super.fetchFromGitHub {
    #     owner = "example";
    #     repo = "my-custom-plugin";
    #     rev = "v1.0.0";
    #     hash = "sha256-...";
    #   };
    # };
  };

in
helm.overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // {
    withPlugins =
      pluginsFn:
      super.wrapHelm helm {
        plugins = pluginsFn customHelmPlugins;
      };
    inherit buildHelmPlugin customHelmPlugins;
  };
})
