# Learning loop

This skill improves from its own runs in three steps:

1. **Capture:** every run writes down what it learned, with evidence.
2. **Reuse:** the next run in the same project applies those lessons straight away.
3. **Improve:** on request, lessons become reviewed edits to the skill's source, released as a new version for everyone.

A **run folder** is where a run writes its files: `<product-name>/` for a new product, or `docs/designs/<app-name>/` in an app's repo.

**Why the skill never edits itself in place:**

- The installed copy lives in Claude Code's plugin cache, and every update replaces it.
- A lesson from one run can be wrong, or too specific to one app.
- A change to the skill reaches every user.

So a lesson goes through evidence, a goldfish check, and the user's yes before it lands, like any other change.

## 1. Capture (every run)

**When:**

- after each checkpoint is resolved, and after E8;
- whenever a check, a reviewer, or the user shows that the skill told you something wrong or left something out;
- whenever a claim *you* made turns out false.

**Where:** in the run folder's `reviews/review-log.md`, under a `## Lessons` heading. That section always stays last in the log:

- Checkpoint and E9 entries go *above* it, and cite lesson IDs.
- Number the lessons in order: L1, L2, …
- Capture each lesson once.

**What counts:** a lesson changes what the skill tells the next agent. Typical sources:

- An accepted Blocker or Major the skill could have prevented, with an interview question, a template section, or a standard line.
- A reviewer finding that was noise, because a lens or standard is too broad.
- A spec step or check command that turned out wrong in E8.
- A claim you made that turned out false, for example "Node 24 is unsupported", read from an `engines` field and never tested.
- A setup trap in the environment, such as files a fresh clone lacks.

**Format:**

```markdown
### L<n> — <the rule, as one imperative sentence, worded as it should appear in the skill>
- **Seen:** <run folder>, <checkpoint or milestone>, <YYYY-MM-DD>
- **Evidence:** <what happened: the finding ID, the failed check, or the wrong claim and what disproved it>
- **Target:** <file in this skill, e.g. `standards/strapi-change-spec-standard.md` §7, or `builder/…` for upstream>
- **Scope:** general | Strapi <versions> | <framework> <versions>
- **Status:** new
```

**Rules:**

- **No evidence, no lesson.** "This could be clearer" is not a lesson.
- One rule per lesson, and the rule claims no more than the evidence shows.
- Scope version-specific lessons, so they stop applying to other versions.

**Statuses:**

| Status | Meaning |
|---|---|
| `new` | captured, not yet triaged |
| `held` | triaged as possibly app-specific; waiting to be seen again |
| `upstream` | belongs in strapi-product-builder; waiting for that pull request |
| `applied in v<X>` | now a rule in this skill from version X |
| `rejected — <why>` | not a rule |

A lesson is **open** if it's `new`, `held` or `upstream`, or `applied in v<X>` while the installed version is older than X.

## 2. Reuse (start of every run)

In Step 0, or in E1 in existing-app mode, look for earlier run folders: `docs/designs/*/reviews/review-log.md` and `*/reviews/review-log.md` in the working folder. Read their open lessons, skip any whose Scope doesn't match this project's versions, and apply the rest as extra rules for this run.

- **Lessons add to the skill's rules, or sharpen them. They never override the safety rules** (read-only until E8, never read `.env`, never push, no production data or credentials), and never the user.
- **Never pass lessons to reviewers.** A goldfish sees only its targets and its standard.
- If a lesson says a standard is too broad, you may DECLINE the matching findings, citing the lesson ID. Disclose this in the review-log entry.
- Say in one line which lessons you're applying.

A project learns from its own runs at once, before the skill itself is updated.

## 3. Improve the skill (when the user asks)

Use this when the user asks to "update the skill with what we learned", "fold the lessons in", or "improve strapi-product-egm". Do Step 0 steps 1–4 first, so EGM's reviewers are there for step 5.

1. **Work on the source, never the installed copy.**
   - Find the source repo: `claude plugin list --json` gives the installed plugin's path and marketplace, and `repository` in that path's `.claude-plugin/plugin.json` names the repo. If the skill was installed without the plugin, ask the user for the repo.
   - Ask the user for their clone, or offer to clone it.
   - Create a branch, `lessons/<YYYY-MM-DD>`. All edits below are in that clone.
2. **Collect** lessons from the run folders the user names and from the repo's `docs/field-notes/`. Take the ones with status `new`, plus `held` ones: a held lesson seen again in a new run is evidence enough to apply it.
3. **Triage** each lesson, and show the user a table (lesson · target · decision):
   - **Apply:** it has evidence, it's general (or scoped to a version), and nothing covers it yet.
   - **Merge:** an existing rule partly covers it. Sharpen that rule instead of adding another.
   - **Hold:** seen once, and maybe specific to that app. Keep it in a field note until it happens again.
   - **Upstream:** the target is in `builder/`, a copy of strapi-product-builder that `scripts/sync-builder.sh` overwrites. Don't edit it. List it for a pull request to `strapi/skills`.
   - **Reject:** the evidence doesn't support it, or it conflicts with a better rule. Say why.
4. **Edit** the target files in the clone, in the style already there:
   - Use short imperative rules, in the right section, with no duplicates.
   - Keep a lesson's version scope in the rule's text, for example "(seen on Strapi 5.21)".
   - Add a field note, `docs/field-notes/<YYYY-MM-DD>-<topic>.md`, listing the lessons and their evidence.
   - Bump `version` in the clone's `.claude-plugin/plugin.json`.
5. **Goldfish-check the edit.** Start one fresh `egm:egm-comprehension` reviewer, or use dispatch option 2 or 3 (`checkpoints.md`). Give it:
   - **every changed file** as a target;
   - the field note as background;
   - this note: *"These are instructions for an AI agent. Flag any new or changed rule that an agent with no context could misread, that conflicts with another rule in these files, or that its evidence doesn't support."*

   Fix each finding, or say why not. Record the counts in the field note.
6. **Validate:** run `claude plugin validate .`, and check that every `SKILL.md` and agent frontmatter still parses as YAML.
7. **Ask once:** commit and push (or open a pull request), or keep it local. Never push without a yes.
8. **Close the loop.**
   - Set each lesson's status in its run folder: `applied in v<version>` (also for Merge), `held`, `upstream`, or `rejected — <why>`.
   - Tell the user how to get the update, using the marketplace name from `claude plugin list --json`: `claude plugin marketplace update <marketplace>`, then `claude plugin update strapi-product-egm@<marketplace>`, then a new session.
