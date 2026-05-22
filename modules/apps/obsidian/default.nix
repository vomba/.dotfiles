{
  pkgs,
  config,
  lib,
  obsidian-plugins,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  vaultDir = "${homeDir}/.vault";

  # Minimal plugin set — obsidian-second-brain skill handles the rest
  communityPluginsList = with obsidian-plugins.packages.${pkgs.system}; [
    { pkg = dataview; }
    {
      pkg = templater-obsidian;
      settings = {
        template_folder = "Templates";
        trigger_on_file_creation = true;
        auto_jump_to_cursor = false;
        enable_system_commands = false;
        timeout = 5;
        startup_templates = [ ];
        enabled_templates_hotkeys = [ ];
      };
    }
    {
      pkg = periodic-notes;
      settings = {
        calendarSets = [
          {
            id = "default";
            ctime = "2025-01-01T00:00:00.000Z";
            day = {
              enabled = true;
              format = "YYYY-MM-DD";
              folder = "00 - Daily";
              templatePath = "Templates/Daily Note";
              openAtStartup = false;
            };
            week = {
              enabled = true;
              format = "YYYY-[W]ww";
              folder = "01 - Weekly";
              templatePath = "Templates/Weekly Review";
              openAtStartup = false;
            };
          }
        ];
        activeCalendarSet = "default";
        showGettingStartedBanner = false;
      };
    }
    { pkg = calendar; }
    {
      pkg = obsidian-tasks-plugin;
      settings = {
        globalQuery = "";
        taskCompleteSettings = "";
      };
    }
    { pkg = quickadd; }
    {
      pkg = obsidian-git;
      settings = {
        commitMessage = "vault backup: {{date}}";
        autoSaveInterval = 0;
        autoBackupInterval = 0;
        gitDirectory = "";
      };
    }
    {
      pkg = obsidian-local-rest-api;
      settings = {
        apiKey = "obsidian-local-rest-api-key";
        port = 27124;
      };
    }
  ];

  obsidianPkg = if pkgs.stdenv.isLinux then config.lib.nixGL.wrap pkgs.obsidian else pkgs.obsidian;
in
{
  config = lib.mkIf config.dotfiles.apps.obsidian.enable {
    home.activation.createObsidianVaultDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p '${vaultDir}' \
        '${vaultDir}/00 - Daily' \
        '${vaultDir}/01 - Weekly' \
        '${vaultDir}/02 - Projects' \
        '${vaultDir}/03 - Resources' \
        '${vaultDir}/04 - Snippets' \
        '${vaultDir}/05 - Wiki' \
        '${vaultDir}/06 - Archive'
    '';

    home.file."${vaultDir}/Templates" = {
      source = ./templates;
      force = true;
    };

    programs.obsidian = {
      enable = true;
      package = obsidianPkg;

      vaults = {
        vault = {
          target = ".vault";
          settings = {
            app = {
              vimMode = false;
              showFrontmatter = true;
              defaultViewMode = "source";
              strictLineBreaks = false;
              spellcheck = true;
              livePreview = true;
              readableLineLength = true;
              newFileLocation = "folder";
              newFileFolderPath = "00 - Daily";
              attachmentFolderPath = "04 - Snippets/attachments";
              showLineNumber = true;
              foldHeading = true;
              foldIndent = true;
              useTab = false;
              tabSize = 2;
              theme = "obsidian";
            };

            appearance = {
              baseFontSize = 16;
              nativeMenus = false;
              accentColor = "#7c3aed";
            };

            corePlugins = [
              "file-explorer"
              "global-search"
              "switcher"
              "graph"
              "backlink"
              "outgoing-link"
              "tag-pane"
              "page-preview"
              "note-composer"
              "command-palette"
              "editor-status"
              "outline"
              "word-count"
              "file-recovery"
              {
                name = "templates";
                enable = false;
              }
              {
                name = "daily-notes";
                enable = false;
              }
            ];

            communityPlugins = communityPluginsList;

            hotkeys = {
              "templater-obsidian:insert-templater" = [
                {
                  modifiers = [ "Mod" ];
                  key = "T";
                }
              ];
            };
          };
        };
      };
    };
  };
}
