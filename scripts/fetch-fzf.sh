#!/usr/bin/env bash
#
# fetch-fzf.sh — install fzf into ~/.local/bin.
#
# Not from apt: noble ships 0.44, and `fzf --zsh` (the one-line shell
# integration these configs use) only exists from 0.48 onward. fzf is a single
# static binary, so taking it from upstream costs nothing and needs no root.
#
#   ./scripts/fetch-fzf.sh                  install or upgrade
#   ./scripts/fetch-fzf.sh --list           show installed vs available
#   ./scripts/fetch-fzf.sh --force          reinstall
#   ./scripts/fetch-fzf.sh --version 0.74.3 pin a release
#
set -euo pipefail

# `fzf --zsh` is the reason for this script; don't accept older than that.
MIN_VERSION="0.48.0"
BIN_DIR="$HOME/.local/bin"
RELEASE="latest"
FORCE=0
LIST=0

usage() { awk 'NR>1 { if (!/^#/) exit; sub(/^# ?/, ""); print }' "${BASH_SOURCE[0]}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)   FORCE=1 ;;
    -l|--list)    LIST=1 ;;
    -v|--version) RELEASE="${2:?--version needs a version, e.g. 0.74.3}"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) printf 'unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

act()  { printf '\033[32m  %-9s\033[0m %s\n' "$1" "$2"; }
skip() { printf '\033[90m  %-9s\033[0m %s\n' "$1" "$2"; }
warn() { printf '\033[33m  %-9s\033[0m %s\n' "$1" "$2"; }
die()  { printf '\033[31m  error    \033[0m %s\n' "$1" >&2; exit 1; }

for c in curl tar; do
  command -v "$c" >/dev/null || die "$c is required but not installed"
done

# Sort two versions and check the smaller one is the minimum: a plain string
# compare would call 0.9 newer than 0.74.
version_at_least() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}

installed_version() {
  command -v fzf >/dev/null || return 1
  fzf --version 2>/dev/null | awk '{print $1}'
}

case "$(uname -m)" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  armv7l) arch=armv7 ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

printf '\nfzf -> %s\n\n' "$BIN_DIR"

have="$(installed_version || true)"

if [ "$LIST" -eq 1 ]; then
  if [ -n "$have" ]; then
    act "installed" "fzf $have  ($(command -v fzf))"
    version_at_least "$have" "$MIN_VERSION" ||
      warn "too old" "need >= $MIN_VERSION for \`fzf --zsh\`"
  else
    warn "missing" "fzf is not installed"
  fi
  printf '\n'
  exit 0
fi

if [ "$RELEASE" = "latest" ]; then
  RELEASE="$(curl -fsSL -m 30 https://api.github.com/repos/junegunn/fzf/releases/latest |
    sed -n 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/p' | head -1)"
  [ -n "$RELEASE" ] || die "could not resolve the latest fzf release (rate limited or offline?)"
fi
RELEASE="${RELEASE#v}"

if [ "$FORCE" -eq 0 ] && [ -n "$have" ] && [ "$have" = "$RELEASE" ]; then
  skip "ok" "fzf $have already installed"
  printf '\n'
  exit 0
fi

version_at_least "$RELEASE" "$MIN_VERSION" ||
  die "fzf $RELEASE is older than $MIN_VERSION, which does not support \`fzf --zsh\`"

tarball="fzf-$RELEASE-linux_$arch.tar.gz"
url="https://github.com/junegunn/fzf/releases/download/v$RELEASE/$tarball"

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

act "download" "$tarball"
curl -fsSL -m 300 -o "$tmp/$tarball" "$url" || die "download failed: $url"
# A 404 or proxy error page would untar into nothing; check before trusting it.
tar -tzf "$tmp/$tarball" >/dev/null 2>&1 || die "$tarball is not a valid archive (bad version?)"
tar -xzf "$tmp/$tarball" -C "$tmp" fzf || die "no fzf binary inside $tarball"

mkdir -p -- "$BIN_DIR"
# Install via a temp name + mv so a running fzf is never truncated mid-write.
install -m 0755 "$tmp/fzf" "$BIN_DIR/.fzf.new"
mv -- "$BIN_DIR/.fzf.new" "$BIN_DIR/fzf"
act "installed" "$BIN_DIR/fzf"

printf '\n'
got="$("$BIN_DIR/fzf" --version 2>/dev/null | awk '{print $1}')"
[ "$got" = "$RELEASE" ] || die "installed binary reports $got, expected $RELEASE"
act "verified" "fzf $got"
"$BIN_DIR/fzf" --zsh >/dev/null 2>&1 ||
  die "this fzf does not support \`fzf --zsh\`"
act "verified" "\`fzf --zsh\` works"

if ! command -v fzf >/dev/null || [ "$(command -v fzf)" != "$BIN_DIR/fzf" ]; then
  warn "note" "$BIN_DIR is not first on PATH in this shell; open a new shell"
fi
printf '\n'
