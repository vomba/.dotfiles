{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.sops.secrets) context7_api_key github_token;
  codegraphNode = pkgs.nodejs_22;

  context7-mcp = pkgs.writeShellScriptBin "context7-mcp" ''
    CONTEXT7_API_KEY="$(cat ${context7_api_key.path})" exec \
      npx -y "@upstash/context7-mcp@latest" "$@"
  '';

  codegraph-mcp = pkgs.writeShellScriptBin "codegraph-mcp" ''
    export PATH="${codegraphNode}/bin:$PATH"
    exec npx -y "@colbymchenry/codegraph@latest" serve --mcp "$@"
  '';

  codegraph-cli = pkgs.writeShellScriptBin "codegraph" ''
    export PATH="${codegraphNode}/bin:$PATH"
    exec npx -y "@colbymchenry/codegraph@latest" "$@"
  '';

  obsidian-mcp = pkgs.writeShellScriptBin "obsidian-mcp" ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    exec node "${../../apps/opencode/mcp/obsidian-mcp-wrapper.mjs}"
  '';

  github-mcp = pkgs.writeShellScriptBin "github-mcp" ''
    GITHUB_TOKEN="$(cat ${github_token.path})" exec \
      npx -y "@modelcontextprotocol/server-github@latest" "$@"
  '';
in
{
  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        command = "${context7-mcp}/bin/context7-mcp";
        args = [ ];
      };
      codegraph = {
        command = "${codegraph-mcp}/bin/codegraph-mcp";
        args = [ ];
      };
      obsidian = {
        command = "${obsidian-mcp}/bin/obsidian-mcp";
        args = [ ];
      };
      github = {
        command = "${github-mcp}/bin/github-mcp";
        args = [ ];
      };
    };
  };

  home.packages = [
    context7-mcp
    codegraph-mcp
    codegraph-cli
    obsidian-mcp
    github-mcp
  ];
}
