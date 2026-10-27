# Jobash

Personal bash helpers: small commands installed into your shell via `./install.sh`.

## Layout

| Path | Role |
|------|------|
| `install.sh` | Interactive / flagged installer |
| `uninstall.sh` | Interactive / flagged uninstaller |
| `bin/jobash` | Hub CLI (installed to `~/.jobash/bin/jobash`) |
| `lib/` | Shared helpers (features, bashrc, install, core) |
| `features/` | One directory per feature |
| `bin/` | Core CLI source (`jobash`) |
| `completions/` | Bash completion scripts (`<id>.bash`) |
| `tests/` | Bats suite + `./tests/run` |
| `vendor/bats-core` | bats-core submodule |

## Feature contract

Each feature is `features/<id>/`:

| File | Purpose |
|------|---------|
| `meta.conf` | `id`, `name`, `description`, `bin`, `script` |
| `<script>.sh` | Implementation (`chmod +x`) |
| `example.sh` | Non-destructive demo |

Matching completion (optional but expected): `completions/<id>.bash`. Install copies it to `~/.jobash/completions/` and the bashrc block sources those files in interactive shells.

Discovery: every `features/*/meta.conf` is a feature. First feature: `count`.

## Install

```bash
./install.sh                 # menu: all | choose | example | quit
./install.sh --all
./install.sh --features count
./install.sh --example count
./install.sh --uninstall     # full cleanup (same as uninstall --all)

./uninstall.sh               # menu: all | choose | quit
./uninstall.sh --all         # wipe bins, shell snippets, bashrc block, prefix
./uninstall.sh --features count,bak
```

Interactive menus use `0` / `back` to go up a level. After an example demo, the feature list is shown again. `uninstall.sh` choose lists only features currently present under the prefix.

Flags for testing / custom paths:

- `--prefix DIR` — install home (default `~/.jobash`)
- `--bashrc FILE` — bashrc path (default `~/.bashrc`)

Install copies selected scripts to `$prefix/bin` and upserts a managed block in bashrc:

```bash
# >>> JOBASH
export JOBASH_HOME="…"
export PATH="$JOBASH_HOME/bin:$PATH"
# shell snippets + completions/*.bash sourced here
# <<< JOBASH
```

Re-runs rewrite that block (no duplicates). `--example` never installs or edits bashrc.

Open a new shell (or `source ~/.bashrc`) after install.

Every install also stamps `~/.jobash/VERSION` (from `git describe`) + `SOURCE` (repo path) and installs the `jobash` hub:

```bash
jobash    # version + menu: installed | install | uninstall | docs | quit
```

Inner install/uninstall menus return to the hub on `0`. Docs lists all features and can run each `example.sh`.

## Tests

```bash
git submodule update --init vendor/bats-core
./tests/run
```

Uses temp prefix/bashrc only — never your real home config.

## License

Personal use; no license chosen yet.
