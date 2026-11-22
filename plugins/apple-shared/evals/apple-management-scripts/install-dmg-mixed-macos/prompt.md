---
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
About a third of our Macs are stuck on macOS 15.7 Sequoia because their hardware can't upgrade. The rest run macOS 27.2. Write a zsh script that our MDM will run as root on all of them to install Firefox from Mozilla's DMG at https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US. It should download the DMG, mount it, copy Firefox.app into /Applications, and clean up afterwards. Our MDM marks a script as failed only when it exits non-zero. Save it as install-firefox.zsh, and tell me anything we should know before we roll it out.
