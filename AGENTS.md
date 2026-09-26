# Repository Guidelines

## Project Structure & Module Organization

This repository stores desktop and terminal configuration by application. Hyprland, Hypridle, Hyprlock, and Hyprpaper settings live in `hypr/`; Neovim starts at `nvim/init.lua`, with reusable settings under `nvim/lua/config/` and plugin specifications under `nvim/lua/plugins/`. Tmux, Kitty, Kanshi, Midnight Commander, and mpv files are grouped in their matching top-level directories. Images and theme files belong beside the configuration that consumes them, such as `hypr/wall.jpg` and `kitty/themes/`.

`hypr/wofi`, `waybar`, and entries under `tmux/plugins/` are recorded as external gitlinks. Make changes in their source repositories, then update the pinned commit here; do not copy edits into generated or vendored content.

## Development and Validation Commands

There is no build step or repository-wide test runner. Validate the files you touched before committing:

```sh
git diff --check
git ls-files -z '*.lua' | xargs -0 -n1 luac -p
tmux source-file "$PWD/tmux/tmux.conf"
hyprctl reload && hyprctl configerrors
```

The first command catches whitespace errors, and the second parses tracked Lua files. The reload commands exercise Tmux and Hyprland configurations in a running session. After Neovim changes, launch `nvim -u "$PWD/nvim/init.lua"` and confirm startup succeeds; plugin resolution is pinned in `nvim/lazy-lock.json`.

## Coding Style & Naming Conventions

Follow the surrounding file's syntax and indentation. Neovim Lua uses two spaces, `snake_case` local names, and one plugin specification per descriptively named file (for example, `lsp-config.lua`). Keep application-native naming for `.conf`, JSONC, CSS, YAML, and INI files. Avoid drive-by reformatting, backup files, secrets, and machine-generated state. Update comments when a key binding, device, or startup command changes.

## Testing Guidelines

Test configuration changes in the target application and inspect its logs or error output. Exercise affected key bindings, monitor rules, status modules, or theme rendering. No coverage threshold applies; include concise manual verification notes in the pull request.

## Commit & Pull Request Guidelines

History uses short, lowercase, imperative subjects such as `fix submodules wofi, waybar`. Keep each commit focused and name the affected application when useful, for example `nvim: update telescope mappings`. Pull requests should explain the user-visible change, list validation performed, and identify host-specific assumptions. Attach screenshots for Waybar, Wofi, lock-screen, or theme changes, and link any relevant issue.

## Security & Portability

Review paths, monitor names, input devices, network locations, and autostart programs before sharing changes. Never commit credentials or private tokens. Prefer documented placeholders when a value cannot be portable across machines.
