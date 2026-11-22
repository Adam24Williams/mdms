# mdms

Agent skills for device-management admins. Starts with **Jamf Pro** and **Fleet**, Apple devices first.

> Status: early development. No Plugin has shipped a release yet.

## Plugins

| Plugin | What it covers |
|---|---|
| `apple-shared` | Platform-independent Apple skills: configuration profiles, declarations (DDM), management scripts |
| `jamf-pro` | Jamf Pro authoring and design: extension attributes, smart group criteria, policy scope review, API roles |
| `fleet` | Fleet: osquery queries and policies, GitOps YAML, hosts and labels |

For live Jamf Pro operations (audit, backup, bulk changes, migration, reporting), install [`jamf-cli-skills`](https://github.com/Jamf-Concepts/jamf-cli) alongside `jamf-pro`. This repo doesn't duplicate it.

## Install for yourself

```
/plugin marketplace add Adam24Williams/mdms
/plugin install apple-shared@mdms
```

## Install for your team

Commit this to `.claude/settings.json` in your team's repo:

```json
{
  "extraKnownMarketplaces": {
    "mdms": {
      "source": { "source": "github", "repo": "Adam24Williams/mdms" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "apple-shared@mdms": true,
    "jamf-pro@mdms": true,
    "fleet@mdms": true
  }
}
```

Each person trusts the folder when Claude Code asks, then installs once per clone:

```bash
claude plugin install apple-shared@mdms --scope project
```

- **Staying current:** `autoUpdate: true` matters, because auto-update is off by default for third-party marketplaces.
- **Pinning:** to stay on a release, add `"ref": "<tag>"` to the `source` object.
- **Versioning:** each Plugin is versioned independently. See [CHANGELOG.md](CHANGELOG.md).

Copying skills into `.claude/skills/` works but isn't supported, because the copies never update.

## Credentials

Skills that read from a Platform use environment variables and never write credentials to disk:

| Platform | Variables |
|---|---|
| Jamf Pro (via `jamf-cli`) | `JAMF_URL`, `JAMF_CLIENT_ID`, `JAMF_CLIENT_SECRET`, or a `jamf-cli` profile stored in the Keychain |
| Fleet | `FLEET_URL`, `FLEET_API_TOKEN` |

Each skill lists the minimum API privileges it needs. Create a dedicated, least-privilege API client for it.

## Safety

- Skills that change a live Platform always show a **Change Plan** and wait for your confirmation.
- No skill ever erases, locks or unmanages devices ([ADR 0003](docs/adr/0003-no-destructive-commands.md)).

## Project docs

- [Design](docs/design.md)
- [Glossary](GLOSSARY.md)
- [Decisions](docs/adr/)
- [Contributing](CONTRIBUTING.md)

## License

[MIT](LICENSE)
