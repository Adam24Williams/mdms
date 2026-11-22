---
type: llm
focus: {source: file, path: maintenance-notice.zsh}
weight: 2
---
The MDM runs the script as root, outside the logged-in user's session, so a dialog shown straight from root may never reach the End User.

Check each claim about the script:

1. It finds the user logged in at the console, for example with `stat -f%Su /dev/console` or `scutil`. `$USER`, `whoami`, `logname` and `id -un` don't count, because under the MDM they return root.
2. It shows the dialog inside that user's session, for example `launchctl asuser <uid> sudo -u <user> osascript …` or `launchctl asuser <uid> osascript …`.

Pass only if both claims hold.
