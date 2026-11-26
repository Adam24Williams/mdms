---
type: llm
focus: trace
---
Check this claim about the trace: the agent checked a current Fleet source instead of answering from memory. It ran at least one command or fetch against the fleetdm/fleet GitHub repository (for example `gh ... -R fleetdm/fleet`, `gh api repos/fleetdm/fleet/...`, or a fetch of github.com/fleetdm/fleet, api.github.com/repos/fleetdm/fleet or raw.githubusercontent.com/fleetdm/fleet) or fetched a page on fleetdm.com. Reading a Skill file does not count.

Pass only if the claim holds.
