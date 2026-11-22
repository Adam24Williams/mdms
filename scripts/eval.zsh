#!/bin/zsh
# Run one Skill's eval cases with this repo's standard flags, then summarize the results.
# Usage: zsh scripts/eval.zsh <plugin> <skill> <baseline|measure> [extra `claude plugin eval` args]
#   baseline  no Skill effect measured: --ablation none, 2 runs per case
#   measure   with vs. without the Skill: --ablation with-without, 3 runs per case
# Env: MAX_COST_USD (default 10), JUDGE_MODEL (default sonnet), CONCURRENCY (default 4)
# Extra args pass through, e.g. --model haiku, --case 'pppc-*', --trust-plugin (non-interactive runs).
# See docs/evals.md.

emulate -L zsh
setopt err_exit pipe_fail

(( $# >= 3 )) || { print -u2 "usage: zsh scripts/eval.zsh <plugin> <skill> <baseline|measure> [extra args]"; exit 2 }
plugin=$1 skill=$2 mode=$3; shift 3

repo=${0:A:h:h}
plugin_dir=$repo/plugins/$plugin
[[ -d $plugin_dir/evals/$skill ]] || { print -u2 "no eval cases at plugins/$plugin/evals/$skill"; exit 2 }

case $mode in
  baseline) mode_args=(--ablation none --runs 2) ;;
  measure)  mode_args=(--ablation with-without) ;;
  *) print -u2 "mode must be 'baseline' or 'measure'"; exit 2 ;;
esac

out=$plugin_dir/evals/$skill/results/$(date +%Y%m%d-%H%M%S)-$mode
mkdir -p "$out"
print -r -- "eval: plugins/$plugin/evals/$skill ($mode) -> ${out#$repo/}/eval.log"

if ! claude plugin eval "$plugin_dir" \
  --eval-dir "evals/$skill" \
  --allow-tools Bash WebFetch Write Edit \
  --no-publish \
  --threshold 0 \
  --max-cost-usd "${MAX_COST_USD:-10}" \
  --judge-model "${JUDGE_MODEL:-sonnet}" \
  -j "${CONCURRENCY:-4}" \
  --output-dir "$out" \
  $mode_args "$@" > "$out/eval.log" 2>&1; then
  print -u2 "claude plugin eval failed; last lines of $out/eval.log:"
  tail -15 "$out/eval.log" >&2
  exit 1
fi

node "$repo/scripts/eval-summary.mjs" "$out/aggregate-result.json"
