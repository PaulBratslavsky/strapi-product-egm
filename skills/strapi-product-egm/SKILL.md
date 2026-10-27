---
name: strapi-product-egm
description: Plan a Strapi product with Google's Elephant-Goldfish Model (EGM) — a business-value-first planning interview (idea → users → requirements → tech → Strapi spec → build spec) plus fresh-context "goldfish" reviews that stress-test the product brief, the technical design, and the build spec before any code is written. Also reviews an EXISTING Strapi app: reconstructs its design from the code, checks it against Strapi standards, and turns the accepted findings into a reviewed change spec (and, on request, implements it on a branch). Sets up the EGM plugin if it is missing. Use when the user wants an EGM / elephant-goldfish / goldfish-reviewed product plan, asks to "stress-test" or get a "fresh-eyes review" of a Strapi product plan, build spec, or existing Strapi codebase, wants goldfish reviews of existing strapi-product-builder files (01-product.md … 06-build-spec.md), or wants to audit and improve a Strapi app with this method.
---

# Strapi Product Builder — EGM edition

> **Experimental.** This skill tests Google's [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) (EGM) on top of Strapi's `strapi-product-builder` interview. Every run records what the reviews caught in `reviews/review-log.md`, so the lessons can be folded back into the builder.

## The model

| Role | Who | Sees | Job |
|---|---|---|---|
| **Elephant** | You, the main agent | The whole conversation and the builder instructions | Interview the user, write the six stage files, resolve review findings |
| **Goldfish** | Fresh subagents | Only the files you hand them and a written standard | Find what is missing, unclear, wrong, or unnecessary |
| **Owner** | The user | Everything | Decide trade-offs and approve each stage |

Why it works: the agent that wrote a document fills its gaps from memory, so it can't see them. A goldfish has no memory to fill them with, so it trips over every gap — exactly like the coding agent that will later build from the spec.

## How this skill is put together

The interview is Strapi's `strapi-product-builder`, copied unchanged into `builder/` (see `builder/SOURCE.md`). **Read `builder/BUILDER.md` before you start** — it defines the six stages, the output files, the defaults, and the tone. Paths inside it (`references/…`, `templates/…`, `examples/…`) are relative to `builder/`.

This file adds only the EGM layer:

1. **EGM setup** — Step 0.
2. **Elephant rules** and a few stage overrides — Step 1.
3. **Three goldfish checkpoints** with Strapi-specific standards — A after stage 3, B after stage 5, C after stage 6.
4. **A resolve protocol** for findings, and a review log.

Where this file and `BUILDER.md` conflict, this file wins.

## Modes

| Mode | When | Follow |
|---|---|---|
| **New product** (default) | The user has an idea and no code | This file, from Step 0 |
| **Review-only** | The user has planning files (01–06) to check | Step 0, then "Review-only mode" below |
| **Existing app** | The user has a Strapi codebase to review and improve | Step 0 (steps 1–4), then `references/existing-app-mode.md` |

**This skill's folder** is `${CLAUDE_SKILL_DIR}` in Claude Code (elsewhere: the folder that contains this file). Reviewers need absolute paths, so resolve every path you hand them against it. Never write review files or edits inside this folder.

## Files this skill writes

```
<product-name>/
├── 01-product.md … 06-build-spec.md   # the builder's six files (same templates, a few extra sections)
└── reviews/
    ├── standards/                     # copies of the standards the reviewers applied
    ├── A-concept-review.md
    ├── B-design-review.md
    ├── C-build-readiness-review.md
    └── review-log.md                  # one entry per checkpoint: counts, outcomes, lessons
```

In existing-app mode the same files live in the app's repo under `docs/designs/<app-name>/`. There, `04`/`05` describe the code as built, `06` is a change spec (`06-change-spec.md`), and the reviews add `R-reconstruction-review.md` and `C-change-readiness-review.md`.

---

## Step 0 — Preflight and EGM setup

Do this before stage 1, so the reviewers are ready when the first checkpoint comes.

1. **Find out what the user wants.**
   - A new product idea → full run.
   - Existing builder files to review → set up EGM (steps 2–4), then use **Review-only mode** below.
   - The bundled example → first copy `builder/examples/trailhead/` into the user's working directory, and review the copy.
   - An existing Strapi codebase to review or improve → set up EGM (steps 2–4), then follow `references/existing-app-mode.md`.
2. **Check the reviewers** in your list of subagent types:
   - `egm:egm-zoom-out` is there → EGM is ready.
   - `strapi-product-egm:strapi-fact-checker` is there → this plugin's lenses are ready. If it's missing (the skill was installed without the plugin), the lenses run as general-purpose subagents (dispatch option 2 in `references/checkpoints.md`). Nothing to install.

   If EGM is ready, go to step 5.
