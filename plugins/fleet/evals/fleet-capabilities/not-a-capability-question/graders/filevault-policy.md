---
type: llm
focus: {source: file, path: filevault-policy.sql}
---
Check this claim about the query: it reads osquery's `disk_encryption` table (for example its `filevault_status` or `encrypted` column) and returns a row only when FileVault is on, so a Fleet policy using it passes only on Macs with FileVault turned on.

Pass only if the claim holds.
