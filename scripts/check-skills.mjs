#!/usr/bin/env node
// Enforces this repo's Skill rules (see CONTRIBUTING.md). No dependencies.
// Errors fail the run; a stale verified-on date only warns.
import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";

const ALLOWED_KEYS = new Set(["name", "description", "license", "compatibility", "metadata", "allowed-tools"]);
const PREFIX = { "apple-shared": "apple-", "jamf-pro": "jamf-pro-", fleet: "fleet-" };
const STALE_DAYS = 183;
const gh = !!process.env.GITHUB_ACTIONS;

let errors = 0;
let warnings = 0;
const error = (file, msg) => { errors++; console.log(gh ? `::error file=${file}::${msg}` : `ERROR ${file}: ${msg}`); };
const warn = (file, msg) => { warnings++; console.log(gh ? `::warning file=${file}::${msg}` : `WARN  ${file}: ${msg}`); };

// Minimal frontmatter reader: top-level keys, plus one level of `metadata` children.
function frontmatter(text) {
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/);
  if (!m) return null;
  const keys = {};
  const metadata = {};
  let current = null;
  for (const line of m[1].split(/\r?\n/)) {
    const top = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (top) { current = top[1]; keys[current] = top[2].trim(); continue; }
    const child = line.match(/^\s+([A-Za-z0-9_-]+):\s*(.*)$/);
    if (child && current === "metadata") metadata[child[1]] = child[2].trim().replace(/^["']|["']$/g, "");
  }
  return { keys, metadata };
}

const root = "plugins";
for (const plugin of readdirSync(root)) {
  const skillsDir = join(root, plugin, "skills");
  if (!statSync(join(root, plugin)).isDirectory() || !existsSync(skillsDir)) continue;
  const prefix = PREFIX[plugin];
  if (!prefix) { error(join(root, plugin), `unknown plugin; add its name prefix to scripts/check-skills.mjs`); continue; }

  for (const skill of readdirSync(skillsDir)) {
    const dir = join(skillsDir, skill);
    if (!statSync(dir).isDirectory()) continue;
    const file = join(dir, "SKILL.md");
    if (!existsSync(file)) { error(dir, "missing SKILL.md"); continue; }

    const fm = frontmatter(readFileSync(file, "utf8"));
    if (!fm) { error(file, "missing YAML frontmatter"); continue; }
    const { keys, metadata } = fm;

    for (const k of Object.keys(keys)) if (!ALLOWED_KEYS.has(k)) error(file, `frontmatter key "${k}" is not portable; allowed: ${[...ALLOWED_KEYS].join(", ")}`);
    if (keys.name !== skill) error(file, `name "${keys.name ?? ""}" must equal folder name "${skill}"`);
    if (!skill.startsWith(prefix)) error(file, `name must start with "${prefix}"`);
    if (!keys.description) error(file, "description is required");
    if (!metadata["verified-against"]) error(file, "metadata.verified-against is required");

    const on = metadata["verified-on"];
    if (!on || !/^\d{4}-\d{2}-\d{2}$/.test(on) || isNaN(Date.parse(on))) {
      error(file, "metadata.verified-on is required as YYYY-MM-DD");
    } else {
      const days = Math.floor((Date.now() - Date.parse(on)) / 86400000);
      if (days > STALE_DAYS) warn(file, `last verified ${days} days ago (${on}); re-verify against a live Platform`);
    }

    const evals = join(root, plugin, "evals", skill);
    if (!existsSync(evals) || readdirSync(evals).length === 0) error(file, `no eval cases in ${evals}`);
  }
}

console.log(`check-skills: ${errors} error(s), ${warnings} warning(s)`);
process.exit(errors ? 1 : 0);
