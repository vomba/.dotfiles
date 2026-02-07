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
            "jan-v3-4b-base-instruct" = {
              name = "jan";
            };
            "ministral-3-3b-reasoning-2512" = {
              name = "ministral 3 reason";
            };
          };
        };
      };
    };
  };

  home.packages =
    [ ]
    ++ (
      if pkgs.stdenv.isDarwin then
        [
          pkgs-stable.lmstudio
          pkgs.mistral-vibe
        ]
      else
        [ ]
    );

}
