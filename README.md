# dotfiles

Config for zsh and [kitty](https://sw.kovidgoyal.net/kitty/), kept in one place.

The repo is the source of truth: `bootstrap.sh` symlinks the real config
locations at the files in here, so editing a file in this repo edits the live
config.

## Install

```sh
git clone https://github.com/RoopanJK/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./bootstrap.sh --dry-run     # look first
./bootstrap.sh
./scripts/fetch-fonts.sh     # Nerd Fonts these configs reference
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

A repo path may be **a file or a directory**. Directories are linked whole, so
files added inside them later need no new entry — which is how configs that
expect a whole directory (`hypr/`, `waybar/`, `fuzzel/`) should be added:

```
"waybar:$CONFIG_HOME/waybar"
```

Two things the script refuses, rather than doing something surprising:

- **A destination inside the repo.** Reachable by listing a directory *and* a
  file within that same directory — the second entry would resolve back into
  the repo through the first link.
- **Removing anything it didn't create.** `--unlink` only removes a symlink
  pointing at the matching repo path; real files and foreign links are left
  alone.

Note that linking a directory means anything the application writes into its
config directory lands in the repo. That is usually what you want (a theme
change becomes a tracked diff), but it is worth knowing before adding an app
that scribbles state next to its config.

## Fonts

`scripts/fetch-fonts.sh` installs the Nerd Fonts these configs name, into
`~/.local/share/fonts/NerdFonts`. The font binaries are **not committed** — a
Nerd Font family is tens of megabytes.

| flag | effect |
| --- | --- |
| *(none)* | install anything missing, then verify |
| `--list` | show wanted vs installed, change nothing |
| `--force` | reinstall even if already present |
| `--version vX.Y.Z` | pin a nerd-fonts release instead of taking the latest |

To add a font, append a `"<release asset>:<family to verify>"` entry to the
`FONTS` array. The family is checked through `fontconfig` after install, so a
silently-renamed upstream family surfaces as a failure with the real family
names printed, rather than as a font that quietly never loads.

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

| tool | why | install |
| --- | --- | --- |
| [kitty](https://sw.kovidgoyal.net/kitty/binary/) | the terminal | upstream installer |
| CaskaydiaCove Nerd Font Mono | `font_family`, plus the powerline tab bar and bell/activity glyphs | `./scripts/fetch-fonts.sh` |

Without the Nerd Font, the tab bar separators and status glyphs render as
missing-glyph boxes.

## Machine-local overrides

`.gitignore` excludes `*.local` and `zsh/*.local.zsh`, so machine-specific
settings (work paths, tokens, per-host env) can live beside the tracked config
without being committed.

Shell history is deliberately **not** tracked — see `.gitignore`.
