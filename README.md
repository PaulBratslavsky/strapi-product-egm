# Strapi Product Builder — EGM edition

> **Experimental.** A test of Google's [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) (EGM) applied to Strapi's `strapi-product-builder` skill. Lessons from real runs go back into the builder.

Turn a product idea into a build-ready spec for a **Strapi v5** project, and have it stress-tested by reviewers who have never seen your conversation, before any code is written.

The interview is Strapi's `strapi-product-builder`: business value first, then users, requirements, tech decisions, a Strapi technical spec, and a self-contained build spec (`01-product.md` … `06-build-spec.md`). This plugin adds EGM's reviews at three checkpoints.

## How it works

| Role | Who | Job |
|---|---|---|
| **Elephant** | The main Claude session | Interviews you, writes the six files, and resolves review findings. It remembers the whole conversation. |
| **Goldfish** | Fresh subagents | Review the files with no chat history, against a written standard. They can't fill gaps from memory, so they find them. |
| **You** | The owner | Decide trade-offs and approve each stage. |

| Checkpoint | After | Reviews | Reviewers |
|---|---|---|---|
| **A — Concept** | Stage 3 | Product, users, requirements | EGM zoom-out, design critic, and comprehension, plus a skeptical-customer lens |
| **B — Design** | Stage 5 | Tech decisions and Strapi spec | EGM zoom-out and design critic, plus a Strapi fact-checker |
| **C — Build readiness** | Stage 6 | The build spec, on its own | EGM implementation readiness and comprehension, plus the Strapi fact-checker |

Checkpoint C is the important one. The build spec promises that a fresh coding agent can build from it alone, and reviewer C is that fresh agent.

### Existing apps

It also works on a Strapi app that already exists — whether or not it was planned with this tool:

| Step | What happens | Checked by |
|---|---|---|
| Reconstruct | Claude asks a few questions, then writes the design docs **as built**, from the code, citing a file for every claim | **R** — EGM's codebase-details reviewer checks the docs against the code |
| Review | The design and the code are reviewed against the Strapi standards | **B** — EGM design critic and zoom-out, plus a Strapi code auditor (traps with file:line evidence) and the fact-checker |
| Plan the change | You pick which findings to fix; Claude writes a change spec with files, data steps, callers, tests, and rollback | **C** — EGM implementation readiness and codebase-details, plus the fact-checker |
| Implement | Only if you say go: on a new branch, one commit per milestone, never pushed | — |

## Install (Claude Code)

