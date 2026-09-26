# Dotfiles

Personal Arch Linux configuration for a Hyprland desktop and a terminal-based
development environment. The installer provisions the required applications,
builds selected tools from their latest upstream source, and links every
configuration into the appropriate location.

## Requirements

- Arch Linux on an x86-64 machine
- A regular user with `sudo` access
- Working network access and Git installed
- A GitHub SSH key that can access this repository and its Waybar submodule

Confirm GitHub authentication before cloning:

```sh
ssh -T git@github.com
```

## Install on a Fresh Machine

Clone the repository with its submodules, then run the installer as your normal
user. Do not run the script itself with `sudo`; it requests elevated privileges
only when Pacman needs them.

```sh
mkdir -p ~/git
git clone --recurse-submodules git@github.com:Hamool/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./install.sh
```

The installer will:

1. Upgrade the Arch system and install Hyprland, Hyprpaper, Hyprlock,
   Hypridle, Kanshi, Waybar, Wofi, PipeWire utilities, and the configured
   desktop applications.
2. Build the latest Neovim, fzf, and Tmux sources and install them under
   `~/.local`.
3. Build and install `wlogout` from the AUR.
4. Link all repository configs into `$XDG_CONFIG_HOME` (or `~/.config`), link
   `zsh/zshenv` as `~/.zshenv`, and link repository commands into
   `~/.local/bin`.
5. Install the Tmux plugins declared in `tmux/tmux.conf` through TPM.
6. Verify that the commands used by the desktop configuration are available.

Existing configuration paths are preserved as timestamped files or directories
such as `~/.config/nvim.backup.20260927-120000`. Re-running the installer is
safe: existing correct links are retained, while source checkouts are updated
and rebuilt.

After installation, log out and back in so the `environment.d` configuration
is applied. Start Hyprland from a display manager or from a TTY:

```sh
Hyprland
```

Open Neovim once and allow `lazy.nvim` and Mason to install their managed
plugins and tools. Tmux plugins should already be installed; inside Tmux,
`prefix` + <kbd>I</kbd> installs any newly added plugin. This configuration uses
<kbd>Ctrl</kbd>+<kbd>S</kbd> as the Tmux prefix.

## Machine-Specific Setup

Review these files before relying on the desktop configuration:

- `kanshi/config` contains exact laptop and external-monitor identifiers. Run
  `hyprctl monitors all` and replace the existing output descriptions with
  those reported by the new machine.
- `hypr/input.lua` contains a Synaptics device override. Find input device names
  with `hyprctl devices` and update or remove that block.
- `hypr/hypridle.conf` controls the `tpacpi::kbd_backlight` device. Remove its
  keyboard-backlight listener on hardware that does not expose that device.
- `hypr/hyprpaper.conf` uses `hypr/wall.jpg`. Replace that image or change the
  configured path.
- <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> launches `zen-browser`. Zen
  Browser is intentionally not installed by `install.sh`; install it separately
  or change the binding in `hypr/keybinds.lua`.

Kanshi owns the named monitor layouts. `hypr/monitors.lua` supplies an automatic
fallback for displays that do not match a Kanshi profile.

## Selective Installation

Set any skip switch to `1` when only part of the setup is needed:

```sh
DOTFILES_SKIP_PACKAGES=1 ./install.sh
DOTFILES_SKIP_BUILDS=1 ./install.sh
DOTFILES_SKIP_SUBMODULES=1 ./install.sh
DOTFILES_SKIP_TMUX_PLUGINS=1 ./install.sh
DOTFILES_SKIP_VERIFY=1 ./install.sh
DOTFILES_BUILD_JOBS=4 ./install.sh
```

For example, the first command keeps the current system packages while updating
source builds, links, and Tmux plugins. `DOTFILES_BUILD_JOBS` controls Tmux build
parallelism.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `hypr/` | Modular Hyprland Lua config plus Hypridle, Hyprlock, Hyprpaper, wallpaper, and Wofi theme |
| `kanshi/` | Monitor profiles |
| `nvim/` | Neovim configuration and locked plugin versions |
| `tmux/` | Tmux configuration; plugins are managed in `~/.tmux/plugins` |
| `waybar/` | Waybar configuration submodule |
| `kitty/`, `mc/`, `mpv/` | Application configuration |
| `environment.d/`, `zsh/` | `~/.local/bin` PATH setup |
| `bin/` | Small commands used by Hyprland bindings |

## Update and Validate

Pull repository updates, including submodules, and rerun the installer:

```sh
cd ~/git/dotfiles
git pull --recurse-submodules
git submodule update --init --recursive
./install.sh
```

Validate configuration changes before committing:

```sh
git diff --check
git ls-files -z '*.lua' | xargs -0 -n1 luac -p
Hyprland --verify-config -c "$PWD/hypr/hyprland.lua"
```

In a running Hyprland session, apply changes with `hyprctl reload` and inspect
errors with `hyprctl configerrors`.
