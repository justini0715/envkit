# Profiles

Profiles provide explicit plugin/theme defaults without forcing surprising shell startup behavior.

Available profiles:
- `minimal` — smallest safe default set
- `general-dev` — general-purpose development plugins
- `cpp-42` — explicit C/C++-leaning example profile
- `personal` — opt-in personal profile that restores your preferred interactive init commands

Each profile is an `.env` file with shell-safe variables such as:
- `PROFILE_NAME`
- `PROFILE_DESCRIPTION`
- `PROFILE_PLUGINS`
- `PROFILE_THEME`
