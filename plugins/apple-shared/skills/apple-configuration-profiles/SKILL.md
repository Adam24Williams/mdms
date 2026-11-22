---
name: apple-configuration-profiles
description: Use when writing, editing, reviewing or troubleshooting an Apple configuration profile (.mobileconfig) or any of its payloads (privacy/PPPC/TCC, restrictions, Wi-Fi, login window, software update, managed preferences) for macOS, iOS or iPadOS.
license: MIT
metadata:
  verified-against: "macOS 26-27, iOS 26; apple/device-management release branch"
  verified-on: "2026-11-21"
---

# Apple configuration profiles

Apple changes payload keys every OS release: keys get deprecated, removed, or replaced by declarative device management (DDM). What you remember about a payload is a snapshot from training. **Ground every payload in Apple's current schema for the Admin's target OS** before you write or approve it.

## Steps

1. **Pin the target OS.** Use the versions the Admin gives. If they gave none, state the versions you assume.
2. **Read the schema for each payload you touch.** Fetch `https://raw.githubusercontent.com/apple/device-management/release/mdm/profiles/<PayloadType>.yaml`, for example `com.apple.TCC.configuration-profile-policy.yaml`. The full list is at `https://github.com/apple/device-management/tree/release/mdm/profiles`. Read the `supportedOS` block for the payload and for every key you use:

   | Field | What to do with it |
   |---|---|
   | `deprecated` / `removed` at or below the target OS | Tell the Admin, and name the replacement from the key's `content` text. It's often a DDM configuration; use `apple-declarations` if installed. |
   | `allowmanualinstall: false` | The payload works only when delivered by MDM. Testing means scoping it to a test device in the MDM, not double-clicking or `profiles install`. |
   | `supervised: true`, `requiresdep`, `userapprovedmdm` | State the enrollment requirement. |
   | `devicechannel` / `userchannel` | Set `PayloadScope` (`System` or `User`) to a channel the payload supports. |
   | `rangelist`, `range`, and `content` notes (e.g. "can only deny") | Use only allowed values. The `content` text overrides what you remember. |

3. **Write or edit the profile.**
   - The top level is `PayloadType` `Configuration`, and every payload has `PayloadType`, `PayloadIdentifier`, `PayloadUUID` and `PayloadVersion` `1`.
   - Use a fresh `uuidgen` value for each payload, and reverse-DNS identifiers that are unique within the profile.
   - **Editing a deployed profile:** keep every existing `PayloadIdentifier`. The MDM replaces the installed profile by identifier, so changing it installs a second copy.
   - **Secrets** (Wi-Fi passwords, PSKs, certificate passphrases): keep them out of files that will be committed. Use the Platform's secret variables, or manage that payload only in the Platform.
4. **Lint.** Run `zsh scripts/lint-profile.zsh <file>` (path relative to this skill's directory) and fix every `ERROR`. To lint a profile the Admin pasted, write it to a file in `$TMPDIR`, not in their working directory. The script checks structure only; step 2 covers key validity.
5. **Report:**
   - the OS versions you targeted;
   - every deprecation or removal you found, with its replacement;
   - enrollment or delivery requirements;
   - how to test (MDM-only payloads are tested through the MDM);
   - any lint findings.
