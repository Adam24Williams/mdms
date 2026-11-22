---
name: apple-declarations
description: Use when writing, reviewing or troubleshooting an Apple declarative device management (DDM) declaration (a com.apple.configuration.*, com.apple.asset.* or com.apple.activation.* JSON), including software update deadlines and deferrals, for macOS, iOS, iPadOS, tvOS or visionOS.
license: MIT
metadata:
  verified-against: "macOS 26-27, iOS 26-27; apple/device-management Release-v27.2"
  verified-on: "2026-11-21"
---

# Apple declarations

Apple adds declaration types and keys in every OS release, often in point releases. Your memory of DDM is older than the Admin's devices. **Before you say a declaration can't do something, list Apple's current declarations and read the schema.**

## Steps

1. **Pin the target versions** for each OS on the Admin's devices, such as "Macs on 26.7 and 27.2". If the Admin gave none, state the versions you assume.
2. **Find the declaration.** List the types in `https://github.com/apple/device-management/tree/release/declarative/declarations/configurations` (also `assets/` and `activations/`). File names drop the `com.apple.configuration.` prefix, so `passcode.settings.yaml` is `com.apple.configuration.passcode.settings`. Pick by `title` and `description`, not by what you remember. If `curl` to GitHub is blocked, use WebFetch, and if WebFetch fails, try `curl`.
3. **Read the schema:** `https://raw.githubusercontent.com/apple/device-management/release/declarative/declarations/configurations/<name>.yaml`. Apple's examples are in `examples/declarative/declarations/configurations/<name>/` on the same branch. Use the examples' JSON nesting. For the declaration and for each key you use, check `supportedOS` for each OS:

   | Field | What to do with it |
   |---|---|
   | `introduced` above a target version | Tell the Admin those devices won't enforce it, and give them a way to cover those devices (upgrade first, or another control in the meantime). |
   | `introduced: n/a` for an OS | Leave the key out of that OS's declaration. When OSes need different keys, write one declaration per OS. |
   | `deprecated` / `removed` | Tell the Admin, and name the replacement key or type. |
   | `allowed-enrollments`, `allowed-scopes` | State the enrollment requirement (for example, supervised only) and the channel (system or user). |

4. **Write the declaration** as JSON with `Type`, `Identifier`, `ServerToken` and `Payload`, and save it where the Admin asked.
5. **Report** the target versions, which of them support the declaration and each key, and any deprecations and enrollment requirements.
