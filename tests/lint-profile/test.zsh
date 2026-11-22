#!/bin/zsh
# Fixture tests for plugins/apple-shared/skills/apple-configuration-profiles/scripts/lint-profile.zsh
emulate -L zsh

here=${0:A:h}
repo=${here:h:h}
lint=$repo/plugins/apple-shared/skills/apple-configuration-profiles/scripts/lint-profile.zsh
fx=$here/fixtures
failed=0

# check <name> <expected-exit> <file...> -- <expected output line regex...>
check() {
  local name=$1 want=$2; shift 2
  local -a files patterns; local seen_sep=0 a
  for a in "$@"; do
    if [[ $a == -- ]]; then seen_sep=1; continue; fi
    (( seen_sep )) && patterns+=("$a") || files+=("$a")
  done
  local out rc
  out=$(zsh "$lint" "${files[@]}" 2>&1); rc=$?
  local ok=1 p
  [[ $rc == $want ]] || { ok=0; print -r -- "  exit $rc, expected $want" }
  for p in $patterns; do
    print -r -- "$out" | grep -Eq -- "$p" || { ok=0; print -r -- "  missing output: $p" }
  done
  if (( ok )); then print -r -- "ok   $name"
  else print -r -- "FAIL $name"; print -r -- "$out" | sed 's/^/    | /'; (( failed++ )); fi
}

check "valid profile passes" 0 $fx/valid.mobileconfig -- \
  '^-- 0 error\(s\), 0 warning\(s\)$'

check "duplicates and plain-text secret" 1 $fx/duplicates-and-secret.mobileconfig -- \
  '^ERROR: payload 1 \(com\.apple\.applicationaccess\): missing PayloadVersion$' \
  "^ERROR: payload 1 .*PayloadUUID '9B2E4F61-3C7A-4D8E-A1B5-6C9D2E7F4A13' duplicates payload 0 \(com\.apple\.wifi\.managed\)$" \
  "^ERROR: payload 1 .*PayloadIdentifier 'com\.example\.baseline\.settings' duplicates payload 0" \
  "^WARN:  a 'Password' value is stored in plain text" \
  '^-- 3 error\(s\), 1 warning\(s\)$'

check "bad top level" 1 $fx/bad-top-level.mobileconfig -- \
  "^ERROR: profile: PayloadUUID 'not-a-uuid' is not a UUID" \
  "^WARN:  profile: PayloadVersion is '2'" \
  "^ERROR: profile: top-level PayloadType is 'com\.apple\.applicationaccess'" \
  "^ERROR: profile: PayloadScope 'Device' must be 'System' or 'User'$" \
  '^ERROR: profile: missing PayloadContent array$'

check "not a plist" 1 $fx/not-a-plist.mobileconfig -- '^ERROR: not a valid property list'

check "unreadable file" 1 $fx/does-not-exist.mobileconfig -- '^ERROR: cannot read file$'

check "any failing file fails the run" 1 $fx/valid.mobileconfig $fx/not-a-plist.mobileconfig -- \
  '^-- 0 error\(s\), 0 warning\(s\)$' '^ERROR: not a valid property list'

# Signed profile: sign the valid fixture with a throwaway self-signed certificate.
if command -v openssl >/dev/null; then
  tmp=$(mktemp -d)
  if openssl req -x509 -newkey rsa:2048 -nodes -keyout $tmp/k.pem -out $tmp/c.pem -days 1 -subj "/CN=lint-test" >/dev/null 2>&1 &&
     openssl smime -sign -signer $tmp/c.pem -inkey $tmp/k.pem -nodetach -outform der \
       -in $fx/valid.mobileconfig -out $tmp/signed.mobileconfig >/dev/null 2>&1; then
    check "signed profile is decoded and linted" 0 $tmp/signed.mobileconfig -- \
      '^WARN:  profile is signed; linting the decoded contents' '^-- 0 error\(s\), 1 warning\(s\)$'
  else
    print "skip signed profile (openssl could not sign)"
  fi
  rm -rf $tmp
else
  print "skip signed profile (no openssl)"
fi

(( failed == 0 ))
