# Terraform Skills author for `jamfplatform` and review both providers

Two maintained Terraform providers reach Jamf Pro. Jamf's own `jamf/jamfplatform` is past 1.0 (v1.10.0 in November 2026) and also covers Jamf's cross-product services that act on the same devices: blueprints, device groups and compliance benchmarks. For scope, those count as part of the Jamf Pro Platform. The community `deploymenttheory/jamfpro` is older, more widely installed, pre-1.0 and not supported by Jamf. Terraform Skills write new HCL only for `jamfplatform`, because it is the one Jamf maintains, has the broader coverage and promises deprecation notice. Plan review accepts configurations and Terraform plans from either provider, because many Admins already run `jamfpro` and most of what plan review checks (deletes, replacements, drift, device scope) does not depend on the provider. Moving a configuration from `jamfpro` to `jamfplatform` is in scope. That is a provider move on one instance, not the instance-to-instance migration that ADR 0002 leaves to `jamf-cli-skills`. Other Jamf products with their own providers (Protect, Security Cloud, School, AI Governance) are out of scope until one is adopted as a Platform.

## Consequences

- Evals and Verified Versions track `jamfplatform` for authoring and both providers for plan review. Each Terraform Skill records the provider version, the Terraform CLI version and the Jamf Pro version it was verified against.
- `jamfpro`-only authoring patterns are not accepted, except when they explain how to migrate away from them.
- If `jamfplatform` stalls, or `jamfpro` becomes Jamf-supported, revisit this ADR rather than adding a second authoring target alongside it.
