{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "openstack-tui";
  version = "0.0.0-unstable-2026-02-06";

  src = fetchFromGitHub {
    owner = "gtema";
    repo = "openstack";
    rev = "f1002a312acade6c2233fb46fb6e4e2a0dcf7ea3";
    sha256 = "sha256-93Mbfg3Mzy036bkN0L/5JGsR1KdM6nakbQKlXWr1yPU=";
  };

  cargoHash = "sha256-XjJ0K57vxmNJ7HzQoSXqWOtG4pnJs3vzDet8jjsh6cE=";

  doCheck = false;

  meta = with lib; {
    description = "OpenStack TUI client (Rust)";
    homepage = "https://github.com/gtema/openstack";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}