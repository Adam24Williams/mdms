# The Environment Profile is a committed file, gated on a Platform Skill

Skills guess at facts about an Admin's environment, such as the Jamf Pro version, Jamf Cloud or on-prem, `jamfpro` or `jamfplatform`, Fleet Free or Premium, and minimum OS versions. We record those facts in an Environment Profile, Markdown at `.mdms/environment-profile.md` in the Team Repo, which a Setup Interview Skill in each Plugin writes and other Skills read when they need a fact.

We don't build the Setup Interview yet. It ships with the first Platform Skill whose baseline fails because an environment fact is missing, and that Skill's evals are the gate. The only Skill that exists today, `apple-configuration-profiles`, fails only on knowledge newer than the model's training, which a profile can't fix. `claude plugin eval` runs a single prompt with no simulated Admin replies, so the interview itself can't be measured, only the Skills that read what it records.

## Considered Options

- **Team Repo `CLAUDE.md`/`AGENTS.md`:** rejected. Every turn would pay context for facts most tasks don't need, the cost [ADR 0004](0004-baseline-gate.md) warns against.
- **Agent memory:** rejected. It is per Admin, so each Admin on the team would end up with different facts.
- **A template with no Skill:** rejected. The Setup Interview's value is detecting facts so the Admin answers only what it can't find.
- **One cross-Platform Skill in `apple-shared`:** rejected. It would put Platform concepts in a Shared Skill ([ADR 0001](0001-platform-skills-over-neutral-abstraction.md)) and make Fleet-only teams install `apple-shared`.

## Consequences

- The path and its per-Plugin headings are a contract with the Skills that read the file. Renaming either is a breaking change and needs a major version bump.
- The file is committed and may be public, so it never holds credentials, server URLs, tenant names, device or user identifiers, or device counts.
- Every Skill treats the profile as optional and asks for a missing fact rather than blocking, so it keeps working in claude.ai and in Team Repos that have no profile.
