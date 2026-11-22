# Terraform providers for Jamf Pro

Checked 2026-11-21 against the Terraform Registry API, the OpenTofu registry, GitHub (`gh api`) and Jamf's docs. Providers release every week or two, so re-check versions before writing evals. Decisions that rest on this are in [ADR 0005](../adr/0005-terraform-skills-target-jamfplatform.md), [ADR 0002](../adr/0002-complement-jamf-cli-skills.md) and [ADR 0003](../adr/0003-no-destructive-commands.md).

## Providers

| Provider | Publisher | Latest | Status | Coverage |
|---|---|---|---|---|
| [`jamf/jamfplatform`](https://registry.terraform.io/providers/jamf/jamfplatform) | Jamf ([repo](https://github.com/jamf/terraform-provider-jamfplatform)) | v1.10.0 (2026-11-19) | Active. Moved from `Jamf-Concepts/jamfplatform` (last v0.31.2, 2026-09-10) at v0.32.0; existing state needs `terraform state replace-provider jamf-concepts/jamfplatform jamf/jamfplatform`. | About 111 resources, 157 data sources and 38 actions. Jamf Pro (`jamfplatform_pro_*`), blueprints, device groups, compliance benchmarks, Security Cloud, AI Governance, Jamf Account SSO. Terraform ≥1.13 or OpenTofu ≥1.6. |
| [`deploymenttheory/jamfpro`](https://registry.terraform.io/providers/deploymenttheory/jamfpro) | Deployment Theory, community ([repo](https://github.com/deploymenttheory/terraform-provider-jamfpro)) | v0.43.0 (2026-11-06) | Active, pre-1.0, breaking changes happen. The README says it is "not officially supported by Jamf". About 486k downloads. | About 75 resources, 54 data sources. Classic and Pro APIs. Terraform ≥1.13, Jamf Pro ≥11.20.0. |
| `Jamf-Concepts/jamfprotect`, `jsctfprovider`, `jamfschool`, `jamfautoupdate` | Jamf Concepts | various | Active to early | Protect, Security Cloud, School, Auto Update metadata. Out of scope (ADR 0005). |
| `sioncojp/jamf`, `Yohan460/jamf`, `w0de/jamf` | individuals | 2020–2024 | Abandoned or dormant | Classic API only |

All six Jamf providers above are published on the OpenTofu registry as well.

## Authentication

- `jamfplatform` uses one OAuth client from Jamf Account, scoped to an environment (preferred), a tenant or an organization when it's created. Beta credentials were revoked when the Platform API went GA on 2026-09-03 ([guide](https://github.com/jamf/terraform-provider-jamfplatform/blob/main/docs/guides/platform-api-ga.md)).
- `jamfpro`: `auth_method` is `oauth2` (a Jamf Pro API client) or `basic`; `auth_provider` is `direct` or `platform` ([README](https://github.com/deploymenttheory/terraform-provider-jamfpro)).

## Device actions in `jamfplatform`

Actions need Terraform 1.14+. There are 38 of them, listed under [`docs/actions/`](https://github.com/jamf/terraform-provider-jamfplatform/tree/main/docs/actions). Each doc's example declares one as `action "jamfplatform_<doc name>" "<label>" { config { … } }`, for example `action "jamfplatform_pro_lock_device" "lock"` ([pro_lock_device.md](https://github.com/jamf/terraform-provider-jamfplatform/blob/main/docs/actions/pro_lock_device.md)).

Jamf requires the `destructive-device-actions` API permission for only some actions, and that set doesn't match ADR 0003's list of Destructive Commands. Withholding the permission therefore doesn't block Lost Mode or clearing a passcode.

| Action type | Needs `destructive-device-actions` |
|---|---|
| `jamfplatform_device_erase`, `jamfplatform_device_unmanage`, `jamfplatform_pro_lock_device`, `jamfplatform_pro_delete_user` | Yes |
| `jamfplatform_pro_enable_lost_mode`, `jamfplatform_pro_clear_passcode` | No |
| `jamfplatform_device_restart`, `jamfplatform_device_shutdown`, `jamfplatform_pro_set_recovery_lock`, `jamfplatform_pro_clear_recovery_lock`, `jamfplatform_pro_clear_restrictions_password`, `jamfplatform_pro_flush_mdm_commands`, `jamfplatform_pro_disable_lost_mode`, `jamfplatform_pro_log_out_user` | No |

Which of these count as Destructive Commands is decided in [ADR 0003](../adr/0003-no-destructive-commands.md).

## Adopting an existing instance

- [jamformer](https://github.com/Jamf-Concepts/jamformer) (Jamf Concepts, MIT, v0.7.0) is the exporter. It supports `jamfplatform` (default), `jamfprotect`, `jsc` and `jamfpro`. It discovers objects, writes import blocks, runs `terraform plan -generate-config-out`, then rewrites cross-references. It moves secrets into sensitive variables or `.tpl` templates and generates a `.gitignore` for tfvars and state. The README calls it "not production-ready". [Jamf guide](https://concepts.jamf.com/en/guides/infrastructure-as-code/adopting-terraform-for-jamf-with-jamformer/).
- Every `jamfplatform` resource supports `terraform import` ([Jamf developer portal](https://developer.jamf.com/platform-api/docs/managing-the-jamf-platform-with-terraform-the-jamf-platform-provider)).
- After an import, the first plan often proposes removing blocks you never wrote. That's harmless on most resources and a real reset on two ([importing guide](https://github.com/jamf/terraform-provider-jamfplatform/blob/main/docs/guides/importing.md)).
- Older importers (`deploymenttheory/terraform-importer-jamfpro`, `jamftf-python-terraform-importer`) have been superseded by jamformer.
- [`Jamf-Concepts/terraform-jamf-reference`](https://github.com/Jamf-Concepts/terraform-jamf-reference) pins `jamfpro` 0.19.1, so it is stale.

## Gotchas

- **Concurrency:** `jamfpro` recommends `-parallelism=1` always, because the default of 10 gives inconsistent behaviour. Jamf's reference repo adds `mandatory_request_delay_milliseconds = 100`. `jamfplatform` has `min_request_interval_ms` (default 0).
- **Propagation:** Jamf Cloud can take up to 60 s to propagate a change across its load-balanced servers. `jamfpro` has `jamfpro_load_balancer_lock` and `custom_cookies` to work around this.
- **Drift:** anything declared is owned by Terraform, so GUI edits show up as drift. Undeclared blocks are left alone. Name-collision checks follow Jamf's per-type case and accent rules ([name-collisions guide](https://github.com/jamf/terraform-provider-jamfplatform/blob/main/docs/guides/name-collisions.md)).
- **Secrets:**
  - `jamfpro_script.script_contents` is not marked sensitive, so script bodies are stored in plain state and shown in plans.
  - State is always plain text.
  - `terraform show -json` prints sensitive values in plain text, while the human-readable `terraform show` redacts them.
  - `TF_LOG=DEBUG` logs full request bodies. `jamfplatform` redacts them first.
- **Forced replacement:**
  - `jamfplatform_cbengine_benchmark` has no update, so any change replaces it.
  - Moving a blueprint payload to a `raw_component` shows as a destroy plus a create.
- **Unsafe destroys:**
  - an AI Governance policy still referenced by a blueprint
  - a Jamf Account SSO connection, which can lock people out
- **Version churn:** `jamfplatform` minor releases can break things, so pin with `~> 1.10.0`. It gives 90 days' notice before removing an attribute. `jamfpro` 0.43.0 migrated many collections to sets.

## Overlap with jamf-cli

[`jamf-cli`](https://github.com/Jamf-Concepts/jamf-cli) (v1.38.0) has no Terraform features. Its `jamf-cli-skills` plugin (audit, backup, bulk, cli, investigate, migrate, report) has no Terraform Skill. No existing Agent Skill for Terraform with Jamf turned up in a GitHub search.

## Not verified

The plan-review evals depend on the first three. Check them in the sandbox first.

- What happens on enrolled devices when a configuration profile, policy or prestage is deleted through Terraform. Jamf's usual behaviour is inferred, and no maintainer doc confirms it.
- Which two resources really reset after an import (see the importing guide).
- How actions are triggered: invoked directly, or wired to a lifecycle event.
- Per-resource import support in `jamfpro`.
- What destroy does for `jamfpro` managed software updates and `macos_configuration_profile_plist`.
- Whether Jamf endorses `jamfpro` beyond acknowledging it.
