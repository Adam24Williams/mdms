#!/bin/zsh
# Structural lint for Apple configuration profiles (.mobileconfig).
# Usage: zsh lint-profile.zsh <profile.mobileconfig> [...]
# Checks plist syntax, required payload keys, PayloadUUID/PayloadIdentifier uniqueness
# and format, PayloadScope values, and plain-text secrets. It does not check
# payload-specific keys; check those against Apple's schema (see SKILL.md).
# Exit status: 0 = no errors (warnings allowed), 1 = errors found, 2 = usage error.

emulate -L zsh
setopt pipe_fail

PB=/usr/libexec/PlistBuddy
UUID_RE='^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$'
SECRET_KEYS=(Password PreSharedKey PSK Secret SharedSecret PIN Passcode)

(( $# > 0 )) || { print -u2 "usage: zsh lint-profile.zsh <profile.mobileconfig> [...]"; exit 2 }

total_errors=0

lint_one() {
  local src=$1 file=$1 tmp="" errors=0 warnings=0
  err()  { print -r -- "ERROR: $*"; (( errors++, total_errors++ )) }
  warn() { print -r -- "WARN:  $*"; (( warnings++ )) }
  get()  { $PB -c "Print :$1" "$file" 2>/dev/null }   # prints value; non-zero if key missing

  print -r -- "== $src"
  [[ -r $src ]] || { err "cannot read file"; return 1 }

  if ! plutil -lint -s "$src" >/dev/null 2>&1; then
    # A signed profile is a CMS envelope, not a plist. Decode it and lint the payload.
    tmp=$(mktemp -t lint-profile)
    if security cms -D -i "$src" -o "$tmp" >/dev/null 2>&1 && plutil -lint -s "$tmp" >/dev/null 2>&1; then
      warn "profile is signed; linting the decoded contents. Any edit invalidates the signature, so re-sign after changing it."
      file=$tmp
    else
      rm -f "$tmp"
      err "not a valid property list: $(plutil -lint "$src" 2>&1 | tail -1)"
      return 1
    fi
  fi

  local -A uuid_seen ident_seen
  check_payload() {   # $1 = PlistBuddy key prefix ("" for top level), $2 = label
    local p=$1 label=$2 v
    for k in PayloadType PayloadIdentifier PayloadUUID PayloadVersion; do
      get "${p}$k" >/dev/null || err "$label: missing $k"
    done
    if v=$(get "${p}PayloadVersion"); then
      [[ $v == 1 ]] || warn "$label: PayloadVersion is '$v'; Apple expects 1"
    fi
    if v=$(get "${p}PayloadUUID"); then
      [[ $v =~ $UUID_RE ]] || err "$label: PayloadUUID '$v' is not a UUID (generate one with uuidgen)"
      if [[ -n ${uuid_seen[$v]} ]]; then err "$label: PayloadUUID '$v' duplicates ${uuid_seen[$v]}"
      else uuid_seen[$v]=$label; fi
    fi
    if v=$(get "${p}PayloadIdentifier"); then
      if [[ -n ${ident_seen[$v]} ]]; then err "$label: PayloadIdentifier '$v' duplicates ${ident_seen[$v]}"
      else ident_seen[$v]=$label; fi
    fi
  }

  check_payload "" "profile"
  local v
  if v=$(get PayloadType) && [[ $v != Configuration ]]; then
    err "profile: top-level PayloadType is '$v'; it must be 'Configuration'"
  fi
  get PayloadDisplayName >/dev/null || warn "profile: missing PayloadDisplayName (admins and users see this name)"
  if v=$(get PayloadScope) && [[ $v != System && $v != User ]]; then
    err "profile: PayloadScope '$v' must be 'System' or 'User'"
  fi

  if ! get PayloadContent >/dev/null; then
    err "profile: missing PayloadContent array"
  else
    local i=0 type
    while get "PayloadContent:${i}" >/dev/null; do
      type=$(get "PayloadContent:${i}:PayloadType") || type="?"
      check_payload "PayloadContent:${i}:" "payload ${i} (${type})"
      (( i++ ))
    done
    (( i > 0 )) || warn "profile: PayloadContent is empty"
  fi

  # Plain-text secrets anywhere in the profile.
  local key
  for key in $SECRET_KEYS; do
    if plutil -p "$file" 2>/dev/null | grep -Eq "\"$key\" => \"[^\"]+\""; then
      warn "a '$key' value is stored in plain text. Keep secrets out of files you commit; use your Platform's secret variables or manage this payload only in the Platform."
    fi
  done

  [[ -n $tmp ]] && rm -f "$tmp"
  print -r -- "-- $errors error(s), $warnings warning(s)"
}

for f in "$@"; do lint_one "$f"; done
(( total_errors == 0 ))
