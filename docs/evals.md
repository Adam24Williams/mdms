# Evals

Every Skill has eval cases under `plugins/<plugin>/evals/<skill>/<case>/`, run by `claude plugin eval`. That command has no public docs page yet; `claude plugin eval --help` is the source of truth for flags.

## Running

```bash
zsh scripts/eval.zsh <plugin> <skill> baseline   # no-Skill baseline, 2 runs per case
zsh scripts/eval.zsh <plugin> <skill> measure    # with vs. without the Skill, 3 runs per case
```

The script adds this repo's standard flags: `--eval-dir evals/<skill>`, `--allow-tools Bash WebFetch Write Edit`, `--no-publish`, a cost cap and a Sonnet judge. It writes results and the full log under `evals/<skill>/results/` (gitignored), then prints `scripts/eval-summary.mjs` output: a score table plus every failing grader with its evidence.

- **Env vars:** `MAX_COST_USD` (default 10), `JUDGE_MODEL` (default `sonnet`) and `CONCURRENCY` (default 4).
- **Extra args** pass through to `claude plugin eval`, for example `--model haiku`, `--case 'pppc-*'` or `--runs 1`. A flag given twice keeps its last value.
- **First run:** a new plugin checkout asks you to trust it. Non-interactive callers, agents included, pass `--trust-plugin`, but only for code they have read.

## Gotchas

- `--case` matches the case folder name (`pppc-screen-recording`), not a path. `--case 'skill/case'` matches nothing. To scope a run to one Skill, use `--eval-dir`.
- `Bash`, `WebFetch`, `Write` and `Edit` are gated. A case that lists them in `allowed_tools` still can't use them without `--allow-tools`, and `file_exists` graders then fail.
- Run traces are deleted after the run. The evidence in `aggregate-result.json` (what the summary prints) is what survives.
- LLM judges sometimes fail a correct answer. Read the evidence for every failure before you trust a score.
- Cases run in a sandbox working directory. Use relative paths in prompts and graders, never absolute ones or `~/`.

## Case format

```
<case>/
  prompt.md        # frontmatter + the prompt the agent receives
  graders/*.md     # one file per grader
```

`prompt.md` frontmatter: `max_turns`, `timeout_seconds`, `allowed_tools`, `runs` (default 3) and `model`. To give the agent a file to review, put it inline in the prompt.

Grader frontmatter, by `type`:

| `type` | Frontmatter | Body |
|---|---|---|
| `llm` | `focus: last_message` (default), `trace`, `files` or `{source: file, path: <created file>}`; `weight` | Concrete, checkable claims, ending "Pass only if …" |
| `regex` | `target` (same values as `focus`), `match: contains\|not_contains\|count:N`, `flags` | The pattern |
| `file_exists` | `path: <glob>`, `exists: true\|false` | (none) |
| `tool_used` | `tool`, `input_match`, `min`, `max`, `arm: with-only\|both` | (none) |
| `tool_order` | `before`, `after` | (none) |

- `files` is the list of files *created* during the run; files that already existed don't count.
- **Did the Skill fire?** Use `tool_used` with `tool: Skill` and `input_match: <skill-name>`. Leave `arm` unset: under ablation it is reported but not scored.
- **Should-not-trigger case:** use `tool_used` with `tool: Skill`, `input_match: <skill-name>`, `min: 0`, `max: 0` and `arm: both`, plus at least one outcome grader.
