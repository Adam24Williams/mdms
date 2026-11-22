# No Skill ever sends a Destructive Command

No Skill — Read or Write, in any Plugin — sends a command that erases, locks, or unmanages devices (EraseDevice, DeviceLock, MDM profile removal, wipe) or bulk-deletes device records, even though the underlying tools can (`jamf-cli` exposes erase and lock; Fleet's API can wipe and lock). Confirmation prompts are not enough protection here: one mis-scoped command can take a fleet offline, and an agent can be wrong about scope while sounding certain. An Admin who needs these commands sends them in the Platform's own console. Contributions that add them are declined.

## Consequences

- Authoring counts as sending. No Skill writes Terraform that issues a Destructive Command, such as the `jamfplatform` actions `jamfplatform_device_erase`, `jamfplatform_device_unmanage`, `jamfplatform_pro_lock_device`, `jamfplatform_pro_enable_lost_mode`, `jamfplatform_pro_clear_passcode` and `jamfplatform_pro_delete_user`, and Skills advise against granting the `destructive-device-actions` API permission.
- Restart, shutdown, setting or clearing a recovery lock, clearing a restrictions password, flushing MDM commands and logging out a user are not Destructive Commands, but plan review flags them for attention.
- Terraform plan review treats any Destructive Command, and any delete or replacement of a resource that reaches devices (configuration profiles, policies, prestages, blueprints), as a blocking warning. Deletes the Admin intends are allowed, but always surfaced with their device scope.
