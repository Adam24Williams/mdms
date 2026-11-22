#!/bin/zsh
# Fixture tests for the Terraform rules in scripts/check-skills.mjs (ADR 0002, ADR 0003).
# Each fixtures/<case>/ is a stand-in for plugins/.
emulate -L zsh

here=${0:A:h}
repo=${here:h:h}
fx=$here/fixtures
failed=0

# check <name> <case> <expected-exit> <expected output line regex...>
check() {
  local name=$1 case=$2 want=$3; shift 3
  local out rc ok=1 p
  # Unset GITHUB_ACTIONS so CI gets the same plain "ERROR file: msg" lines as a local run.
  out=$(cd $repo && env -u GITHUB_ACTIONS node scripts/check-skills.mjs $fx/$case 2>&1); rc=$?
  [[ $rc == $want ]] || { ok=0; print -r -- "  exit $rc, expected $want" }
  for p in "$@"; do
    print -r -- "$out" | grep -Eq -- "$p" || { ok=0; print -r -- "  missing output: $p" }
  done
  if (( ok )); then print -r -- "ok   $name"
  else print -r -- "FAIL $name"; print -r -- "$out" | sed 's/^/    | /'; (( failed++ )); fi
}

check "offline commands and a restart action pass" safe 0 \
  '^check-skills: 0 error\(s\)'

check "apply and blanket terraform are rejected" live-commands 1 \
  'pre-approves "Bash\(terraform apply:\*\)"' \
  'pre-approves "Bash\(terraform:\*\)"' \
  '^check-skills: 2 error\(s\)'

check "a Terraform Skill may not pre-approve all of Bash" bare-bash 1 \
  'pre-approves all of Bash' '^check-skills: 1 error\(s\)'

check "any Skill pre-approving tofu plan is rejected" other-skill-plan 1 \
  'pre-approves "Bash\(tofu plan:\*\)"' '^check-skills: 1 error\(s\)'

check "YAML-list allowed-tools and compound commands are checked" list-form 1 \
  'pre-approves "Bash\(cd infra && terraform apply:\*\)"' '^check-skills: 1 error\(s\)'

check "destructive actions in .tf files and hcl blocks are rejected" destructive-action 1 \
  'erase\.tf: declares action "jamfplatform_device_erase"' \
  'SKILL\.md: declares action "jamfplatform_pro_enable_lost_mode"' \
  'erase\.tf: declares action "jamfplatform_pro_delete_user"' \
  '^check-skills: 3 error\(s\)'

(( failed == 0 ))
