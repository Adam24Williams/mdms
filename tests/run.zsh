#!/bin/zsh
# Runs every tests/<name>/test.zsh. Exit status is non-zero if any suite fails.
# Suites exercise bundled Skill scripts against fixtures and need macOS tools (plutil, PlistBuddy).
emulate -L zsh

failed=0
for t in ${0:A:h}/*/test.zsh(N); do
  print -r -- "== ${t:h:t}"
  zsh "$t" || (( failed++ ))
done
(( failed == 0 )) && print "all suites passed" || { print "$failed suite(s) failed"; exit 1 }
