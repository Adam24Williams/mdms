# Design

Settled design for the `mdms` Marketplace. Vocabulary is defined in [GLOSSARY.md](../GLOSSARY.md); the harder-to-reverse decisions are in [docs/adr/](adr/).

## Format and distribution

- Skills are Agent Skills (`SKILL.md` folders), published as a Claude Code plugin Marketplace in the public repo [Adam24Williams/mdms](https://github.com/Adam24Williams/mdms) under the MIT license.
- Marketplace `name` is `mdms`. It ships three Plugins: `apple-shared`, `jamf-pro`, `fleet`.
- Team Repos opt in by committing `.claude/settings.json`:

  ```json
  {
    "extraKnownMarketplaces": {
      "mdms": {
        "source": { "source": "github", "repo": "Adam24Williams/mdms" },
        "autoUpdate": true
      }
    },
    "enabledPlugins": { "apple-shared@mdms": true, "jamf-pro@mdms": true, "fleet@mdms": true }
  }
  ```

  Each Admin still runs `claude plugin install <plugin>@mdms --scope project` once per clone. Auto-update is off by default for third-party marketplaces, hence `autoUpdate: true`. Teams that prefer stability pin a tag via `ref`.
- Copying Skills into a Team Repo's `.claude/skills/` works but is not supported, because the copies never update.
- Each Plugin has its own semver `version`. Releases are tagged per Plugin with `claude plugin tag` (`fleet--v0.1.0`), and every release gets a changelog entry. Breaking changes (renamed Skill, changed env var) need a major version bump.
- SKILL.md frontmatter uses only portable fields (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`), so the same files work in Claude Code, claude.ai and other agents. CI enforces this.

## Scope

- Platforms: Jamf Pro and Fleet. Device OS: Apple first (macOS, then iOS/iPadOS). Fleet's Windows/Linux coverage comes later.
- Skills are Platform Skills or Shared Skills ([ADR 0001](adr/0001-platform-skills-over-neutral-abstraction.md)).
- Skill names carry a Platform prefix (`jamf-pro-`, `fleet-`, `apple-`), so they don't collide outside Claude Code's plugin namespacing.
- Platform Skills refer to Shared Skills by name. There are no hard install dependencies between Plugins.
- `jamf-pro` complements the Companion Plugin `jamf-cli-skills` and doesn't duplicate it ([ADR 0002](adr/0002-complement-jamf-cli-skills.md)).

## Safety

- Read Skills come first. Write Skills arrive only after the Change Plan pattern has been proven.
- Every Write Skill presents a Change Plan and waits for explicit confirmation. Fleet changes go through GitOps where possible.
- No Skill ever sends a Destructive Command ([ADR 0003](adr/0003-no-destructive-commands.md)).

## Platform access

- **Jamf Pro:** only through `jamf-cli` (Jamf-Concepts/jamf-cli). There are no bundled Jamf API scripts.
- **Fleet:** through `fleetctl` where it covers the task, otherwise bundled zsh + `curl` + `jq` scripts (`jq` ships with macOS 15+).
- **Credentials:** environment variables `JAMF_URL`, `JAMF_CLIENT_ID`, `JAMF_CLIENT_SECRET`, `FLEET_URL` and `FLEET_API_TOKEN`, with an optional Keychain helper. Credentials are never written to disk or committed. Each Skill documents the least-privilege API role it needs.

## Quality

- Each Skill records its Verified Version in `metadata`. For Jamf Skills that includes the `jamf-cli` version. CI flags any Skill that hasn't been re-verified in about 6 months.
- CI runs offline checks only: frontmatter rules, Verified Version staleness, `shellcheck`, `plutil -lint` on sample profiles, and script tests against recorded API responses.
- Live verification is manual before each release, against the maintainer's Jamf Pro sandbox and a local Fleet. Fleet tests run on `fleetctl preview`, which is Fleet Free. Skills that touch Premium features also run with a dev Premium license. Apple MDM test setup is deferred until a Fleet MDM Skill is planned.
- Each Skill has 3–5 eval cases for `claude plugin eval`, under `plugins/<plugin>/evals/<skill>/`, including at least one where the Skill should not trigger.
- `CONTRIBUTING.md` provides a Skill template that requires a Verified Version, env vars, minimum API privileges and evals. Write Skills require maintainer review via `CODEOWNERS`.

## Layout

```
.claude-plugin/marketplace.json
plugins/
  apple-shared/  .claude-plugin/plugin.json, skills/<skill>/SKILL.md, evals/<skill>/<case>/ (claude plugin eval format)
  jamf-pro/      (same)
  fleet/         (same)
docs/adr/  docs/design.md  GLOSSARY.md  CONTRIBUTING.md  README.md  CHANGELOG.md  LICENSE
.github/workflows/
```

## Roadmap

These Skills are candidates: each ships only if it fixes a baseline failure ([ADR 0004](adr/0004-baseline-gate.md)). All first-release Skills are Read Skills. Each Plugin ships as `v0.1.0` when ready, in this order:

1. **`apple-shared`:** `apple-configuration-profiles` (authoring and linting payloads), `apple-declarations` (DDM authoring), `apple-management-scripts` (zsh conventions, exit codes, logging).
2. **`fleet`** (after a local Fleet instance is running): `fleet-queries-and-policies` (osquery), `fleet-gitops` (YAML authoring), `fleet-hosts-and-labels` (lookups via API/`fleetctl`).
3. **`jamf-pro`:** `jamf-pro-extension-attributes`, `jamf-pro-smart-group-criteria` (smart groups and advanced searches), `jamf-pro-policy-scope-review`, `jamf-pro-api-roles` (least-privilege API role design).

Skill names above are working names.
