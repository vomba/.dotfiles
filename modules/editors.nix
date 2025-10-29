{
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
}
