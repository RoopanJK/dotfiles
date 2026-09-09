# dotfiles

Config for zsh and [kitty](https://sw.kovidgoyal.net/kitty/), kept in one place.

The repo is the source of truth: `bootstrap.sh` symlinks the real config
locations at the files in here, so editing a file in this repo edits the live
config.

## Install

```sh
git clone https://github.com/RoopanJK/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./bootstrap.sh --dry-run   # look first
./bootstrap.sh
exec zsh
```

The repo can live anywhere — `bootstrap.sh` resolves its own location, so no
paths need editing.

Anything it would overwrite is moved to
`~/.local/share/dotfiles-backup/<timestamp>/` first. Nothing is deleted.

| flag | effect |
| --- | --- |
| `--dry-run` / `-n` | print what would change, touch nothing |
| `--force` / `-f` | replace existing files without prompting |
| `--unlink` / `-u` | remove the symlinks this script created |
| `--help` / `-h` | usage |

## What gets linked

| repo file | destination |
| --- | --- |
| `zsh/.zshrc` | `~/.zshrc` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `kitty/current-theme.conf` | `~/.config/kitty/current-theme.conf` |

To add another file, append one `"<repo path>:<destination>"` entry to the
`LINKS` array at the top of `bootstrap.sh`.

## Prerequisites

Not installed by `bootstrap.sh` — install these for the config to work fully.

**Required by `.zshrc` as written:**

| tool | why | Ubuntu |
| --- | --- | --- |
| [zsh](https://www.zsh.org/) | the shell itself | `sudo apt install zsh` |
| [oh-my-zsh](https://ohmyz.sh/) | `git` / `sudo` / `web-search` plugins | see upstream installer |
| [znap](https://github.com/marlonrichert/zsh-snap) | plugin + prompt loader | cloned automatically on first shell start |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | smarter `cd` | `sudo apt install zoxide` |

**Required by `kitty.conf` as written:**

| tool | why |
| --- | --- |
| [kitty](https://sw.kovidgoyal.net/kitty/binary/) | the terminal |
| CaskaydiaCove Nerd Font Mono | `font_family`, plus the powerline tab bar and bell/activity glyphs |

Without the Nerd Font, the tab bar separators and status glyphs render as
missing-glyph boxes.

## Machine-local overrides

`.gitignore` excludes `*.local` and `zsh/*.local.zsh`, so machine-specific
settings (work paths, tokens, per-host env) can live beside the tracked config
without being committed.

Shell history is deliberately **not** tracked — see `.gitignore`.
