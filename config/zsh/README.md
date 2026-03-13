# config/zsh

- `plugins.txt` — optional explicit plugin list (one plugin per line)
- `plugin-lock.txt` — optional lock refs for supported external plugins
- `theme.txt` — optional theme override (first non-comment line wins)

If `plugins.txt` or `theme.txt` contain no usable values, `dev-env` falls back to the selected profile.
