---
type: llm
focus: {source: file, path: mac-updates.json}
weight: 2
---
Check each claim about the JSON declaration for the Macs:

1. `Type` is `com.apple.configuration.softwareupdate.settings`.
2. `Payload.Deferrals.MinorPeriodInDays` is 14 and `Payload.Deferrals.MajorPeriodInDays` is 60.
3. It doesn't use `CombinedPeriodInDays` or `RecommendedCadence`, which macOS doesn't support.

Pass only if all three claims hold.
