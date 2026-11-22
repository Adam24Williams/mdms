---
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
Write a zsh script for our monorepo's CI. It runs `npm test` in every package folder under packages/ that has a package.json, keeps going if one fails, prints which packages failed, and exits non-zero if any failed. Save it as run-tests.zsh.
