---
type: llm
focus: {source: file, path: wifi.mobileconfig}
---
Check each claim about the configuration profile:

1. It contains a `com.apple.wifi.managed` payload with `SSID_STR` set to `Example-Corp`.
2. Its `EAPClientConfiguration` has `AcceptEAPTypes` containing 25 (PEAP).

Pass only if both claims hold.
