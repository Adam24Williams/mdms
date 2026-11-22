---
type: llm
focus: {source: file, path: block-team.json}
weight: 2
---
Check each claim about the JSON declaration:

1. `Type` is `com.apple.configuration.app.settings`, and the top level has `Identifier`, `ServerToken` and `Payload`.
2. `Payload.Allowed.DeniedBinaries` is an array with an entry that matches the Team ID `ABCDE12345` (a `TeamID` field with that value).

Pass only if both claims hold.
