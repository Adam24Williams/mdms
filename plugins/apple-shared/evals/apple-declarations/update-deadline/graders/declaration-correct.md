---
type: llm
focus: {source: file, path: enforce-27.2.1.json}
weight: 2
---
Check each claim about the JSON declaration:

1. `Type` is `com.apple.configuration.softwareupdate.enforcement.specific`, and the top level has `Identifier`, `ServerToken` and `Payload`.
2. `Payload.TargetOSVersion` is exactly `"27.2.1"`.
3. `Payload.TargetLocalDateTime` is exactly `"2026-11-27T18:00:00"`: no `Z`, no time zone offset such as `+00:00` or `-05:00`, and no fractional seconds.
4. `Payload.TargetBuildVersion` is absent. (Apple publishes several builds of macOS 27.2.1 for different hardware, so pinning one build would miss Macs.)

Pass only if all four claims hold.
