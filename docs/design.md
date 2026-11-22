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

## Environment Profile

Decided in [ADR 0006](adr/0006-environment-profile-file-gated-on-platform-skill.md).

- **Packaging:** each Plugin gets its own Setup Interview Skill (`jamf-pro-setup`, `fleet-setup`, `apple-setup`), added only once a Skill in that Plugin needs it. Each one writes only its own Plugin's section of the Environment Profile.
- **Location:** the Environment Profile is Markdown at `.mdms/environment-profile.md` in the Team Repo. It is committed and reviewed like any other change.
  - The file has one `##` heading per Plugin, with Instances listed under labels (`production`, `sandbox`).
  - The path and headings are a contract with the Skills that read the file, so renaming either is a breaking change.
  - Outside a repo, such as in claude.ai, the Setup Interview prints the same content for the Admin to paste into project instructions.
- **Detect before asking:** the Setup Interview is a Read Skill and asks the Admin only for what it can't detect. Its only write is the Environment Profile file, which the Admin commits. It may detect from:
  - local tool versions (`jamf-cli`, `fleetctl`, `terraform`);
  - Terraform `.terraform.lock.hcl` and `required_providers` (never `*.tfstate*` or `*.tfvars`);
  - the Fleet GitOps layout;
  - one read-only query per Instance for its server version and license tier.

  It does no device, user or object inventory, which belongs to `jamf-cli-skills` ([ADR 0002](adr/0002-complement-jamf-cli-skills.md)).
- **Contents:**
  - Platform and version, hosting (Jamf Cloud or on-prem; Fleet self-hosted or Fleet-managed) and license tier.
  - Managed OS families and minimum supported OS versions.
  - Terraform provider and CLI, and whether Fleet GitOps is used and where.
  - Naming Conventions, and whether a sandbox exists.
  - A `recorded-on` date for each fact.
- **Conventions:** a Skill follows a recorded Convention over its own default, and uses its default only when the profile records none.
  - Only the Setup Interview writes naming Conventions. It infers them from files already in the Team Repo, such as Terraform resource `name` values and script filenames, and asks the Admin when those don't settle it. It never lists object names from an Instance, which would be inventory.
  - A naming Convention records, for each object type the team names (policies, smart groups, configuration profiles, scripts, packages, extension attributes, Terraform resource labels), a pattern with one or two invented examples, and how the team marks test or sandbox objects.
  - Where the Admin has no Convention, the Setup Interview may offer a default, sourced as described in [Quality](#quality).
- **Never in the file:** credentials, server URLs or tenant names (those live in environment variables), device or user identifiers, and device counts.
- **Re-running:** the Setup Interview re-detects what it can, updates the file in place, shows the Admin which facts changed and asks only about facts that are new or missing.
- **Triggering:** the Setup Interview runs only on an explicit request. Other Skills mention it by name and never invoke it.
- **Reading the profile:** in every other Skill the Environment Profile is optional.
  - If the file exists, the Skill reads it.
  - If a fact the Skill needs is missing, it asks the Admin for that fact, mentions the Setup Interview once, and carries on.
  - When a version decides the answer and detection is cheap, the Skill re-detects it rather than trusting the file.
  - When the answer depends on which Instance a task targets, the Skill asks.

## Quality

- Each Skill records its Verified Version in `metadata`. For Jamf Skills that includes the `jamf-cli` version. Terraform Skills record the provider, Terraform CLI and Jamf Pro versions instead. Their plan-review evals use text plans recorded from the maintainer's Jamf Pro sandbox, with secrets and identifiers scrubbed. CI flags any Skill that hasn't been re-verified in about 6 months.
- A default practice a Skill offers, such as a naming pattern, smart group structure or policy design, cites Jamf's documentation or a named community source (a JNUC talk, the Mac Admins community), recorded in `docs/research/`. The maintainer's own practice may stand in when the research file marks it as opinion.
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

1. **`apple-shared`:** `apple-configuration-profiles` (authoring and linting payloads), `apple-declarations` (DDM authoring, including software-update deadlines the End User sees), `apple-management-scripts` (zsh style, header and inline comments, exit codes, logging, and dialogs a script shows the End User).
2. **`fleet`** (after a local Fleet instance is running): `fleet-queries-and-policies` (osquery), `fleet-gitops` (YAML authoring), `fleet-hosts-and-labels` (lookups via API/`fleetctl`).
3. **`jamf-pro`:** `jamf-pro-extension-attributes`, `jamf-pro-smart-group-criteria` (smart group criteria and structure, and advanced searches), `jamf-pro-policy-design` (designing and reviewing policies: scope, trigger, frequency, execution order, script parameters, and End User impact such as restarts, deferrals and timing), `jamf-pro-api-roles` (least-privilege API role design). Then the Terraform Skills, in this order:
   - `jamf-pro-terraform-plan-review`: flags deletes and replacements that reach devices (with scope), Destructive Command actions, drift from GUI edits, post-import removal noise and forced replacements.
   - `jamf-pro-terraform-authoring`: `jamfplatform` HCL, covering provider pinning, OAuth client and least-privilege permissions, references between objects, scripts kept out of inline strings, Jamf Cloud propagation delay, and modules (where a module's boundary goes, which values become inputs, and when a small Instance is better off without modules).
   - `jamf-pro-terraform-adoption`: bringing an existing instance under Terraform with jamformer (run by the Admin), cleaning up generated HCL, the first plan after import, and moving a configuration from `jamfpro` to `jamfplatform` (a provider move, not an instance migration).

A Plugin's Setup Interview ships alongside its first Skill whose baseline fails because an environment fact is missing (see [Environment Profile](#environment-profile)).

Skill names above are working names.
