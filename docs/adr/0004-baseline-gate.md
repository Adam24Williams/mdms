# A Skill ships only if it fixes a baseline failure

Every Skill is preceded by eval cases run without it. A Skill is written only when the baseline fails those cases, and it ships only if it raises the score on them (`claude plugin eval --ablation with-without`). We adopted this after the first Skill, `apple-configuration-profiles`: the default model passed 6 of 7 cases with no Skill at all, including well-known gotchas like the Screen Recording restriction. Its one consistent failure was knowledge newer than its training (macOS 27 privacy-key deprecations). A Skill that restates what the model already knows costs context on every turn and adds nothing.

## Consequences

- Roadmap Skills in [design.md](../design.md) are candidates, not commitments. One whose baseline passes is dropped or rewritten against harder cases, and the PR records why.
- The Skills that do ship lean toward grounding in current sources (Apple's schema, Platform release notes) and toward deterministic tools such as linters, rather than general explanations.
