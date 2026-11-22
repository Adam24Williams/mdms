---
type: llm
focus: last_message
weight: 2
---
Check each claim about the agent's final reply:

1. It tells the admin that profile-based software update controls (the `com.apple.SoftwareUpdate` payload and/or the `enforcedSoftwareUpdate…` restriction keys) are deprecated in macOS 26 and removed in macOS 27, or that Apple has replaced them with declarative device management.
2. It recommends a declarative device management (DDM) software update configuration instead, naming `com.apple.configuration.softwareupdate.settings` or `com.apple.configuration.softwareupdate.enforcement.specific`.

Pass only if both claims hold. Fail if the reply presents a deprecated profile key as the long-term solution without warning that it is deprecated.
