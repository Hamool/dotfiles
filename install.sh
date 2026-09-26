#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
local_prefix="$HOME/.local"
local_bin="$local_prefix/bin"
source_root="$local_prefix/src"
backup_suffix="$(date +%Y%m%d-%H%M%S)"
build_jobs="${DOTFILES_BUILD_JOBS:-$(nproc)}"

export PATH="$local_bin:$PATH"

log() {
  printf '[dotfiles] %s\n' "$*"
}

fail() {
  printf '[dotfiles] error: %s\n' "$*" >&2
  exit 1
}

link_path() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p -- "$(dirname -- "$target_path")"

  if [[ -L "$target_path" ]] && \
    [[ "$(readlink -f -- "$target_path")" == "$(readlink -f -- "$source_path")" ]]; then
    log "already linked: $target_path"
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    local backup_path="${target_path}.backup.${backup_suffix}"
    mv -- "$target_path" "$backup_path"
    log "backed up $target_path to $backup_path"
  fi

  ln -s -- "$source_path" "$target_path"
  log "linked $target_path -> $source_path"
}

sync_repo() {
  local name="$1"
  local url="$2"
  local branch="${3:-master}"
  local checkout="$source_root/$name"

  if [[ -e "$checkout" && ! -d "$checkout/.git" ]]; then
    fail "$checkout exists but is not a Git checkout"
  fi

  if [[ ! -d "$checkout/.git" ]]; then
    log "cloning $name"
    git clone --branch "$branch" "$url" "$checkout"
  else
    local current_url
    current_url="$(git -C "$checkout" remote get-url origin)"
    [[ "$current_url" == "$url" ]] || \
      fail "$checkout has unexpected origin: $current_url"
    log "updating $name"
    git -C "$checkout" fetch --prune --tags origin "$branch"
    git -C "$checkout" checkout "$branch"
    git -C "$checkout" merge --ff-only "origin/$branch"
  fi
}

install_arch_packages() {
  command -v pacman >/dev/null || \
    fail "automatic package installation currently supports Arch Linux only"
  command -v sudo >/dev/null || fail "sudo is required to install system packages"

  local packages=(
    autoconf automake base-devel bison blueman brightnessctl cmake curl fd
    gettext git go grim hypridle hyprland hyprlock hyprpaper hyprshot kanshi kitty
    libevent libnotify mc mpv nautilus ncurses networkmanager ninja pamixer
    pavucontrol pipewire playerctl pkgconf polkit-gnome ripgrep slurp swaync
    ttf-sharetech-mono-nerd unzip waybar wireplumber wl-clipboard wofi
    xdg-desktop-portal-hyprland zsh
  )
  local missing=()

  mapfile -t missing < <(pacman -T "${packages[@]}" 2>/dev/null || true)
  if ((${#missing[@]})); then
    log "installing Arch packages: ${missing[*]}"
    sudo pacman -Syu --needed --noconfirm "${missing[@]}"
  else
    log "all Arch packages are installed"
  fi
}

install_aur_package() {
  local package="$1"
  local checkout="$source_root/aur/$package"

  mkdir -p -- "$source_root/aur"
  sync_repo "aur/$package" "https://aur.archlinux.org/${package}.git" master
  log "building AUR package: $package"
  (
    cd -- "$checkout"
    makepkg -si --needed --noconfirm
  )
}

install_desktop_packages() {
  install_arch_packages

  command -v wlogout >/dev/null || install_aur_package wlogout
}

build_neovim() {
  local checkout="$source_root/neovim"
  sync_repo neovim https://github.com/neovim/neovim.git master
  log "building Neovim nightly"
  make -C "$checkout" distclean
  make -C "$checkout" \
    CMAKE_BUILD_TYPE=Release \
    CMAKE_INSTALL_PREFIX="$local_prefix" \
    install
  log "installed $("$local_bin/nvim" --version | sed -n '1p')"
}

build_fzf() {
  local checkout="$source_root/fzf"
  sync_repo fzf https://github.com/junegunn/fzf.git master
  log "building fzf from master"
  make -C "$checkout" clean install
  install -Dm755 "$checkout/bin/fzf" "$local_bin/fzf"
  install -Dm755 "$checkout/bin/fzf-tmux" "$local_bin/fzf-tmux"
  install -Dm644 "$checkout/man/man1/fzf.1" "$local_prefix/share/man/man1/fzf.1"
  install -Dm644 "$checkout/man/man1/fzf-tmux.1" "$local_prefix/share/man/man1/fzf-tmux.1"
  log "installed fzf $("$local_bin/fzf" --version)"
}

build_tmux() {
  local checkout="$source_root/tmux"
  sync_repo tmux https://github.com/tmux/tmux.git master
  log "building Tmux from master"
  (
    cd -- "$checkout"
    sh autogen.sh
    ./configure --prefix="$local_prefix"
    make -j "$build_jobs"
    make install
  )
  log "installed $("$local_bin/tmux" -V)"
}

build_nightly_tools() {
  mkdir -p -- "$source_root" "$local_bin"
  build_neovim
  build_fzf
  build_tmux
}

install_configs() {
  if [[ "${DOTFILES_SKIP_SUBMODULES:-0}" != "1" ]]; then
    log "initializing configuration submodules"
    git -C "$repo_dir" submodule update --init --recursive -- hypr/wofi waybar
  fi

  mkdir -p -- "$config_home" "$local_bin"

  local name
  for name in environment.d hypr kanshi kitty mc mpv nvim tmux waybar; do
    link_path "$repo_dir/$name" "$config_home/$name"
  done

  link_path "$repo_dir/zsh/zshenv" "$HOME/.zshenv"

  local executable
  for executable in "$repo_dir"/bin/*; do
    link_path "$executable" "$local_bin/$(basename -- "$executable")"
  done
}

install_tmux_plugins() {
  [[ "${DOTFILES_SKIP_TMUX_PLUGINS:-0}" == "1" ]] && return

  local plugin_root="$HOME/.tmux/plugins"
  local tpm_dir="$plugin_root/tpm"
  if [[ ! -d "$tpm_dir/.git" ]]; then
    mkdir -p -- "$plugin_root"
    log "installing Tmux Plugin Manager"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    git -C "$tpm_dir" pull --ff-only
  fi

  log "installing Tmux plugins"
  TMUX_PLUGIN_MANAGER_PATH="$plugin_root/" "$tpm_dir/bin/install_plugins"
}

verify_runtime() {
  local commands=(
    Hyprland blueman-applet brightnessctl fzf hypridle hyprlock hyprpaper
    hyprshot kanshi kitty mc mpv nautilus nvim pamixer playerctl swaync tmux
    waybar wlogout wofi wpctl
  )
  local missing=()
  local command_name

  for command_name in "${commands[@]}"; do
    command -v "$command_name" >/dev/null || missing+=("$command_name")
  done

  ((${#missing[@]} == 0)) || fail "missing runtime commands: ${missing[*]}"
  case ":$PATH:" in
    *":$local_bin:"*) ;;
    *) fail "$local_bin must be present in PATH" ;;
  esac
}

command -v git >/dev/null || fail "git is required to install these dotfiles"

if [[ "${DOTFILES_SKIP_PACKAGES:-0}" != "1" ]]; then
  install_desktop_packages
fi

if [[ "${DOTFILES_SKIP_BUILDS:-0}" != "1" ]]; then
  build_nightly_tools
fi

install_configs
install_tmux_plugins
if [[ "${DOTFILES_SKIP_VERIFY:-0}" != "1" ]]; then
  verify_runtime
fi
log "installation complete"
