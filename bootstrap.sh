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
#
# A repo path may be a file or a directory. Directories are linked whole, so
# files added to them later need no change here — which is how the app configs
# that expect a whole directory (hypr/, waybar/, fuzzel/) are meant to be added.
#
# Don't list a directory and something inside that same directory; the second
# entry would resolve into the repo. The script refuses that, but it is easier
# not to write it.
LINKS=(
  "zsh/.zshrc:$HOME/.zshrc"
  "kitty/kitty.conf:$CONFIG_HOME/kitty/kitty.conf"
  "kitty/current-theme.conf:$CONFIG_HOME/kitty/current-theme.conf"
)

DRY_RUN=0
FORCE=0
UNLINK=0

usage() { awk 'NR>1 { if (!/^#/) exit; sub(/^# ?/, ""); print }' "${BASH_SOURCE[0]}"; }

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

# Pick a backup filename that doesn't clobber an earlier one this run. Two
# entries can share a basename (several apps use "config"), and silently
# overwriting one backup with another would defeat the point of having them.
backup_path() {
  local base="$1" candidate="$backup_dir/$1" n=2
  while [ -e "$candidate" ] || [ -L "$candidate" ]; do
    candidate="$backup_dir/$base.$n"
    n=$((n + 1))
  done
  printf '%s' "$candidate"
}

# Refuse to create a link whose destination lives inside the repo. Reachable by
# listing a directory and one of its own children, and it would write the app's
# config into the repo through a link pointing at itself.
#
# Resolve the parent but never the destination itself: once we have linked
# something, resolving the destination follows our own link back into the repo
# and every later run would refuse its own work. Resolving only the parent still
# catches the case that matters, where an ancestor directory is a link into the
# repo and a child entry would land inside it.
inside_repo() {
  local parent base
  parent="$(realpath -m -- "$(dirname -- "$1")")"
  base="$(basename -- "$1")"
  case "$parent/$base/" in
    "$REPO_DIR"/*) return 0 ;;
    *) return 1 ;;
  esac
}

do_link() {
  local src="$REPO_DIR/$1" dest="$2" label=link

  if [ ! -e "$src" ]; then
    warn "missing" "$1 is not in the repo — skipping"
    return 0
  fi
  if [ -d "$src" ]; then label="link dir"; fi

  if inside_repo "$dest"; then
    warn "refused" "$dest is inside the repo — check the LINKS entry for $1"
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
      local what="file"
      [ -d "$dest" ] && [ ! -L "$dest" ] && what="directory and everything in it"
      printf '  \033[33mexists\033[0m    %s (%s) — replace? [y/N] ' "$dest" "$what"
      read -r reply
      case "$reply" in
        [yY]*) ;;
        *) skip "kept" "$dest"; return 0 ;;
      esac
    fi
    ensure_backup_dir
    local bpath
    if [ "$DRY_RUN" -eq 1 ]; then
      bpath="$backup_dir/$(basename -- "$dest")"
    else
      bpath="$(backup_path "$(basename -- "$dest")")"
    fi
    act "backup" "$dest -> $bpath"
    run mv -- "$dest" "$bpath"
  fi

  # -n so a leftover symlink-to-directory is replaced rather than followed
  # (which would drop the new link *inside* the old target).
  act "$label" "$dest -> $src"
  run ln -sfn -- "$src" "$dest"
}

do_unlink() {
  local src="$REPO_DIR/$1" dest="$2"
  # Only ever remove a symlink we would have created. rm (not rm -r): if this
  # is our link, it is a link, so a plain rm is enough — and if the guard is
  # ever wrong, a plain rm cannot take a real directory with it.
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
