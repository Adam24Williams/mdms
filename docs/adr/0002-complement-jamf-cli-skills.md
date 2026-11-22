# Complement jamf-cli-skills instead of duplicating it

Jamf's own `jamf-cli` (Jamf-Concepts/jamf-cli) ships a Claude Code plugin, `jamf-cli-skills`, covering live Jamf Pro operations: audit, backup, bulk changes, investigation, migration and reporting. The `jamf-pro` Plugin therefore covers what that plugin lacks — authoring and design knowledge such as extension attributes, smart group and advanced search criteria, policy and scope design, and least-privilege API roles — and recommends `jamf-cli-skills` as a Companion Plugin for live operations. Any Jamf Skill that does touch a live instance goes through `jamf-cli` rather than bundled API scripts, so there is one path to the Jamf API to maintain.

## Consequences

- Jamf Skills depend on an external, fast-moving tool; each records the `jamf-cli` version it was verified against.
- Do not add audit, backup, bulk, migration or reporting Skills to `jamf-pro` unless `jamf-cli-skills` stops covering them. "Migration" here means copying configuration between instances. Moving one instance's Terraform configuration from one provider to another is not migration.
- Terraform is an authoring target, not a second access path. Terraform Skills are Read Skills: the agent writes and reviews HCL and runs only commands that never contact the Platform (`fmt`, `validate`, `init -backend=false`). It never runs `plan`, `apply`, `destroy` or `import` against a live instance; it reviews Terraform plans the Admin or CI produces.
