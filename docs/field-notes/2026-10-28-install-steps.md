# Field note: install steps on a second computer (2026-10-28)

The owner installed this plugin for one project (matt-finder) on a second computer, from the Claude desktop app in auto mode, using a prompt the Elephant wrote. The first attempt was blocked; a second session installed it, but into a hand-off folder rather than the project. Testing the install steps with an empty Claude Code config then showed the README's team-install line had been wrong since it was written.

All tests: Claude Code 2.1.312, macOS, with `HOME` and `CLAUDE_CONFIG_DIR` set to a temporary folder to stand in for a computer that has never seen this plugin.

| Test | Result |
|---|---|
| `claude plugin install strapi-product-egm --marketplace PaulBratslavsky/strapi-product-egm --scope project` | Plugin enabled in the project's `.claude/settings.json`; plugin source (`extraKnownMarketplaces`) written to the **user's** settings |
| A teammate with only that project file runs `claude plugin install strapi-product-egm@strapi-product-egm --scope project` | Fails: `not found in marketplace` |
| `claude plugin marketplace add … --scope project`, then `claude plugin install strapi-product-egm@strapi-product-egm --scope project` | Both entries in the project's settings; EGM installed as a dependency |
| The same two commands on a computer where the plugin is already installed for the user (the maintainer's own config, not an empty one) | `marketplace add` reports "already on disk — declared in project settings"; both entries in the project's settings |
| A teammate runs the same two commands in a clone | Installs; the settings file is unchanged |
| The same two commands with `egm@strapi-product-egm` | Works |
| `claude plugin update strapi-product-egm@strapi-product-egm --scope project` | Works |

## Lessons

### L1 — For a team install, add the plugin source at project scope too: `marketplace add … --scope project`, then `install … --scope project`
- **Seen:** README and `SKILL.md` install steps, checked after the matt-finder setup, 2026-10-28
- **Evidence:** The first two rows of the table above. The old line ("add `--scope project`") had never been tested; a teammate's copy couldn't download the plugin.
- **Target:** README "Install"; `SKILL.md` Step 0 step 4; `references/egm-setup.md` "Install"
- **Scope:** Claude Code 2.1.312
- **Status:** applied in v0.2.5

### L2 — If auto mode blocks an install command, don't retry it or route around it: give the user the exact command for the Terminal panel
- **Seen:** matt-finder, second computer, setup, 2026-10-28
- **Evidence:** In auto mode, that session was blocked from running `claude plugin marketplace add …`. It stopped and gave the user the commands, which was right, but nothing in the README or the skill said to. In a new session, a prompt naming the exact commands ran unblocked, so the outcome varies and the steps must cover both.
- **Target:** README "In the Claude desktop app"; `SKILL.md` Step 0 step 4; `references/egm-setup.md`
- **Scope:** general (Claude Code auto mode)
- **Status:** applied in v0.2.5

### L3 — Before a project-scope install, check that the folder is the project's own repo
- **Seen:** matt-finder, second computer, setup, 2026-10-28
- **Evidence:** The install that worked went into `~/Desktop/matfinder-handoff`, a hand-off folder due for deletion, not the project's own folder. Project settings go with the folder.
- **Target:** README; `SKILL.md` Step 0 step 4; `references/egm-setup.md`
- **Scope:** general
- **Status:** applied in v0.2.5

### L4 — A check counts only for the setup it ran in: say how yours differed from the user's, or repeat it in a matching one
- **Seen:** this repo's maintenance session, 2026-10-28
- **Evidence:** The Elephant tested the project-install prompt on a computer that already had the plugin source ("already on disk") and handed it over as working. On the owner's second computer (fresh config, auto mode) the first attempt was blocked. Repeating the test with an empty config then found L1.
- **Target:** `SKILL.md` Step 1, "Check before you claim" (Merge: sharpens that rule)
- **Scope:** general
- **Status:** applied in v0.2.5

## Goldfish check of the v0.2.5 edit

One fresh `egm:egm-comprehension` reviewer checked the changed README, `SKILL.md` and `egm-setup.md` against this note, with `learning-loop.md` and `existing-app-mode.md` for conflicts. It found 🔴 1 · 🟡 6 · 🟢 9, plus one bug outside the diff. All were fixed before commit.

- **Blocker:** the new "repeat the check in a matching setup" tip (an empty config) could be read as a way to rerun a command auto mode had just blocked, which the blocked-command rule forbids. A project-scope "test" from the user's folder would even write the blocked change. Fixed: a blocked command is never rerun as a test, and test commands run from a new empty folder.
- **Majors fixed:**
  - The empty-config tip didn't isolate project scope.
  - It also claimed to match the user's setup when it matches only their settings, not their computer or permission mode.
  - It clashed with "read-only until E8". That rule is now scoped to the app; plugin tests in a temporary folder are allowed.
  - The EGM project install writes `.claude/settings.json` before E8. This is now a named exception in `existing-app-mode.md`.
  - Widening "Check before you claim" to every command went beyond the evidence. It's now narrowed to install or setup commands handed over as working, and slash commands are exempt.
  - "Check that it's the project's own folder" gave the agent no way to check. The scope question now writes out the full repo-root path.
- **Minors fixed:**
  - Hand over the blocked command and every one after it, with a fallback if the user won't run them (dispatch option 3).
  - Separate code blocks for each scope.
  - "Their own terminal" instead of only the desktop app's Terminal panel.
  - The README no longer states a cause for the auto-mode block.
  - Project-scope update commands in all four places.
  - The `claude` check now comes first in the README.
  - The desktop prompt confirms the folder, stops if `claude` is missing, and says what the settings file should show.
  - The README says what committing the settings file does.
  - The "already installed for the user" case was added to the table above.
- **Outside the diff:** `checkpoints.md` took EGM's install path from `egm@egm` only. It now accepts `egm@strapi-product-egm` too.

## Also changed (no lesson)

- README: a ready-to-paste prompt for the Claude desktop app, and the official command-line install for `claude: command not found` (from https://code.claude.com/docs/en/setup). No run has hit that error yet.

## Not verified

- Whether Claude Code offers the install when a teammate opens a project whose settings declare it. The CLI alone doesn't install it.
- Why auto mode blocked the first attempt and not the second.
- The desktop prompt in a session that isn't in auto mode.
