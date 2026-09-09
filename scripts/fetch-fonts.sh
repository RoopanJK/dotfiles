#!/usr/bin/env bash
#
# fetch-fonts.sh — install the Nerd Fonts these dotfiles ask for.
#
# The font binaries are deliberately not committed: a Nerd Font family is tens
# of megabytes and would dwarf the rest of the repo. This fetches them instead.
#
#   ./scripts/fetch-fonts.sh                 install anything missing
#   ./scripts/fetch-fonts.sh --force         reinstall even if present
#   ./scripts/fetch-fonts.sh --list          show what's wanted vs installed
#   ./scripts/fetch-fonts.sh --version v3.5.1  pin a nerd-fonts release
#
set -euo pipefail

# "<release asset>:<font family to verify>"
#
# CascadiaCode.zip is the patched Cascadia Code; its families are named
# CaskaydiaCove, which is what kitty.conf already asks for.
FONTS=(
  "CascadiaCode:CaskaydiaCove Nerd Font"
)

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts"
RELEASE="latest"
FORCE=0
LIST=0

usage() { awk 'NR>1 { if (!/^#/) exit; sub(/^# ?/, ""); print }' "${BASH_SOURCE[0]}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)   FORCE=1 ;;
    -l|--list)    LIST=1 ;;
    -v|--version) RELEASE="${2:?--version needs a tag, e.g. v3.5.1}"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) printf 'unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

act()  { printf '\033[32m  %-9s\033[0m %s\n' "$1" "$2"; }
skip() { printf '\033[90m  %-9s\033[0m %s\n' "$1" "$2"; }
warn() { printf '\033[33m  %-9s\033[0m %s\n' "$1" "$2"; }
die()  { printf '\033[31m  error    \033[0m %s\n' "$1" >&2; exit 1; }

# Note: no `grep -q` here. It exits on the first match, which SIGPIPEs fc-list
# upstream, and under `set -o pipefail` that makes the whole pipeline fail — so
# an installed font reads as missing. Letting grep drain its input avoids it.
have_family() { fc-list : family 2>/dev/null | tr ',' '\n' | grep -xF "$1" >/dev/null; }

for c in curl unzip fc-cache fc-list; do
  command -v "$c" >/dev/null || die "$c is required but not installed"
done

printf '\nnerd fonts -> %s\n\n' "$FONT_DIR"

if [ "$LIST" -eq 1 ]; then
  for entry in "${FONTS[@]}"; do
    family="${entry#*:}"
    if have_family "$family"; then act "installed" "$family"; else warn "missing" "$family"; fi
  done
  printf '\n'
  exit 0
fi

# Resolve "latest" once, so every asset in one run comes from one release.
if [ "$RELEASE" = "latest" ]; then
  RELEASE="$(curl -fsSL -m 30 https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest |
    sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  [ -n "$RELEASE" ] || die "could not resolve the latest nerd-fonts release (rate limited or offline?)"
fi
printf '  release   %s\n\n' "$RELEASE"

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

installed_any=0

for entry in "${FONTS[@]}"; do
  asset="${entry%%:*}"
  family="${entry#*:}"

  if [ "$FORCE" -eq 0 ] && have_family "$family"; then
    skip "ok" "$family"
    continue
  fi

  url="https://github.com/ryanoasis/nerd-fonts/releases/download/$RELEASE/$asset.zip"
  act "download" "$asset.zip"
  curl -fsSL -m 300 -o "$tmp/$asset.zip" "$url" || die "download failed: $url"

  # A failed download often arrives as an HTML error page, which would unzip
  # into nothing and leave the font silently missing. Check the archive first.
  unzip -tqq "$tmp/$asset.zip" >/dev/null 2>&1 || die "$asset.zip is not a valid zip (bad release tag?)"

  dest="$FONT_DIR/$asset"
  mkdir -p -- "$dest"
  # Keep only the font files; the archives also carry licence and readme text.
  unzip -qo "$tmp/$asset.zip" '*.ttf' '*.otf' -d "$dest" 2>/dev/null || true

  count=$(find "$dest" -type f \( -name '*.ttf' -o -name '*.otf' \) | wc -l)
  [ "$count" -gt 0 ] || die "no font files extracted from $asset.zip"
  act "extracted" "$count faces -> $dest"
  installed_any=1
done

if [ "$installed_any" -eq 1 ]; then
  # Rebuild every user cache, not just $FONT_DIR. On a first run the parent
  # ~/.local/share/fonts is itself new, and scoping the rebuild to the leaf
  # leaves fc-list unable to see what we just extracted.
  act "cache" "rebuilding font cache"
  fc-cache -f >/dev/null
fi

printf '\n'
status=0
for entry in "${FONTS[@]}"; do
  asset="${entry%%:*}"
  family="${entry#*:}"
  if have_family "$family"; then
    act "verified" "$family"
  else
    warn "FAILED" "$family is not visible to fontconfig"
    # Say what the files actually declare, so a renamed upstream family is
    # obvious instead of looking like a failed install.
    if [ -d "$FONT_DIR/$asset" ]; then
      printf '           families found in %s:\n' "$asset"
      find "$FONT_DIR/$asset" -type f \( -name '*.ttf' -o -name '*.otf' \) -print0 |
        xargs -0 -r fc-query -f '%{family}\n' 2>/dev/null |
        tr ',' '\n' | sort -u | sed 's/^/             /'
    fi
    status=1
  fi
done
printf '\n'

[ "$status" -eq 0 ] && printf '  restart kitty to pick up the new font\n\n'
exit "$status"
