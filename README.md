# Jobash

Personal bash helpers: small commands installed into your shell via `./install.sh`.

## Layout

| Path | Role |
|------|------|
| `install.sh` | Interactive / flagged installer |
| `lib/` | Shared helpers (features, bashrc, install) |
| `features/` | One directory per feature |
| `bin/` | Reserved for repo-local entrypoints |
| `completions/` | Bash completions (future) |
| `tests/` | Bats suite + `./tests/run` |
| `vendor/bats-core` | bats-core submodule |
| `docs/` | Extra documentation |

## Feature contract

Each feature is `features/<id>/`:

| File | Purpose |
|------|---------|
| `meta.conf` | `id`, `name`, `description`, `bin`, `script` |
| `<script>.sh` | Implementation (`chmod +x`) |
| `example.sh` | Non-destructive demo |

Discovery: every `features/*/meta.conf` is a feature. First feature: `count`.

## Install

```bash
./install.sh                 # menu: all | choose | example | quit
./install.sh --all
./install.sh --features count
./install.sh --example count
./install.sh --uninstall
```

Interactive menus use `0` / `back` to go up a level. After an example demo, the feature list is shown again.

Flags for testing / custom paths:

- `--prefix DIR` — install home (default `~/.jobash`)
- `--bashrc FILE` — bashrc path (default `~/.bashrc`)

Install copies selected scripts to `$prefix/bin` and upserts a managed block in bashrc:

```bash
# >>> JOBASH
export JOBASH_HOME="…"
export PATH="$JOBASH_HOME/bin:$PATH"
# <<< JOBASH
```

Re-runs rewrite that block (no duplicates). `--example` never installs or edits bashrc.

Open a new shell (or `source ~/.bashrc`) after install.

## Tests

```bash
git submodule update --init vendor/bats-core
./tests/run
```

Uses temp prefix/bashrc only — never your real home config.

## License

Personal use; no license chosen yet.
