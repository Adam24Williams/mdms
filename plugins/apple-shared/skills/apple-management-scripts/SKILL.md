---
name: apple-management-scripts
description: Use when writing, reviewing or troubleshooting a shell script that an MDM or management agent runs on Macs, such as an install, configuration, remediation or inventory script, or one that shows a dialog to the End User.
license: MIT
metadata:
  verified-against: "macOS 27.2"
  verified-on: "2026-11-21"
---

# Apple management scripts

Apple deprecates command-line tools in macOS releases, and its man pages name the replacements. What you remember about these tools is older than the Admin's Macs. **Before you write a call to a macOS command-line tool, read that tool's man page on this Mac for a deprecation notice.**

## Steps

1. **Pin the target macOS versions** on the Admin's Macs. If the Admin gave none, state the versions you assume. Run `sw_vers -productVersion` to get this Mac's version.
2. **Check each tool the script calls** that ships with macOS (in `/usr/bin`, `/usr/sbin`, `/bin` or `/sbin`; shell builtins don't count):

   ```zsh
   man <tool> | col -b | grep -n -i -B2 -A25 deprecat
   ```

   When the notice names a replacement, run the replacement's help (for example `<tool> <subcommand>` with no arguments) for its syntax, then:

   | What you find | What to do |
   |---|---|
   | The tool, or the verb you need, is deprecated | Use the replacement the man page names. |
   | Some target versions are older than this Mac, so the replacement may be missing on them | Tell the Admin. Branch on `sw_vers -productVersion`, or keep the old tool with a comment that names the replacement. |
   | This Mac is older than the target versions | Tell the Admin that you couldn't check the newer releases' man pages. |

3. **Report** which tools you checked, and each one you replaced and why.
