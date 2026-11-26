---
name: fleet-capabilities
description: Use when an Admin asks whether Fleet can do something, whether a Fleet feature is coming or has been requested, or about known Fleet bugs, or is planning a Fleet change that depends on what Fleet supports.
license: MIT
metadata:
  verified-against: "Fleet 4.96"
  verified-on: "2026-11-26"
---

# Fleet capabilities

Fleet ships a release every week or two, and its public issue tracker holds what is scheduled, what Admins have asked for, and the bugs that are still open. What you remember about Fleet is older than the Admin's Instance. Fleet's docs say only what ships today. **Before you answer, check the fleetdm/fleet repo's issues as well as the docs**, even when the docs already answer the question.

This is a Read Skill: never open, comment on or react to an issue, and never change a Fleet Instance.

## Requirements

- `gh`, signed in (`gh auth status`). `gh` refuses every command when it isn't signed in. If `gh` is missing, isn't signed in, hits a rate limit (HTTP 403 or 429), or a `gh` or `curl` call is denied, use WebFetch as in [Without gh](#without-gh). WebFetch is the supported route here, not a workaround, so don't answer from memory instead.
- No Fleet credentials.

## Where each answer lives

| Question | Where to look |
|---|---|
| Latest Fleet release | Tags that start with `fleet-v`. The repo also tags `fleetd-v*` (fleetd, Fleet's host agent), Fleet Desktop and osquery releases; ignore those. |
| Shipped, and in which version | `CHANGELOG.md` **at the latest `fleet-v` tag**, which lists every release under `## Fleet X.Y.Z` headings, and that release's notes. `CHANGELOG.md` on `main` can lag a release behind. It's about 700 KB, so grep it; never read it whole. |
| How a shipped feature works | fleetdm.com docs and guides, or `docs/` at the release tag. `docs/` on `main` describes unreleased behaviour. |
| Merged but not released | Files in `changes/` on `main`, one per change. |
| Scheduled | An open issue with a version milestone (`X.Y.0` for Fleet, `fleetd-vX.Y.0` for fleetd; milestones can name a major version that hasn't shipped yet), usually labelled `story`. The milestone's due date is a plan and can slip. |
| Requested only | An open issue with no milestone that isn't a `bug`, often labelled `:product`, `~feature fest`, `customer-*` or `prospect-*`. A request that also has a milestone counts as scheduled. |
| Known bug | An issue labelled `bug` or `~released bug`. Open with a milestone: a fix is scheduled. Open with none: it isn't. Closed with a milestone newer than the Admin's version: fixed in that release, so it still affects them until they upgrade. |

## Steps

1. **Pin the Admin's Fleet version.** Use the version the Admin gave, or the Fleet section of the Environment Profile (`.mdms/environment-profile.md`) if the Team Repo has one. Otherwise assume the latest release and say so. Get the latest release this way, not from the top of `gh release list`, which sorts by publish date and puts backported patches first:

   ```zsh
   gh release view -R fleetdm/fleet --json tagName,publishedAt
   ```

2. **Check what ships.** Read the docs or guide for the feature. To find the version that added it, grep the CHANGELOG at the **latest** tag (not the Admin's), keeping the version headings so each hit shows its release:

   ```zsh
   gh api 'repos/fleetdm/fleet/contents/CHANGELOG.md?ref=<latest fleet-v tag>' \
     -H 'Accept: application/vnd.github.raw' | grep -n -i -E '^## Fleet |<keyword>'
   ```

   The nearest `## Fleet X.Y.Z` heading above a hit is the release that added it. For more detail, read that release's notes: `gh release view fleet-vX.Y.Z -R fleetdm/fleet`.

   If it shipped in a version newer than the Admin's, the answer is "not in your version, added in X.Y".

3. **Search the issues, every time.** Run a search for the feature, and a separate one for the objects the Admin's plan touches (for a GitOps change to labels, search "label" as well as "gitops"):

   ```zsh
   gh issue list -R fleetdm/fleet --state open --search '<keywords>' --limit 15 \
     --json number,title,labels,milestone,url \
     --jq '.[] | "#\(.number) [\(.milestone.title // "no milestone")] \(.title) {\([.labels[].name] | join(","))}"'
   ```

   Sort each hit into scheduled, requested or bug using the table above. Open a promising hit (`gh issue view <n> -R fleetdm/fleet`) before you cite it. When no hit is about the feature (an empty result, or hits that are all about something else), search again with synonyms and Fleet's own name for the feature from its docs before you conclude there's nothing.

   When the Admin's version is older than the latest release, or they're planning a change, also search closed bugs: a fix in a release newer than theirs hasn't reached them.

   ```zsh
   gh issue list -R fleetdm/fleet --state closed --label bug --search '<keywords>' --limit 10 \
     --json number,title,milestone --jq '.[] | "#\(.number) [\(.milestone.title // "no milestone")] \(.title)"'
   ```

4. **Check `changes/`** when the feature isn't in a release but might be merged:

   ```zsh
   gh api repos/fleetdm/fleet/contents/changes --jq '.[].name' | grep -i '<keyword>'
   ```

5. **Answer by bucket.** Give the short answer first, then whichever of these apply, each with its issue or release link:
   - **Available in your version** (and the version that added it)
   - **Merged, not released**
   - **Scheduled:** issue, milestone and due date, noting that milestones slip
   - **Requested, not scheduled:** issue, and that the Admin can comment on it with their use case
   - **Known bugs** that affect the plan: issue, whether a fix is scheduled, and a safe way around it

   When planning a change, put a known bug that would break it at the top, ahead of the plan.

## Without gh

Run the same steps with WebFetch on GitHub's public API. It needs no sign-in, but allows only 10 searches a minute and 60 requests an hour, so keep requests few. Read `milestone.title` and `labels[].name` from each issue in the results.

- Issue search: `https://api.github.com/search/issues?q=repo:fleetdm/fleet+is:issue+is:open+<keywords>&per_page=10` (use `is:closed+label:bug` for closed bugs)
- Latest release: `https://api.github.com/repos/fleetdm/fleet/releases/latest`
- One release's notes: `https://api.github.com/repos/fleetdm/fleet/releases/tags/fleet-vX.Y.Z`

WebFetch can't grep the 700 KB CHANGELOG. Read the notes of the releases in question instead, and tell the Admin which releases you checked.
