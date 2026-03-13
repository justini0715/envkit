# Recovery and Rollback Runbook

## Backup Behavior
`envkit` creates `.envkit.bak.*` backups when managed files change.
Typical targets include:
- `~/.zshrc`
- managed drop-in files under `~/.config/zsh/conf.d/`
- plugin/theme/user config outputs when rewritten

## List Backups
```bash
./envkit backups-list
```

## Roll Back a File
```bash
./envkit rollback --backup-file /path/to/file.envkit.bak.<timestamp> --target ~/.zshrc
```

If `--target` is omitted, rollback defaults to `~/.zshrc`.

## Clean Backup Files
Dry-run by default:
```bash
./envkit clean-backups
```

Delete backups:
```bash
./envkit clean-backups --apply
```

## Recovery Guidance
- use `backups-list` before deleting anything
- prefer rollback over manual copy/paste when a managed file was recently rewritten
- rerun `./envkit configure --profile <name>` after rollback if you need to re-establish the managed bootstrap block
