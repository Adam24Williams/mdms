#!/usr/bin/env node
// Summarize a `claude plugin eval` aggregate-result.json: one score line per case,
// then every failing scored grader with its judge explanation and evidence excerpt.
// Usage: node scripts/eval-summary.mjs <aggregate-result.json> [--evidence-chars N]
import { readFileSync } from "node:fs";

const args = process.argv.slice(2);
const file = args.find((a) => !a.startsWith("--"));
const n = args.indexOf("--evidence-chars");
const EVIDENCE = n >= 0 ? Number(args[n + 1]) : 600;
if (!file) { console.error("usage: node scripts/eval-summary.mjs <aggregate-result.json> [--evidence-chars N]"); process.exit(2); }

const r = JSON.parse(readFileSync(file, "utf8"));
const fmt = (x) => (typeof x === "number" ? x.toFixed(2) : "  - ");
const ablation = r.suite?.ablation ?? "none";

console.log(`ablation: ${ablation} · cost $${(r.costUsd ?? 0).toFixed(2)} · ${Math.round(r.durationSeconds ?? 0)}s`);
console.log(`${"CASE".padEnd(32)} WITH  W/OUT Δ`);
for (const c of r.cases) {
  const a = c.aggregates ?? {};
  console.log(`${c.name.padEnd(32)} ${fmt(a.score)}  ${fmt(a.scoreWithout)}  ${a.delta === undefined ? "" : (a.delta >= 0 ? "+" : "") + a.delta.toFixed(2)}`);
}

let failures = 0;
for (const c of r.cases) {
  for (const [arm, runs] of Object.entries(c.arms ?? {})) {
    runs.forEach((run, i) => {
      if (run.error) { failures++; console.log(`\n✗ ${c.name} [${arm} run ${i + 1}] run error: ${run.error}`); }
      for (const g of run.graders ?? []) {
        if (g.passed || g.scored === false) continue;
        failures++;
        console.log(`\n✗ ${c.name} [${arm} run ${i + 1}] ${g.name}: ${g.explanation}`);
        if (g.evidence) console.log("  evidence: " + g.evidence.slice(0, EVIDENCE).replace(/\s+/g, " "));
      }
    });
  }
}
console.log(failures ? `\n${failures} failing grader result(s). Read the evidence before trusting a score.` : "\nNo failing scored graders.");
