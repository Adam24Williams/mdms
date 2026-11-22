# Contributing

Read [GLOSSARY.md](GLOSSARY.md) and [docs/design.md](docs/design.md) first. Use the glossary's terms in Skills, issues and pull requests.

## Adding a Skill

A Skill must fix a failure seen in a baseline run without it ([ADR 0004](docs/adr/0004-baseline-gate.md)). Write the evals first, and write the Skill only if the baseline fails them.

1. Choose the Plugin:
   - Shared Skill → `apple-shared`
   - Platform Skill → `jamf-pro` or `fleet`
2. Name the Skill with its Plugin's prefix (`apple-`, `jamf-pro-` or `fleet-`). The folder name must equal the `name`.
3. **Write the evals first.** Add 3–5 eval cases under `plugins/<plugin>/evals/<skill-name>/`.
   - At least one case must be a prompt where the Skill should **not** trigger.
   - Base cases on mistakes you've actually seen an agent make, plus anything that depends on facts newer than the model's training (new OS releases, Platform releases, deprecations).
4. **Run the baseline**, with no Skill present: `zsh scripts/eval.zsh <plugin> <skill-name> baseline`. Read the evidence for every failing grader, not just the scores. If every outcome grader passes, stop: there is nothing for a Skill to fix. Either write harder cases or drop the Skill and note why in the PR.
5. **Write the Skill** to address the failures you saw. Create `plugins/<plugin>/skills/<skill-name>/SKILL.md` from the template below.
6. **Measure it:** `zsh scripts/eval.zsh <plugin> <skill-name> measure`. The Skill must raise the score (a positive Δ) on the cases that failed, and must not fire on the should-not-trigger case. Put the score table in the PR.
7. Put any bundled scripts in the Skill's folder. Write them in zsh with a `.zsh` extension (CI runs `zsh -n` on them). Any `.sh`/`.bash` scripts must pass `shellcheck`. Add fixture tests under `tests/<script-name>/` (see `tests/run.zsh`).
8. Run `node scripts/check-skills.mjs`, `claude plugin validate .` and `zsh tests/run.zsh` locally.

Eval runs use your own Claude credentials and cost money. [docs/evals.md](docs/evals.md) covers flags, cost caps, the case and grader format, and known gotchas.

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

- **CI** runs offline checks only: manifests, Skill frontmatter, `zsh -n` and `shellcheck` on scripts, script fixture tests (`tests/run.zsh`), and `plutil -lint` on sample profiles.
- **Before a release**, the maintainer verifies Skills live against a Jamf Pro sandbox and a local Fleet (`fleetctl preview`), then updates `verified-on`.