**First, check for the `claude` command:** run `claude --version`. If it's not found, install Claude Code's command-line tool (macOS, Linux, WSL), then open a new terminal:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Windows and other options: [Claude Code setup](https://code.claude.com/docs/en/setup).

**For you, in every project:**

```bash
claude plugin install strapi-product-egm --marketplace PaulBratslavsky/strapi-product-egm
```

That installs this plugin and Google's EGM plugin with it. This repo's `.claude-plugin/marketplace.json` lists EGM as a pointer to Google's repo, so EGM is downloaded straight from `google/elephant-goldfish-model`; nothing of Google's is copied here.

**For one project, shared with your team:** from the project's root folder, run both commands:

```bash
claude plugin marketplace add PaulBratslavsky/strapi-product-egm --scope project
claude plugin install strapi-product-egm@strapi-product-egm --scope project
```

You need both. Adding `--scope project` to the one-command install records the plugin in the project, but this repo's address only in *your* settings, so a teammate's Claude Code wouldn't know where to download it from.

Then commit `.claude/settings.json`: it records the plugin and where it comes from, in the repo. Teammates run the same two commands in their clone, and the file doesn't change. (Tested with Claude Code 2.1.312, both with an empty config and with the plugin already installed for the user. Whether Claude Code also offers the install when a teammate opens the project: not verified.)

Then start a new session in that folder (or run `/reload-plugins` in an open one).

**In the Claude desktop app:** open the project's root folder in the Code tab and paste:

```text
Install the strapi-product-egm plugin for this project only.

First, tell me this folder's full path and wait for me to confirm it's the project's own folder. Then, from that folder, run:

claude plugin marketplace add PaulBratslavsky/strapi-product-egm --scope project
claude plugin install strapi-product-egm@strapi-product-egm --scope project

If `claude` isn't found, stop and tell me. If a command is blocked, don't retry it or look for another way: give me that command and any after it to paste into the Terminal panel. Afterwards, check that .claude/settings.json lists the strapi-product-egm marketplace and plugin.
```

Then start a new session in that folder, and commit `.claude/settings.json`.

- **Use the project's own folder,** not a temporary or hand-off folder: project settings live in that folder and go when it's deleted.
- **Auto mode may block the first command.** Auto mode lets Claude run commands without asking you, behind a safety check that can stop some of them. In the one case seen so far, the first command was blocked once and allowed once (cause unknown). If it's blocked, paste the command into the Terminal panel yourself.

**Already installed EGM from Google's own marketplace (`egm@egm`)?** Keep it — it works. If you'd rather have a single copy, install this repo's listing first, then remove Google's:

```bash
claude plugin install egm@strapi-product-egm
claude plugin uninstall egm@egm
```

(In that order: updating this plugin doesn't add EGM by itself, so removing `egm@egm` first would leave you without EGM.)

**Update later:** `claude plugin marketplace update strapi-product-egm`, then `claude plugin update strapi-product-egm@strapi-product-egm` (for a project install, run both from the project's folder and add `--scope project` to the second).

**Recommended:** connect the Strapi docs MCP server in Claude Code under the name `strapi-docs`, so the fact-checker can query the official docs directly. Under any other name (for example a claude.ai connector), the fact-checker doesn't see it and falls back to fetching https://docs.strapi.io.

## Use

- Start a plan: `/strapi-product-egm:strapi-product-egm`, or ask *"Plan my Strapi product with EGM reviews."*
- Review files you already have: *"Run strapi-product-egm goldfish reviews on ./my-product"*. The skill runs the checkpoints that match the files present.
- Review and improve an existing app: see [Review an existing app](#review-an-existing-app) below.
- Try it on the bundled example. From a clone of this repo, copy it out first, so the reviews don't write into the plugin:

  ```bash
  cp -R skills/strapi-product-egm/builder/examples/trailhead ~/trailhead-review
  ```

  Then, in a session in `~/trailhead-review`, ask *"Run strapi-product-egm goldfish reviews on this folder"*. Expect plenty of findings: the example was written before these standards existed. See [`docs/field-notes/`](docs/field-notes/) for a first run.

### Review an existing app

Built for Strapi v5 apps in a git repo.

1. **Install the plugin, if you haven't.** Use the project install under [Install (Claude Code)](#install-claude-code). In the Claude desktop app, use the install prompt from that section instead. Run it in the app repo's root folder (the git root, also for a monorepo). The project install adds `.claude/settings.json` to the repo, so your team gets the same setup. Skip this step if the plugin is already installed for you in every project.
2. **Start a new session in the same folder.** A plugin installed during a session doesn't load until you start a new one (or run `/reload-plugins`). In the desktop app, open the folder again in the Code tab; in a terminal, `cd` to it and run `claude`.
3. **Fill in the angle brackets and paste:**

   ```text
   Use the strapi-product-egm skill to review this existing Strapi app and plan fixes (existing-app mode).

   What I know so far (use it to draft your interview answers, then confirm them with me):
   - What I want out of this round: <e.g. a general health check, "auth feels fragile", "add team accounts">
   - Live constraints: <in production with real users and data? where it's hosted? or "local only, no real data">
   - Must not change: <public URLs, a mobile app using the API, integrations, or "nothing in particular">

   Take it through checkpoint C (the reviewed change spec), then stop. Don't change any app code until I say go.
   ```

What happens next:

1. The skill reads the code and asks a few short questions, one at a time.
2. It writes "as built" design docs (`01`–`05`) in `docs/designs/<app-name>/` and has a reviewer check them against the code (`reviews/R-reconstruction-review.md`). It may ask about things the code can't show, such as permissions set in the admin panel, or hosting.
3. It runs the design review (`reviews/B-design-review.md`), and you pick which findings to fix.
4. It writes a change spec (`06-change-spec.md`) and has it reviewed (`reviews/C-change-readiness-review.md`).

Along the way it asks you to decide anything a reviewer can't settle.

**Only want the findings?** Replace the prompt's last paragraph with: *"Stop after the design review (checkpoint B) and give me the reports."*

**When you're ready to implement,** reply in the same session: *"Go: implement the change spec."* Before you do:

- Commit your changes, including the new `docs/designs/` files (the skill needs them, so don't stash them). If the working tree isn't clean, the skill stops and asks.
- Expect it to ask whether your local `.env` points at any production service (database, payments, email, storage, a paid API). It never reads `.env`, so it needs your answer.
- It works on a new git branch, runs its checks against a scratch database, and never pushes.

Until you say go, the skill changes no app code. It only adds the docs under `docs/designs/<app-name>/`.

**If the skill doesn't start** (Claude doesn't mention strapi-product-egm, or starts reviewing without asking you anything), start again with `/strapi-product-egm:strapi-product-egm` at the front of the prompt.

(This prompt follows the skill's existing-app steps but hasn't yet been run from start to finish.)

## What you get

```
<product-name>/
├── 01-product.md … 06-build-spec.md   # the plan; 06 is the build spec for your coding agent
└── reviews/
    ├── standards/                     # the standards the reviewers applied
    ├── A-concept-review.md
    ├── B-design-review.md
    ├── C-build-readiness-review.md
    └── review-log.md                  # what each checkpoint caught, and numbered lessons (L1, L2, …)
```

## It learns from its runs

Every run ends by writing **lessons**: rules the skill should have told it, each with the evidence that proved it (a reviewer finding, a failed check, a wrong claim). They go in the run's `review-log.md`.

- **Same project:** the next run reads those lessons at the start and applies them straight away.
- **Everyone:** ask *"update strapi-product-egm with these lessons"*. Claude works on a clone of this repo, never the installed copy, and does four things:
  1. sorts the lessons into apply, merge, hold, upstream (builder) or reject;
  2. edits the standards and references;
  3. has a fresh reviewer check that the new rules are clear and don't conflict;
  4. asks you before it pushes.

  Then `claude plugin update` brings the new version to every machine.

Details: [`references/learning-loop.md`](skills/strapi-product-egm/references/learning-loop.md). Example: [`docs/field-notes/2026-10-27-epic-next-implementation.md`](docs/field-notes/2026-10-27-epic-next-implementation.md).

## Other agents

For Cursor, Codex and other agents, use the [skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add PaulBratslavsky/strapi-product-egm
```

This installs the skill folder without the plugin's agents. The skill then sets up EGM where it can (Claude Code, Cowork, Codex) and falls back to general-purpose reviewers or a "paste it into a new chat" review elsewhere. See [`references/egm-setup.md`](skills/strapi-product-egm/references/egm-setup.md).

## Repo layout

```
.claude-plugin/              plugin.json (depends on egm) and marketplace.json
agents/                      Claude Code adapters for the three Strapi lenses
skills/strapi-product-egm/
├── SKILL.md                 the EGM layer: setup, interview rules, checkpoints, resolve
├── standards/               what "good" means at each checkpoint (Strapi-specific)
├── lenses/                  Strapi reviewer roles (skeptical customer, fact-checker, code auditor)
├── references/              EGM setup, checkpoint dispatch, resolve protocol, existing-app mode, learning loop
├── templates/               the change-spec template (existing-app mode)
└── builder/                 strapi-product-builder, copied unchanged (see SOURCE.md)
scripts/sync-builder.sh      re-copies the builder from a strapi/skills checkout
docs/field-notes/            findings and lessons from real runs
```

## Keeping it current

- **Builder:** `scripts/sync-builder.sh /path/to/strapi-skills-checkout` copies the latest `strapi-product-builder` and records the commit in `builder/SOURCE.md`.
- **Lessons:** see "It learns from its runs" above.
- **EGM:** `claude plugin update egm@strapi-product-egm` (for a project install, from the project's folder with `--scope project`). EGM is pre-1.0, so agent names may change; this plugin was written against EGM v0.1.0.

## Credits

- [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) by Google (Apache-2.0): the method, the `egm:` reviewer agents, and the resolve labels. This plugin depends on EGM and doesn't copy its files.
- [`strapi-product-builder`](https://github.com/strapi/skills/tree/main/skills/in-progress/strapi-product-builder) from Strapi's skills repo: the interview, templates, and Strapi references in `builder/`.
