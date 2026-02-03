{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "helmfile";
  version = "0.171.0";

  src = fetchFromGitHub {
    owner = "helmfile";
    repo = "helmfile";
    rev = "v${version}";
    sha256 = "0iwf5rknr5jv8dr02llf0ksg8w227458smvbhchs43lv25ip96yd";
  };

  vendorHash = "sha256-sGqnM40Y1nr9dXcSSC1lkwh1ToRLpCMiWJhyMcxxH9U=";

  proxyVendor = true;

  doCheck = false;

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X go.szostok.io/version.version=v${version}"
  ];
}
