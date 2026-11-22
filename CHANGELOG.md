# Changelog

Each Plugin is versioned independently with semver. A major bump is required for breaking changes, such as a renamed Skill or a changed environment variable. Release tags use `<plugin>--v<version>` (created with `claude plugin tag`).

## apple-shared

### Unreleased

- Added `apple-configuration-profiles`: grounds payloads in Apple's current device-management schema (deprecations, MDM-only delivery, enrollment requirements) and lints profile structure with `scripts/lint-profile.zsh`.
- Added `apple-declarations`: finds declaration types newer than the model's training (such as macOS 27's `app.settings`) and grounds keys in Apple's current DDM schema (per-OS support, deprecations, enrollment requirements, End User impact).
- Added `apple-management-scripts`: checks each macOS command-line tool a management script calls for a deprecation notice in its man page and uses the named replacement (such as `diskutil image` for `hdiutil` on macOS 27).

## jamf-pro

_Unreleased._

## fleet

_Unreleased._
