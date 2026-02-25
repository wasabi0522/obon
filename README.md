<div align="center">

# obon (お盆)

**Gather and restore tmux panes across sessions**

[![CI](https://github.com/wasabi0522/obon/actions/workflows/ci.yml/badge.svg)](https://github.com/wasabi0522/obon/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![tmux 3.0+](https://img.shields.io/badge/tmux-3.0%2B-green)
![Bash 3.2+](https://img.shields.io/badge/Bash-3.2%2B-green)
![hashi](https://img.shields.io/badge/hashi-required-green)

</div>

## Features

Collect panes running a specific command into one window, then put them back.

- **Join** — gather target panes into a single `obon` window with `even-horizontal` layout
- **Break** — restore panes to their original locations
- **Cross-session** — works across all [hashi](https://github.com/wasabi0522/hashi)-managed `hs/` sessions with `--all`
- **Width check** — warns before joining into a narrow window

## Installation

> [!NOTE]
> Requires **tmux 3.0+**, **Bash 3.2+**, and **[hashi](https://github.com/wasabi0522/hashi)**.

### Homebrew

```bash
brew install wasabi0522/tap/obon
```

<details>
<summary>Manual installation</summary>

```bash
mkdir -p ~/.local/bin
curl -sSL https://raw.githubusercontent.com/wasabi0522/obon/main/obon -o ~/.local/bin/obon
chmod +x ~/.local/bin/obon
```

Make sure `~/.local/bin` is in your `$PATH`.

</details>

## Usage

```bash
export OBON_TARGET_CMD="claude"    # target command name

obon join              # gather target panes into an obon window
obon join --all        # gather from all hs/ sessions into an obon session
obon break             # restore panes to their original locations
obon break --all       # restore panes across all sessions
```

### Options

| Flag | Subcommand | Description |
|------|------------|-------------|
| `--all` | join, break | Target all `hs/` sessions |
| `-y`, `--yes` | join | Skip width confirmation prompt |

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OBON_TARGET_CMD` | Yes | — | Command name to match (`#{pane_current_command}`) |
| `OBON_MIN_PANE_WIDTH` | No | `80` | Minimum pane width threshold (columns) |

## Shell Completions

Homebrew installs completions automatically. For manual installation:

<details>
<summary>Zsh</summary>

```bash
mkdir -p ~/.zsh/completions
curl -sSL https://raw.githubusercontent.com/wasabi0522/obon/main/completions/obon.zsh -o ~/.zsh/completions/_obon
```

Add the following to your `.zshrc`:

```zsh
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
```

</details>

<details>
<summary>Bash</summary>

```bash
mkdir -p ~/.local/share/bash-completion/completions
curl -sSL https://raw.githubusercontent.com/wasabi0522/obon/main/completions/obon.bash -o ~/.local/share/bash-completion/completions/obon
```

</details>

## License

[MIT](LICENSE)
