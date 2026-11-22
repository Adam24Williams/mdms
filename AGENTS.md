# mdms

A plugin marketplace of Agent Skills for admins running Jamf Pro and Fleet.

- **Vocabulary:** [GLOSSARY.md](GLOSSARY.md). Use its terms in Skills, docs and commits.
- **Decisions:** [docs/design.md](docs/design.md) and [docs/adr/](docs/adr/). Read the relevant ADR before changing scope, safety, Platform access or distribution.
- **Adding or changing a Skill:** [CONTRIBUTING.md](CONTRIBUTING.md). Evals come first, and a Skill ships only if it fixes a baseline failure ([ADR 0004](docs/adr/0004-baseline-gate.md)).
- **Writing or running evals** (case format and its limits): [docs/evals.md](docs/evals.md).
- **Before committing:** enable the hook once per clone with `git config core.hooksPath .githooks`. It runs `scripts/check-skills.mjs`, `claude plugin validate` and `tests/run.zsh`.
