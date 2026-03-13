# Recovery and Rollback Runbook

## Backup Behavior
`dev-env` creates `.dev-env.bak.*` backups when managed files change.
Typical targets include:
- `~/.zshrc`
- managed drop-in files under `~/.config/zsh/conf.d/`
- plugin/theme/user config outputs when rewritten

## List Backups
```bash
./dev-env backups-list
```

## Roll Back a File
```bash
./dev-env rollback --backup-file /path/to/file.dev-env.bak.<timestamp> --target ~/.zshrc
```

If `--target` is omitted, rollback defaults to `~/.zshrc`.

## Clean Backup Files
Dry-run by default:
```bash
./dev-env clean-backups
```

Delete backups:
```bash
./dev-env clean-backups --apply
```

## Recovery Guidance
- use `backups-list` before deleting anything
- prefer rollback over manual copy/paste when a managed file was recently rewritten
- rerun `./dev-env configure --profile <name>` after rollback if you need to re-establish the managed bootstrap block
