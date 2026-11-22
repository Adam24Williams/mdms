#!/usr/bin/env node
// Enforces this repo's Skill rules (see CONTRIBUTING.md). No dependencies.
// Errors fail the run; a stale verified-on date only warns.
import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";

const ALLOWED_KEYS = new Set(["name", "description", "license", "compatibility", "metadata", "allowed-tools"]);
const PREFIX = { "apple-shared": "apple-", "jamf-pro": "jamf-pro-", fleet: "fleet-" };
const STALE_DAYS = 183;
// ADR 0002: Terraform Skills pre-approve only commands that never contact the Platform.
const TF_SAFE = /^(terraform|tofu) (fmt|validate|init -backend=false)\b/;
// ADR 0003: action types that issue a Destructive Command. See docs/research/terraform-providers.md.
const DESTRUCTIVE_ACTION = /^\s*action\s+"(jamfplatform_device_erase|jamfplatform_device_unmanage|jamfplatform_pro_lock_device|jamfplatform_pro_enable_lost_mode|jamfplatform_pro_clear_passcode|jamfplatform_pro_delete_user)"/gm;
const HCL_FILE = /\.(tf|tftpl|hcl|md)$/;
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
  let block = false; // inside a `>` or `|` block scalar
  for (const line of m[1].split(/\r?\n/)) {
    const top = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (top) {
      current = top[1];
      block = /^[>|][+-]?$/.test(top[2].trim());
      keys[current] = block ? "" : top[2].trim().replace(/^["']|["']$/g, "");
      continue;
    }
    if (block) { keys[current] = (keys[current] + " " + line.trim()).trim(); continue; }
    const item = line.match(/^\s*-\s+(.*)$/); // YAML list item, e.g. under allowed-tools
    if (item && current && current !== "metadata") {
      keys[current] = (keys[current] + " " + item[1].trim().replace(/^["']|["']$/g, "")).trim();
      continue;
    }
    const child = line.match(/^\s+([A-Za-z0-9_-]+):\s*(.*)$/);
    if (child && current === "metadata") metadata[child[1]] = child[2].trim().replace(/^["']|["']$/g, "");
  }
  return { keys, metadata };
}

// Every file under dir, recursively.
function walk(dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    e.isDirectory() ? walk(join(dir, e.name)) : [join(dir, e.name)]);
}

// Tool entries in an `allowed-tools` string, e.g. "Read Bash(terraform fmt:*)".
const toolEntries = (s) => s.match(/[^\s,()]+(\([^)]*\))?/g) ?? [];

function checkTerraform(skill, dir, file, keys) {
  const terraformSkill = skill.includes("-terraform-");
  for (const entry of toolEntries(keys["allowed-tools"] ?? "")) {
    const bash = entry.match(/^Bash(?:\((.*)\))?$/);
    if (!bash) continue;
    const cmd = (bash[1] ?? "").trim();
    if (terraformSkill && (cmd === "" || cmd === "*")) {
      error(file, `allowed-tools pre-approves all of Bash; Terraform Skills may pre-approve only fmt, validate and init -backend=false (ADR 0002)`);
    } else if (/\b(terraform|tofu)\b/.test(cmd) && !TF_SAFE.test(cmd)) {
      error(file, `allowed-tools pre-approves "${entry}"; only fmt, validate and init -backend=false may be pre-approved (ADR 0002)`);
    }
  }
  for (const f of walk(dir).filter((f) => HCL_FILE.test(f))) {
    for (const m of readFileSync(f, "utf8").matchAll(DESTRUCTIVE_ACTION))
      error(f, `declares action "${m[1]}", which sends a Destructive Command (ADR 0003)`);
  }
}

const root = process.argv[2] ?? "plugins";
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
    else {
      if (!/^Use when\b/.test(keys.description)) error(file, 'description must start with "Use when" and state only when to use the Skill');
      if (keys.description.length > 1024) error(file, `description is ${keys.description.length} characters; the limit is 1024`);
    }
    if (!metadata["verified-against"]) error(file, "metadata.verified-against is required");
    checkTerraform(skill, dir, file, keys);

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
