{ pkgs, ... }:

{
  nixGL = {
    packages = pkgs.nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = false;
  };
}
