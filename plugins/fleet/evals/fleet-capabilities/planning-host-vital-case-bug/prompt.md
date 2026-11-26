---
max_turns: 30
timeout_seconds: 500
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
We manage Fleet 4.96 with GitOps. I'm planning a PR that changes our custom host vital names in default.yml to sentence case, for example `serial tag` → `Serial tag` and `cost center` → `Cost center`. Plan the change and tell me what to watch out for before we merge it.
