{
  # home.packages = with pkgs; [ lsp-ai ];
  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language-server = {
        terraform-ls = {
          command = "terraform-ls";
          arg = [ "serve" ];

        };
        mpls = {
          command = "mpls";
          args = [
            "--dark-mode"
            "--enable-emoji"
          ];
        };
        # lsp-ai = {
        #   command = "lsp-ai";
        #   config = {
        #     memory = {
        #       file_store = {};
        #     };
        #     models = {
        #       model1 = {
        #         type = "gemini";
        #         completions_endpoint = "https://generativelanguage.googleapis.com/v1beta/models/";
        #         chat_endpoint = "https://generativelanguage.googleapis.com/v1beta/models/";
        #         model = "gemini-1.5-pro-latest";
        #         auth_token_env_var_name = "GEMINI_API_KEY";
        #       };
        #     };
        #     chat = [
        #       {
        #         trigger = "!C";
        #         action_display_name = "Chat";
        #         model = "model1";
        #         parameters = { contents = []; };
        #       }
        #     ];
        #   };
        # };
      };
      language = [
        {
          name = "nix";
          file-types = [ "nix" ];
          formatter = {
            command = "nixfmt";
          };
        }
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform";
        }
        {
          name = "tfvars";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform-vars";
        }
        {
          name = "markdown";
          language-servers = [
            "marksman"
            "mpls"
          ];
        }
      ];
    };
  };
  # home.sessionVariables = {
  #   GEMINI_API_KEY = "your-api-key-here";
  # };
}
