{ pkgs, pkgs-stable, ... }:
{
  programs.opencode = {
    enable = if pkgs.stdenv.isLinux then false else true;
    settings = {
      provider = {
        mistral = {
          npm = "@ai-sdk/openai-compatible";
          name = "Mistral AI";
          options = {
            baseURL = "https://api.mistral.ai/v1";
          };
        };
        google = {
          models = {
            "gemini-2.5-pro" = { };
          };
        };
        lmstudio = {
          npm = "@ai-sdk/openai-compatible";
          name = "LM Studio (local)";
          options = {
            baseURL = "http://localhost:1234/v1";
          };
          models = {
            "essentialai/rnj-1" = {
              name = "rnj1";
            };
          };
        };
      };
    };
  };

  home.packages = []
  ++ (
    if pkgs.stdenv.isDarwin then
      [
        pkgs-stable.lmstudio
      ]
    else
      [ ]
  );

}
