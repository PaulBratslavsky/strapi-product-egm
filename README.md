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

Two commands:

```bash
claude plugin marketplace add google/elephant-goldfish-model
claude plugin install strapi-product-egm --marketplace PaulBratslavsky/strapi-product-egm
```

The second command adds this repo's marketplace and installs the plugin, and Google's EGM plugin (`egm@egm`) comes with it as a dependency.

**Why the first command is needed:** Claude Code never adds a marketplace on another plugin's behalf, so you add Google's yourself, once. If you skip it, the plugin installs but won't load. Running the first command afterwards fixes that: it installs the missing EGM automatically.

Then start a new session (or run `/reload-plugins` in an open one).

**Update later:** `claude plugin marketplace update strapi-product-egm`, then `claude plugin update strapi-product-egm@strapi-product-egm`.

**Recommended:** connect the Strapi docs MCP server in Claude Code under the name `strapi-docs`, so the fact-checker can query the official docs directly. Under any other name (for example a claude.ai connector), the fact-checker doesn't see it and falls back to fetching https://docs.strapi.io.

## Use

- Start a plan: `/strapi-product-egm:strapi-product-egm`, or ask *"Plan my Strapi product with EGM reviews."*
- Review files you already have: *"Run strapi-product-egm goldfish reviews on ./my-product"*. The skill runs the checkpoints that match the files present.
- Review and improve an existing app: open a session in the app's repo and ask *"Use strapi-product-egm to review this Strapi app and plan fixes."* The docs and reviews go in `docs/designs/<app-name>/`. Nothing in the app changes unless you approve the change spec and say go.
- Try it on the bundled example. From a clone of this repo, copy it out first, so the reviews don't write into the plugin:

  ```bash
  cp -R skills/strapi-product-egm/builder/examples/trailhead ~/trailhead-review
  ```

  Then, in a session in `~/trailhead-review`, ask *"Run strapi-product-egm goldfish reviews on this folder"*. Expect plenty of findings: the example was written before these standards existed. See [`docs/field-notes/`](docs/field-notes/) for a first run.

## What you get

```
<product-name>/
├── 01-product.md … 06-build-spec.md   # the plan; 06 is the build spec for your coding agent
└── reviews/
    ├── standards/                     # the standards the reviewers applied
    ├── A-concept-review.md
    ├── B-design-review.md
    ├── C-build-readiness-review.md
    └── review-log.md                  # what each checkpoint caught, and lessons for the builder
```

## Other agents

`npx skills add PaulBratslavsky/strapi-product-egm` installs the skill folder without the plugin's agents. The skill then sets up EGM where it can (Claude Code, Cowork, Codex) and falls back to general-purpose reviewers or a "paste it into a new chat" review elsewhere. See [`references/egm-setup.md`](skills/strapi-product-egm/references/egm-setup.md).

## Repo layout

```
.claude-plugin/              plugin.json (depends on egm@egm) and marketplace.json
agents/                      Claude Code adapters for the three Strapi lenses
skills/strapi-product-egm/
├── SKILL.md                 the EGM layer: setup, interview rules, checkpoints, resolve
├── standards/               what "good" means at each checkpoint (Strapi-specific)
├── lenses/                  Strapi reviewer roles (skeptical customer, fact-checker, code auditor)
├── references/              EGM setup, checkpoint dispatch, resolve protocol, existing-app mode
├── templates/               the change-spec template (existing-app mode)
└── builder/                 strapi-product-builder, copied unchanged (see SOURCE.md)
scripts/sync-builder.sh      re-copies the builder from a strapi/skills checkout
docs/field-notes/            findings from real runs, and lessons for strapi-product-builder
```

## Keeping it current

- **Builder:** `scripts/sync-builder.sh /path/to/strapi-skills-checkout` copies the latest `strapi-product-builder` and records the commit in `builder/SOURCE.md`.
- **EGM:** `claude plugin update egm@egm`. EGM is pre-1.0, so agent names may change; this plugin was written against EGM v0.1.0.

## Credits

- [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) by Google (Apache-2.0): the method, the `egm:` reviewer agents, and the resolve labels. This plugin depends on EGM and doesn't copy its files.
- [`strapi-product-builder`](https://github.com/strapi/skills/tree/main/skills/in-progress/strapi-product-builder) from Strapi's skills repo: the interview, templates, and Strapi references in `builder/`.
