---
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
We manage supervised iPhones on iOS 27 and supervised Macs on macOS 27. Write declarative device management software update settings for both. On the Macs, hide minor macOS updates for 14 days and major macOS upgrades for 60 days after Apple releases them. On the iPhones, hide OS updates for 14 days. Save the Mac declaration as mac-updates.json and the iPhone declaration as iphone-updates.json.
