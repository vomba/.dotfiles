{
  pkgs,
  nixGL,
  ...
}:
{
  imports = [
    ./modules/desktop/hyprland
    ./modules/desktop/kanshi.nix
  ];

  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL = {
    packages = nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = false;
  };

}
