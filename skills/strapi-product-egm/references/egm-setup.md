# Setting up EGM

EGM is Google's [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) plugin (Apache-2.0). This skill was written against **v0.1.0**. EGM is pre-1.0, so its agent names and file paths may change; if a name in `checkpoints.md` no longer matches, check EGM's README and update this skill.

## Claude Code (reference harness)

**Installed as this repo's plugin?** Then EGM comes with it: the plugin declares `egm` as a dependency, this repo's marketplace lists EGM as a pointer to Google's repo, and `claude plugin install` downloads it from `google/elephant-goldfish-model` at the same scope.

**Check:**

- Your subagent types include `egm:egm-zoom-out`, `egm:egm-design`, `egm:egm-comprehension`, `egm:egm-implementation-readiness` → ready.
- Or run `claude plugin list --json` and look for an `egm@…` entry (`egm@strapi-product-egm`, or `egm@egm` if it was installed from Google's own marketplace).

**Install** (ask the user first — it changes their Claude Code settings):

| For | Command |
|---|---|
| Just this user | `claude plugin install egm --marketplace PaulBratslavsky/strapi-product-egm` |
| Everyone on the project (recorded in `<repo root>/.claude/settings.json`) | From the repo root, both: `claude plugin marketplace add PaulBratslavsky/strapi-product-egm --scope project`, then `claude plugin install egm@strapi-product-egm --scope project` |

- **Don't add `--scope project` to the one-line command.** That puts the plugin source in the user's own settings, so teammates' copies can't download it (seen on Claude Code 2.1.312). Teammates run the same two commands in their clone.
- **Name the folder.** When you ask about scope, write out the full repo-root path (`git rev-parse --show-toplevel`), so the user can spot a temporary or hand-off folder.
- **If a command is blocked** (auto mode may not let you add a new plugin source), don't retry it, and don't run it another way, including as a test in a temporary config. Give the user the blocked command and every one after it, to run in their own terminal (in the desktop app, the Terminal panel) from the repo root. If they'd rather not, continue without EGM: dispatch option 3 in `checkpoints.md`.

Two copies of EGM (one from each marketplace) are harmless — each reviewer loads once. To keep one, install `egm@strapi-product-egm` first, then `claude plugin uninstall egm@egm`; in the other order the user is left with no EGM.

**Load it:** ask the user to type `/reload-plugins` (or `/reload-plugins --force` if it warns). Plugin agents load on reload or on the next session start.

**Permissions:** reviewers read files outside the user's project — EGM's reviewers read their persona and standard files from EGM's install folder, and this plugin's lens agents read `lenses/*.md` from this plugin's install folder. In an interactive session, approve those read prompts. For headless runs, the user adds read rules for both folders (paths from `claude plugin list --json`): EGM's `agents/`, `resources/`, `docs/`, `skills/`, and this plugin's `skills/`. The fact-checker also asks to use the `strapi-docs` MCP server and to fetch web pages. Never turn permission checks off.

**Update:** `claude plugin update egm@strapi-product-egm` (for a project install, from the repo root with `--scope project`), then reload. **Remove:** `claude plugin uninstall egm@strapi-product-egm`.

## Claude Cowork

Install EGM from claude.ai/plugins or the Cowork plugin panel, marketplace `google/elephant-goldfish-model`. In Cowork a subagent can't start subagents; that's fine, because this skill dispatches every reviewer from the main conversation. EGM lists Cowork as installable with open verification gaps, so check on the first checkpoint that each reviewer could read its persona file.

## Codex

```bash
codex plugin marketplace add google/elephant-goldfish-model
codex plugin add egm@egm
```

Codex doesn't register EGM's named agents. Use dispatch option 2 in `checkpoints.md`: a general-purpose subagent reads the persona file from the installed plugin folder. Find that folder in Codex's skill inventory or install metadata, as EGM's `docs/codex.md` describes.

## Cursor and other agents

EGM doesn't ship for these. Skip the install. If the agent can start subagents, use dispatch option 3 (fallback role lines); otherwise use the manual fallback.

## claude.ai web, or Desktop chat without subagents

Nothing to install. Use the manual fallback in `checkpoints.md`: each reviewer runs in a brand-new chat.