3. **EGM missing.** Run `claude plugin list --json` and look for `egm@egm`.
   - Listed, but there are no `egm:` agent types → the plugin hasn't loaded in this session. Ask the user to type `/reload-plugins`, and continue when they say it's done.
   - Not listed → ask first. Say in two sentences what EGM is (Google's open-source spec-review method: fresh reviewer agents with no chat history check your documents) and that you'll install its plugin from `github.com/google/elephant-goldfish-model`. Ask one question: install it **just for you** (user scope) or **for everyone on this project** (project scope, recorded in `.claude/settings.json`)? Never install without a yes.
4. **Install** (Claude Code):

   ```bash
   claude plugin marketplace add google/elephant-goldfish-model   # add --scope project for the team option
   claude plugin install egm@egm                                  # add --scope project for the team option
   claude plugin list --json                                      # confirm egm@egm and note its version
   ```

   Then ask the user to type `/reload-plugins` (add `--force` if it warns) so the new agents load into this session, and continue when they say it's done. If the `egm:` agent types still don't appear, use dispatch option 2 for those reviewers.
   Other harnesses (Cowork, Codex, Cursor, claude.ai): follow `references/egm-setup.md`.
5. **Ready.** Note the EGM version (from `claude plugin list --json`) for the review log. Then start the builder's flow: ask for the product name and pick the output mode as `BUILDER.md` describes.

---

## Step 1 — Elephant rules

Apply these on top of the builder's "Tone & pacing" section. They replace it where they conflict.

- **Stress-test, don't cheerlead.** Lead with the weakest point of each answer. Agree only after an idea survives a challenge. Don't call ideas "great", "brilliant", or "perfect". When corrected, don't apologise — state the corrected reasoning.
- **One open question per turn in stages 1–3.** Ask open-ended questions and don't suggest candidate answers while discovering the problem; the user's own words expose their assumptions. (Ask the builder's product-category question the same way.) Offering options is fine for real decisions in stage 4.
- **The owner decides forks.** Where the builder has a default (Strapi v5, PostgreSQL, Strapi Cloud, Users & Permissions, `src/api/<name>` modules), state it. Where it has none (the frontend, a tenancy model), lay out the options — how each works, its trade-offs, and when it fails — and let the user choose. Use the builder's own option lists where it has them, such as its four first-class frontends.
- **A contradiction stops edits.** If a new answer contradicts an earlier decision, don't edit any file in that turn. Name both statements and ask which one wins.
- **Write to the standard.** Before drafting stages 1–3, 4–5, and 6, read the matching file in `standards/`. The reviewers grade against it. Knowing the rubric isn't cheating: a goldfish is useful because it has no memory, not because the rules are secret.
- **Files, not chat.** Never paste a stage file into chat. After writing one, give its path and the 2–3 decisions that matter, then ask the builder's "Does this look right?" question.

### Stage overrides

| Stage | Change to the builder |
|---|---|
| 1 | Ask three extra questions (from the Heilmeier catechism EGM uses): *How do people handle this today, and why does that fall short? What is the riskiest assumption — the one that, if wrong, makes the product pointless? What would you see in the first month that tells you it's working?* Record the answers in `01-product.md` as three extra sections after "The value": **Today's workaround**, **Riskiest assumption**, **Early signal**. |
| End of 3 | Write the anchored hypothesis into `01-product.md` as a **Hypothesis** section (see the gate below). |
| 5 | Add an **Operations (robustness sweep)** section to `05-tech-requirements.md`: one line per sweep item, saying where it's specified in 05, or "N/A — <reason>" if the user declined it. |
| 6 | `06-build-spec.md` never points at another stage file *instead of* giving the content. A background mention is fine only when the content itself is in 06 (this overrides the builder's "reference them as background"). Use the cookbook's full non-interactive scaffold flags — `--non-interactive --skip-cloud --no-example --no-git-init` plus the `--db*` flags; the builder's stage-6 reminder leaves out the middle two. |

---

## The flow

| # | Elephant (you) | Goldfish checkpoint |
|---|---|---|
| 1 | Builder stages 1–3 → `01`, `02`, `03` | |
| 2 | Anchored hypothesis gate | **A — Concept review** of 01–03 |
| 3 | Resolve A | |
| 4 | Builder stages 4–5 and the robustness sweep → `04`, `05` | **B — Design review** of 04–05 |
| 5 | Resolve B | |
| 6 | Builder stage 6 → `06` | **C — Build-readiness review** of 06 |
| 7 | Resolve C, then hand off | |

### Anchored hypothesis gate (end of stage 3)

Write a **Hypothesis** section into `01-product.md`:

> For **<persona from 02>**, who today **<workaround>**, **<product>** lets them **<core loop>** so they **<value>**. The MVP is **<scope from 03>**. The riskiest assumption is **<assumption>**.
>
> - **What's new:** why this works where today's workaround doesn't.
> - **How the MVP tests the riskiest assumption:** what the MVP will show, and how you'll know.

Show the user the hypothesis and ask one question: run the concept review now, or keep refining? Don't start any reviewer before the user says go. The zoom-out reviewer in checkpoint A gets the hypothesis verbatim.

### Checkpoints

Read `references/checkpoints.md` before the first checkpoint. It has the dispatch options, prompt templates, report format, and fallbacks. Summary:

| Checkpoint | Review these | Background only | Reviewers (in parallel) | Standard | Report |
|---|---|---|---|---|---|
| **A** Concept | 01, 02, 03 | — | `egm:egm-zoom-out` (BRAINSTORM mode) · `egm:egm-design` · `egm:egm-comprehension` · `strapi-product-egm:skeptical-customer` | `standards/product-brief-standard.md` | `A-concept-review.md` |
| **B** Design | 04, 05 | 03 (+ the design standard, for zoom-out) | `egm:egm-zoom-out` · `egm:egm-design` · `strapi-product-egm:strapi-fact-checker` | `standards/strapi-design-standard.md` | `B-design-review.md` |
| **C** Build readiness | 06 only | none | `egm:egm-implementation-readiness` · `egm:egm-comprehension` · `strapi-product-egm:strapi-fact-checker` | `standards/strapi-build-spec-standard.md` | `C-build-readiness-review.md` |

When they start: A after the hypothesis gate. B as soon as the user approves 05 (after the sweep). C as soon as the user approves 06. For B and C, say in one line that the review is starting; the user can say "skip".

Rules that matter most:

- **Every reviewer is a new subagent.** Never fork this conversation into a reviewer, and never pass it your notes, summaries, or reasoning. Pass only the paths in the table and the prompt template.
- **C gets 06 alone, on purpose.** The spec promises that a fresh agent can build from it; C is that agent. Don't give C extra context to make it pass — fix the spec instead.
- **One checkpoint at a time.** Run the reviewers inside a checkpoint in parallel, and finish resolving before the next stage.
- **No subagent tool → no same-context review.** A review in this conversation is not a goldfish review. Use the manual fallback in `references/checkpoints.md`.

### Resolve (after each checkpoint)

Follow `references/resolve-protocol.md`. In short:

1. Label each finding **PROPOSE FIX**, **CONTEST** (only with evidence the reviewer could read), **ESCALATE** (needs the user's knowledge), or **DECLINE** (a nit not worth changing). Write the labels into the checkpoint report.
2. In chat, list escalations first, then ask one question: apply all fixes, walk through them one by one, or make no changes.
3. A fix that touches an earlier stage file follows the builder's "revise an earlier stage" protocol — ask before changing downstream files.
4. Re-run a checkpoint at most once.
5. Append an entry to `reviews/review-log.md`.

The builder's **robustness sweep** after stage 5 stays a conversation with the user, because it gathers decisions only the user can make. Checkpoint B then checks the Operations section that records them.

---

## Review-only mode

If the user already has builder files, skip the interview:

1. Do Step 0, steps 1–4. Work on files in the user's working directory, never inside this skill's folder.
2. Run the checkpoints that match the files present — A if 01–03 exist, B if 04–05 exist, C if 06 exists — in that order. Before A, if 01 has no Hypothesis section, draft one from 01–03 and have the user confirm it.
3. Resolve each one. Ask before editing files that weren't written in this session.
4. Write the review log. The lessons are the main output of a review-only run.

Files made by the builder without this skill lack the extra sections (Hypothesis, Operations). Expect the reviewers to flag that, and treat those findings as lessons for the builder.

**Files nobody here owns** (the bundled example, a third party's plan): there's no owner to confirm the hypothesis or answer the resolve gate. Draft the hypothesis for the zoom-out reviewer only, mark it unconfirmed, and don't write it into 01. Label findings as usual, apply no edits unless the user asks, and put the effort into the review log.

## Hand-off (after C is resolved)

- `06-build-spec.md` is the build spec, exactly as in the builder.
- Suggest committing the product folder into the build repo under `docs/designs/<product-name>/` (EGM's convention). After the build, the user can run `/egm:egm-drift-report docs/designs/<product-name>` to compare the spec with the code — for example content types against `apps/cms/src/api/*/content-types/*/schema.json` in the builder's default layout, plus routes and policies.
- For a deeper, generic pass the user can run `/egm:egm-review docs/designs/<product-name>/06-build-spec.md`. (EGM's own skills can only be started by the user, not by this skill.)
- Point the user to `reviews/review-log.md` and its "Lessons for strapi-product-builder".

## Attribution

The method, the `egm:` reviewer agents, and the resolve labels come from Google's [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) (Apache-2.0), written against v0.1.0 (commit `b3a3595`). This skill calls EGM's installed agents rather than copying them. The interview in `builder/` is Strapi's `strapi-product-builder`. The standards and lenses in this folder are original to this skill.
