---
type: llm
focus: {source: file, path: restrictions.mobileconfig}
weight: 2
---
The original profile had top-level PayloadIdentifier `com.example.it.restrictions` and a `com.apple.applicationaccess` payload with PayloadIdentifier `com.example.it.restrictions.applicationaccess`. Check each claim about the updated file:

1. The top-level PayloadIdentifier is still exactly `com.example.it.restrictions`.
2. The restrictions payload's PayloadIdentifier is still exactly `com.example.it.restrictions.applicationaccess`.
3. `allowAirDrop` is set to `false` inside the existing `com.apple.applicationaccess` payload, not in a second, new restrictions payload.
4. `allowCamera` is still `false`.

Pass only if all four claims hold.
