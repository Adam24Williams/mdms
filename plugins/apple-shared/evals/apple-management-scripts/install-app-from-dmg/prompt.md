---
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
All our Macs run macOS 27.1 or later. Write a zsh script that our MDM will run as root to install Firefox from Mozilla's DMG at https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US. It should download the DMG, mount it, copy Firefox.app into /Applications, and clean up afterwards. Our MDM marks a script as failed only when it exits non-zero. Save it as install-firefox.zsh.
