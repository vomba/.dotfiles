{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # settings = { ... }; # Add configuration here later if needed
  };
}
