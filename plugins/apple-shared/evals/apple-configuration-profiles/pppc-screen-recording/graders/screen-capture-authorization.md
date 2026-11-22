---
type: llm
focus: {source: file, path: zoom-screen-recording.mobileconfig}
weight: 2
---
The file is a configuration profile. Check each claim:

1. It contains a payload whose PayloadType is `com.apple.TCC.configuration-profile-policy`.
2. Under `Services`, it has a `ScreenCapture` entry for identifier `us.zoom.xos` with `IdentifierType` `bundleID` and a non-empty `CodeRequirement` string.
3. The ScreenCapture entry uses `Authorization` set to `AllowStandardUserToSetSystemService`. It does NOT grant the service with `Allowed` set to true or `Authorization` set to `Allow`, because the Screen Capture service cannot be pre-approved by a profile.
4. It does not include both `Allowed` and `Authorization` in the same entry.

Pass only if all four claims hold.
