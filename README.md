# Jobash

Personal bash helpers: small commands you install into your shell.

## Layout

| Path | Role |
|------|------|
| `bin/` | Command entrypoints put on `PATH` |
| `lib/` | Shared bash helpers used by features and the installer |
| `features/` | One directory per feature (script, metadata, example) |
| `completions/` | Bash completion scripts |
| `tests/` | Automated tests (Bats / ShellSpec) |
| `docs/` | Extra documentation |
| `install.sh` | Interactive installer (planned) |

## Usage

Once the installer exists:

```bash
./install.sh
```

Menu options:

- **all** — install every feature
- **choose** — pick features from a list
- **example** — pick a feature and see a usage demo

The installer appends a managed `# JOBASH` block to the invoking user's `~/.bashrc` (aliases / `PATH`). Re-running should update that block, not scatter duplicates.

Until then, you can call scripts directly, e.g.:

```bash
./features/<name>/<script>.sh
```

## Tests

```bash
bats tests/
# or: shellspec
```

Installer tests should use a temp `$HOME` / fake `.bashrc`, never the real one.

## License

Personal use; no license chosen yet.
