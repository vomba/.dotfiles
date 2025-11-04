{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    # settings = {
    #   keys.normal = {
    #     space.f = [
    #       ":sh rm -f /tmp/yazi-choice"
    #       ":sh yazi --chooser-file=/tmp/yazi-choice"
    #       ":open %sh{cat /tmp/yazi-choice}"
    #       ":redraw"
    #     ];

    #   };
    # };
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
