# Coding standards

These are for review. They cover judgement calls that no check can make. Mechanical rules live in `scripts/check-skills.mjs`, CI and `.githooks/pre-commit`; a rule that can be checked by a script goes there, not here.

## Skills

- **Earned by evidence.** The PR shows a baseline failure and a positive with/without Δ on that case ([ADR 0004](docs/adr/0004-baseline-gate.md)). Each instruction in SKILL.md traces to an observed failure or to a fact the agent can't know without looking it up. Flag lines that only restate what the model already does by default.
- **Triggers, not steps, in `description`.** The description names situations, symptoms and file types. Flag any description that summarizes the Skill's steps or its output.
- **Ground in current sources.** Facts that change with OS or Platform releases (payload keys, API fields, deprecations) are looked up at run time from the primary source the Skill names. They are not written into the Skill as remembered lists.
- **Positive instructions.** Each step says what to do. A prohibition belongs only where it guards against harm, and even then it sits beside the instruction to follow instead.
- **One home per fact.** A rule appears once, in the Skill, an ADR or the glossary, and everything else links to it. Flag rules that are copied between Skills.
- **Right Plugin.** A Skill that is the same on every Platform is a Shared Skill in `apple-shared`. A Skill that uses one Platform's concepts (smart groups, labels, teams, policies) is a Platform Skill.

## Language

- Use [GLOSSARY.md](GLOSSARY.md) terms in Skills, docs and commit messages, and flag the words it lists under _Avoid_. A new domain term needs a glossary entry in the same PR.

## Safety

- **Write Skills** present a Change Plan (object, change, scope, affected device count) and stop for explicit confirmation before acting. For Fleet, they prefer GitOps over direct API writes.
- **No Destructive Commands**, including through a tool that offers them, such as `jamf-cli` erase or lock ([ADR 0003](docs/adr/0003-no-destructive-commands.md)).
- **Credentials** come from the documented environment variables or the Keychain. Flag any step that writes a secret to disk, prints it, or puts it in a file that will be committed.
- **Jamf Pro access** goes through `jamf-cli` only ([ADR 0002](docs/adr/0002-complement-jamf-cli-skills.md)).

## Bundled scripts

- Errors are reported as `ERROR:` lines and warnings as `WARN:` lines, and the exit status means 0 = clean, 1 = findings or failure, 2 = usage error. That keeps output easy for agents to parse.
- Each script has fixture tests under `tests/<script-name>/`, including at least one case for each class of finding it reports.
