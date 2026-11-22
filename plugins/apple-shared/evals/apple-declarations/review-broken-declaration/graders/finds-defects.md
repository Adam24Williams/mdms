---
type: llm
focus: last_message
weight: 2
---
The declaration has these defects:

A. `ServerToken` is missing; every declaration needs `Type`, `Identifier`, `ServerToken` and `Payload`.
B. `AllowGenmoji` is the string `"false"`, not the boolean `false`.
C. `AllowVisualIntelligenceSummary` is deprecated in iOS 27 (and never applied to macOS). `AllowVisualIntelligence`, introduced in iOS 27 and macOS 27, covers Visual Intelligence instead.
D. `ForceOnDeviceOnlyTranslation` isn't supported on macOS, so it has no effect on the Macs.

Check the agent's final reply. Pass only if it identifies C and D, and at least one of A and B.
