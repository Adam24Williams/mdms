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
- Terraform Skills live in `jamf-pro` with a `jamf-pro-terraform-` prefix. They write new HCL for `jamf/jamfplatform` and review configurations and Terraform plans from both `jamfplatform` and `deploymenttheory/jamfpro`. Scope is Jamf Pro, counting Jamf's blueprints, device groups and compliance benchmarks as part of the Jamf Pro Platform ([ADR 0005](adr/0005-terraform-skills-target-jamfplatform.md)). HCL stays CLI-neutral: verified on Terraform, expected to work on OpenTofu. Provider facts, gotchas and open questions are in [docs/research/terraform-providers.md](research/terraform-providers.md); read it before writing a Terraform Skill or its evals.

## Safety

- Read Skills come first. Write Skills arrive only after the Change Plan pattern has been proven.
- Every Write Skill presents a Change Plan and waits for explicit confirmation. Fleet changes go through GitOps where possible.
- No Skill ever sends a Destructive Command ([ADR 0003](adr/0003-no-destructive-commands.md)).

## Platform access

- **Jamf Pro:** only through `jamf-cli` (Jamf-Concepts/jamf-cli). There are no bundled Jamf API scripts.
- **Terraform:** an authoring target, not an access path. Terraform Skills are Read Skills. The agent runs only commands that never contact the Platform (`fmt`, `validate`, `init -backend=false`), never `plan`, `apply`, `destroy` or `import`. It reviews the human-readable Terraform plan (`terraform show plan.out`), not `-json` output, which includes sensitive values in plain text. It never opens `*.tfstate*` or `*.tfvars` files. Skills recommend an encrypted remote backend and an API client without the `destructive-device-actions` permission.
- **Fleet:** through `fleetctl` where it covers the task, otherwise bundled zsh + `curl` + `jq` scripts (`jq` ships with macOS 15+).
- **Credentials:** environment variables `JAMF_URL`, `JAMF_CLIENT_ID`, `JAMF_CLIENT_SECRET`, `FLEET_URL` and `FLEET_API_TOKEN`, with an optional Keychain helper. Credentials are never written to disk or committed. Each Skill documents the least-privilege API role it needs.

## Quality

- Each Skill records its Verified Version in `metadata`. For Jamf Skills that includes the `jamf-cli` version. Terraform Skills record the provider, Terraform CLI and Jamf Pro versions instead. Their plan-review evals use text plans recorded from the maintainer's Jamf Pro sandbox, with secrets and identifiers scrubbed. CI flags any Skill that hasn't been re-verified in about 6 months.
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
docs/adr/  docs/research/  docs/design.md  GLOSSARY.md  CONTRIBUTING.md  README.md  CHANGELOG.md  LICENSE
.github/workflows/
```

## Roadmap

These Skills are candidates: each ships only if it fixes a baseline failure ([ADR 0004](adr/0004-baseline-gate.md)). All first-release Skills are Read Skills. Each Plugin ships as `v0.1.0` when ready, in this order:

1. **`apple-shared`:** `apple-configuration-profiles` (authoring and linting payloads), `apple-declarations` (DDM authoring), `apple-management-scripts` (zsh conventions, exit codes, logging).
2. **`fleet`** (after a local Fleet instance is running): `fleet-queries-and-policies` (osquery), `fleet-gitops` (YAML authoring), `fleet-hosts-and-labels` (lookups via API/`fleetctl`).
3. **`jamf-pro`:** `jamf-pro-extension-attributes`, `jamf-pro-smart-group-criteria` (smart groups and advanced searches), `jamf-pro-policy-scope-review`, `jamf-pro-api-roles` (least-privilege API role design). Then the Terraform Skills, in this order:
   - `jamf-pro-terraform-plan-review`: flags deletes and replacements that reach devices (with scope), Destructive Command actions, drift from GUI edits, post-import removal noise and forced replacements.
   - `jamf-pro-terraform-authoring`: `jamfplatform` HCL, covering provider pinning, OAuth client and least-privilege permissions, references between objects, scripts kept out of inline strings, and Jamf Cloud propagation delay.
   - `jamf-pro-terraform-adoption`: bringing an existing instance under Terraform with jamformer (run by the Admin), cleaning up generated HCL, the first plan after import, and moving a configuration from `jamfpro` to `jamfplatform` (a provider move, not an instance migration).

Skill names above are working names.
