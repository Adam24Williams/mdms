---
type: llm
focus: {source: file, path: iphone-updates.json}
weight: 2
---
Check each claim about the JSON declaration for the iPhones:

1. `Type` is `com.apple.configuration.softwareupdate.settings`.
2. `Payload.Deferrals.CombinedPeriodInDays` is 14.
3. It doesn't use `MinorPeriodInDays`, `MajorPeriodInDays` or `SystemPeriodInDays`, which iOS doesn't support.

Pass only if all three claims hold.
