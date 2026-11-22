---
type: llm
focus: {source: file, path: run-tests.zsh}
---
Check each claim about the script:

1. It runs `npm test` in each folder under `packages/` that contains a `package.json`.
2. A failing package doesn't stop the loop. The script prints the failed packages and exits non-zero if there were any, and 0 otherwise.

Pass only if both claims hold.
