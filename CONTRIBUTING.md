# Contributing

Read [GLOSSARY.md](GLOSSARY.md) and [docs/design.md](docs/design.md) first. Use the glossary's terms in Skills, issues and pull requests.

## Adding a Skill

1. Choose the Plugin:
   - Shared Skill → `apple-shared`
   - Platform Skill → `jamf-pro` or `fleet`
2. Name the Skill with its Plugin's prefix (`apple-`, `jamf-pro-` or `fleet-`). The folder name must equal the `name`.
3. Create `plugins/<plugin>/skills/<skill-name>/SKILL.md` from the template below.
4. Add 3–5 eval cases under `plugins/<plugin>/evals/<skill-name>/`. At least one case must be a prompt where the Skill should **not** trigger. Run the cases with `claude plugin eval plugins/<plugin>`.
5. Put any bundled scripts in the Skill's folder. Write them in zsh with a `.zsh` extension (CI runs `zsh -n` on them). Any `.sh`/`.bash` scripts must pass `shellcheck`.
6. Run `scripts/check-skills.mjs` and `claude plugin validate .` locally.

### What we don't accept

- Skills that send a Destructive Command ([ADR 0003](docs/adr/0003-no-destructive-commands.md)).
- Jamf Pro Skills that call the API directly instead of through `jamf-cli` ([ADR 0002](docs/adr/0002-complement-jamf-cli-skills.md)).
- Jamf Pro audit, backup, bulk, migration or reporting Skills. `jamf-cli-skills` covers those.

## SKILL.md template

Frontmatter may use only these portable fields: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. CI enforces this.

```markdown
---
name: fleet-example-skill
description: One or two sentences on what this Skill does and when to use it. Lead with the trigger.
license: MIT
metadata:
  verified-against: "Fleet 4.95"
  verified-on: "2026-11-21"
---

# Example Skill

## When to use
...

## Requirements
- Environment variables: `FLEET_URL`, `FLEET_API_TOKEN`
- Minimum API privileges: Observer on the target team
- Tools: `fleetctl` 4.95+

## Steps
...
```

- `verified-against`: the Platform version you tested with. For Jamf Pro Skills, include the `jamf-cli` version too (`"Jamf Pro 11.x, jamf-cli 1.38"`). Shared Skills name the macOS/iOS versions.
- `verified-on`: the date you last checked the Skill against a live Platform (`YYYY-MM-DD`). CI warns once this is more than about 6 months old.

## Read Skills and Write Skills

- **Read Skill:** the agent never changes a live Platform itself.
- **Write Skill:** the agent does change a live Platform. It must present a Change Plan (which object, what changes, its scope, how many devices are affected) and wait for explicit confirmation. For Fleet, prefer GitOps over direct API writes.
- Write Skills require maintainer review (see `.github/CODEOWNERS`).

## Testing

- **CI** runs offline checks only: manifests, Skill frontmatter, `zsh -n` and `shellcheck` on scripts, and `plutil -lint` on sample profiles.
- **Before a release**, the maintainer verifies Skills live against a Jamf Pro sandbox and a local Fleet (`fleetctl preview`), then updates `verified-on`.
