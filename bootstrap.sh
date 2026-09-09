#!/usr/bin/env bash
#
# bootstrap.sh — link this dotfiles repo into place on any machine.
#
# The repo is the source of truth. This script points the real config
# locations at the files in here, backing up anything it would replace.
#
#   ./bootstrap.sh              install (backs up existing files)
#   ./bootstrap.sh --dry-run    show what would happen, change nothing
#   ./bootstrap.sh --force      replace existing files without prompting
#   ./bootstrap.sh --unlink     remove links this script created
#
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles-backup"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Each entry is "<path relative to repo>:<destination>".
# Destinations may use $HOME and $CONFIG_HOME.
LINKS=(
  "zsh/.zshrc:$HOME/.zshrc"
  "kitty/kitty.conf:$CONFIG_HOME/kitty/kitty.conf"
  "kitty/current-theme.conf:$CONFIG_HOME/kitty/current-theme.conf"
)

DRY_RUN=0
FORCE=0
UNLINK=0

usage() { sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^#\s\?//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -u|--unlink)  UNLINK=1 ;;
    -h|--help)    usage; exit 0 ;;
    *) printf 'unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

info()  { printf '  %s\n' "$*"; }
act()   { printf '\033[32m  %-9s\033[0m %s\n' "$1" "$2"; }
skip()  { printf '\033[90m  %-9s\033[0m %s\n' "$1" "$2"; }
warn()  { printf '\033[33m  %-9s\033[0m %s\n' "$1" "$2"; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then return 0; fi
  "$@"
}

backup_dir=""
ensure_backup_dir() {
  [ -n "$backup_dir" ] && return 0
  backup_dir="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
  run mkdir -p "$backup_dir"
}

# Resolve a symlink one level, without requiring GNU readlink -f semantics.
link_target() { readlink -- "$1" 2>/dev/null || true; }

do_link() {
  local src="$REPO_DIR/$1" dest="$2"

  if [ ! -e "$src" ]; then
    warn "missing" "$1 is not in the repo — skipping"
    return 0
  fi

  # Already pointing at the right place?
  if [ -L "$dest" ] && [ "$(link_target "$dest")" = "$src" ]; then
    skip "ok" "$dest"
    return 0
  fi

  run mkdir -p -- "$(dirname -- "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$FORCE" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ -t 0 ]; then
      printf '  \033[33mexists\033[0m    %s — replace? [y/N] ' "$dest"
      read -r reply
      case "$reply" in
        [yY]*) ;;
        *) skip "kept" "$dest"; return 0 ;;
      esac
    fi
    ensure_backup_dir
    act "backup" "$dest -> $backup_dir/$(basename -- "$dest")"
    run mv -- "$dest" "$backup_dir/$(basename -- "$dest")"
  fi

  act "link" "$dest -> $src"
  run ln -s -- "$src" "$dest"
}

do_unlink() {
  local src="$REPO_DIR/$1" dest="$2"
  if [ -L "$dest" ] && [ "$(link_target "$dest")" = "$src" ]; then
    act "unlink" "$dest"
    run rm -- "$dest"
  else
    skip "not ours" "$dest"
  fi
}

printf '\ndotfiles: %s\n' "$REPO_DIR"
[ "$DRY_RUN" -eq 1 ] && printf '\033[33mdry run — nothing will change\033[0m\n'
printf '\n'

for entry in "${LINKS[@]}"; do
  src="${entry%%:*}"
  dest="${entry#*:}"
  if [ "$UNLINK" -eq 1 ]; then
    do_unlink "$src" "$dest"
  else
    do_link "$src" "$dest"
  fi
done

printf '\n'
if [ -n "$backup_dir" ]; then
  info "backups: $backup_dir"
fi
if [ "$UNLINK" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  info "done — open a new shell, or run: exec zsh"
fi
printf '\n'
