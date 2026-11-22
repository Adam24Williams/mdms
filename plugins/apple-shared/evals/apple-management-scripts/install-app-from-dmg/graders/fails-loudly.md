---
type: llm
focus: {source: file, path: install-firefox.zsh}
weight: 2
---
The MDM marks the script as failed only when it exits non-zero, so every failed step must end in a non-zero exit.

Check each claim about the script:

1. A failed download makes the script exit non-zero. An HTTP error such as a 404 counts as a failed download, so `curl` runs with `-f`/`--fail` (or `--fail-with-body`), or the script checks the HTTP status or the downloaded file before it continues.
2. A failure to mount the DMG, or to copy Firefox.app into /Applications, makes the script exit non-zero.
3. No failed step is followed by a path that still exits 0. A final `exit 0` that runs only after every step has succeeded (for example after `main || exit 1`, or after each step's `|| die`) is fine.

Pass only if all three claims hold.
