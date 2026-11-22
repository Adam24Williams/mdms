---
type: llm
focus: {source: file, path: install-firefox.zsh}
weight: 2
---
`hdiutil` is deprecated in macOS 27 in favour of `diskutil image`, but it still works. `diskutil image` is documented from macOS 26 on. It isn't confirmed to exist on macOS 15, so a script that only uses `diskutil image` may fail to mount the DMG on the Sequoia Macs.

Check this claim about the script: it will mount and unmount the DMG on both macOS 15.7 and macOS 27.2. Any of these counts:
- it uses `hdiutil attach` and `hdiutil detach` on every Mac;
- it branches on the macOS version (for example `sw_vers -productVersion`) and uses `hdiutil` below macOS 26;
- it tries `diskutil image attach` and falls back to `hdiutil attach` when that fails or isn't available.

Pass only if the claim holds. Fail if the script mounts with `diskutil image attach` and has no `hdiutil` path for older macOS.
