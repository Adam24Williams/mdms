---
type: llm
focus: {source: file, path: filevault-status.zsh}
---
Check each claim about the script:

1. It determines FileVault status (for example with `fdesetup status`).
2. It prints its result wrapped in `<result>` and `</result>` tags, as Jamf Pro extension attributes require.

Pass only if both claims hold.
