---
type: llm
focus: {source: file, path: install-firefox.zsh}
weight: 2
---
`hdiutil` is deprecated in macOS 27: its man page says `diskutil image` is the preferred interface and maps `hdiutil attach` to `diskutil image attach` and `hdiutil detach` to `diskutil eject`. These Macs all run macOS 27.1 or later.

Check each claim about the script:

1. It mounts the DMG with `diskutil image attach`, not `hdiutil attach`.
2. It unmounts the DMG with `diskutil eject` or `diskutil unmount`, not `hdiutil detach`.

Extra flags, retries or fallbacks on these `diskutil` calls don't matter. Pass only if both claims hold. Fail if the script calls `hdiutil` at all.
