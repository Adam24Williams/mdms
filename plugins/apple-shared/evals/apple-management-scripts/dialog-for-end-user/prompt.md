---
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
Our MDM runs scripts as root on our Macs (macOS 27). Write a zsh script that tells the person using the Mac that it will restart for maintenance tonight at 8 pm and asks them to save their work. They click OK to acknowledge it. Append a line to /var/log/maintenance-notice.log saying whether they acknowledged it. Use only tools built into macOS, no third-party dialog apps. Save it as maintenance-notice.zsh.
