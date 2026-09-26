# Dotfiles

Personal configuration for a Hyprland desktop and terminal environment. The
repository is organized by application and is intended to be linked directly
into the XDG configuration directory.

## Contents

- `hypr/` contains the modular Hyprland Lua configuration plus Hypridle,
  Hyprlock, Hyprpaper, and the Wofi theme submodule.
- `kanshi/` owns machine-specific monitor profiles.
- `nvim/`, `kitty/`, `tmux/`, and `mc/` contain application configuration.
- `waybar/` is a separate configuration repository included as a submodule.
- `environment.d/` and `zsh/` keep `~/.local/bin` first in `PATH`.
- `bin/` contains small commands used by the desktop configuration.

## Installation

Clone the repository, then run the installer from any working directory:

```sh
git clone git@github.com:Hamool/dotfiles.git ~/git/dotfiles
~/git/dotfiles/install.sh
```

The installer targets Arch Linux. It performs a system upgrade and installs the
Hyprland desktop, its portal and utilities, the applications referenced by the
configuration, build dependencies, and the configured Nerd Font. Wlogout is
installed through its AUR package recipe. Zen Browser is used by a Hyprland
binding but must be installed separately.

Neovim, fzf, and Tmux are cloned from their upstream `master` branches into
`~/.local/src`, built from source, and installed under `~/.local`. This follows
the upstream [Neovim](https://github.com/neovim/neovim/blob/master/BUILD.md),
[fzf](https://github.com/junegunn/fzf/blob/master/BUILD.md), and
[Tmux](https://github.com/tmux/tmux/wiki/Installing#from-version-control) build
instructions. Re-running the installer fast-forwards each checkout and rebuilds
the latest development version.

Every application directory is linked into `$XDG_CONFIG_HOME` (or
`~/.config`), `.zshenv` is linked into the home directory, commands are linked
into `~/.local/bin`, and Tmux plugins are installed through TPM. Existing
destinations are moved to timestamped
`.backup.YYYYMMDD-HHMMSS` paths. Running the installer again is safe.

The following environment switches support focused or offline runs:

```sh
DOTFILES_SKIP_PACKAGES=1
DOTFILES_SKIP_BUILDS=1
DOTFILES_SKIP_SUBMODULES=1
DOTFILES_SKIP_TMUX_PLUGINS=1
DOTFILES_SKIP_VERIFY=1
DOTFILES_BUILD_JOBS=4
```

The first five accept `1` to skip their named phase. `DOTFILES_BUILD_JOBS`
controls Tmux compilation parallelism. The default installation verifies that
every command referenced by the desktop is available and fails with a concrete
list if anything is missing.

## Hyprland Configuration

`hypr/hyprland.lua` is the entry point. Appearance and compositor options live
in `settings.lua`; monitor fallback behavior in `monitors.lua`; startup services
in `autostart.lua`; and input, key bindings, and window rules in their matching
modules. Kanshi applies the actual internal/external monitor layouts.

Validate changes without starting a compositor:

```sh
Hyprland --verify-config -c "$PWD/hypr/hyprland.lua"
git ls-files -z '*.lua' | xargs -0 -n1 luac -p
git diff --check
```
