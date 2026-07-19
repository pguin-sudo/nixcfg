{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.desktop.zed;
in
{
  options.features.desktop.zed.enable = mkEnableOption "Zed editor";

  config = mkIf cfg.enable {
    home.file.".config/zed/settings.json".text = ''
      {
        "agent_servers": {
          "claude-acp": {
            "type": "registry"
          }
        },
        "cli_default_open_behavior": "existing_window",
        "project_panel": { "dock": "left" },
        "outline_panel": { "dock": "left" },
        "collaboration_panel": { "dock": "left" },
        "agent": {
          "default_model": {
            "provider": "anthropic",
            "model": "claude-sonnet-4-6",
            "enable_thinking": true,
            "effort": "high"
          },
          "button": true,
          "dock": "right",
          "favorite_models": [
            {
              "provider": "anthropic",
              "model": "claude-fable-5",
              "enable_thinking": true,
              "effort": "high"
            }
          ],
          "model_parameters": []
        },
        "git_panel": { "dock": "left" },
        "session": { "trust_all_worktrees": true },
        "vim_mode": true,
        "icon_theme": "Zed (Default)",
        "ui_font_size": 16,
        "buffer_font_size": 15,
        "lsp": {
          "rust-analyzer": {
            "initialization_options": {
              "inlayHints": {
                "maxLength": null,
                "lifetimeElisionHints": {
                  "enable": "skip_trivial",
                  "useParameterNames": true
                },
                "closureReturnTypeHints": { "enable": "always" }
              }
            }
          },
          "pyright": {
            "settings": {
              "python.analysis.typeCheckingMode": "strict",
              "python.analysis.autoSearchPaths": true,
              "python.analysis.useLibraryCodeForTypes": true,
              "python.analysis.diagnosticMode": "workspace",
              "python.analysis.exclude": ["**/__pycache__", "**/migrations", "**/.venv"],
              "python.analysis.include": ["src", "tests"]
            }
          }
        },
        "languages": {
          "Python": {},
          "JavaScript": {
            "language_servers": ["biome", "..."],
            "formatter": { "language_server": { "name": "biome" } },
            "format_on_save": "on",
            "code_actions_on_format": {
              "source.fixAll.biome": true,
              "source.organizeImports.biome": true
            }
          },
          "TypeScript": {
            "language_servers": ["biome", "..."],
            "formatter": { "language_server": { "name": "biome" } },
            "format_on_save": "on",
            "code_actions_on_format": {
              "source.fixAll.biome": true,
              "source.organizeImports.biome": true
            }
          },
          "TSX": {
            "language_servers": ["biome", "..."],
            "formatter": { "language_server": { "name": "biome" } },
            "format_on_save": "on",
            "code_actions_on_format": {
              "source.fixAll.biome": true,
              "source.organizeImports.biome": true
            }
          },
          "JSX": {
            "language_servers": ["biome", "..."],
            "formatter": { "language_server": { "name": "biome" } },
            "format_on_save": "on",
            "code_actions_on_format": {
              "source.fixAll.biome": true,
              "source.organizeImports.biome": true
            }
          },
          "JSON": {
            "language_servers": ["biome", "..."],
            "formatter": { "language_server": { "name": "biome" } },
            "format_on_save": "on"
          }
        }
      }
    '';
  };
}
