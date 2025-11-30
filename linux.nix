{
  pkgs,
  nixGL,
  ...
}:
{
  imports = [
    ./modules/hyprland.nix
    ./modules/kanshi.nix
  ];

  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL = {
    packages = nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = false;
  };

}
