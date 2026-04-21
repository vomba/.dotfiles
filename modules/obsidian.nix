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
  templatesDir = "${vaultDir}/Templates";

  # Community plugins from the obsidian-plugins-nix overlay
  communityPluginsList = with obsidian-plugins.packages.${pkgs.system}; [
    { pkg = dataview; }
    {
      pkg = templater-obsidian;
      settings = {
        template_folder = "Templates";
        trigger_on_file_creation = false;
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
    { pkg = tag-wrangler; }
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
      pkg = obsidian-linter;
      settings = {
        lintOnSave = false;
      };
    }
    {
      pkg = obsidian-local-rest-api;
      settings = {
        apiKey = "obsidian-local-rest-api-key";
        port = 27124;
      };
    }
    {
      pkg = smart-connections;
      settings = {
        smart_folder = "06 - Archive";
      };
    }
    { pkg = obsidian-style-settings; }
    { pkg = obsidian-advanced-uri; }
    { pkg = obsidian-hover-editor; }
  ];

  obsidianPkg = if pkgs.stdenv.isLinux then config.lib.nixGL.wrap pkgs.obsidian else pkgs.obsidian;
in
{
  home.activation.createObsidianVaultDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p '${vaultDir}'
  '';

  # QuickAdd needs a writable data.json (not a symlink to the Nix store)
  # because it runs migrations on startup. Copy instead of symlink.
  home.activation.setupQuickAddData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p '${vaultDir}/.obsidian/plugins/quickadd'
    cp -f '${./obsidian/plugins/quickadd/data.json}' '${vaultDir}/.obsidian/plugins/quickadd/data.json'
  '';

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
            spellcheckLanguages = null;
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
            theme = "";
            enabledCssSnippets = [ ];
            baseFontSize = 16;
            monospaceFontFamily = "";
            textFontFamily = "";
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
            "templates"
            "note-composer"
            "command-palette"
            "editor-status"
            "markdown-importer"
            "outline"
            "word-count"
            "file-recovery"
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

          extraFiles = {
            "Templates" = {
              source = ./obsidian/templates;
            };
            "00 - Daily" = {
              source = ./obsidian/vault-dirs/00-daily;
            };
            "01 - Weekly" = {
              source = ./obsidian/vault-dirs/01-weekly;
            };
            "02 - Projects" = {
              source = ./obsidian/vault-dirs/02-projects;
            };
            "03 - Resources" = {
              source = ./obsidian/vault-dirs/03-resources;
            };
            "04 - Snippets" = {
              source = ./obsidian/vault-dirs/04-snippets;
            };
            "05 - Wiki" = {
              source = ./obsidian/vault-dirs/05-wiki;
            };
            "06 - Archive" = {
              source = ./obsidian/vault-dirs/06-archive;
            };
          };
        };
      };
    };
  };
}
