# Resolving goldfish findings

Adapted from EGM's `egm-resolve` skill (v0.1.0). Run it here, in the main conversation: you remember why each decision was made, and the reviewers don't.

## 1. Label every finding

| Label | Use when | What happens |
|---|---|---|
| **PROPOSE FIX** | The finding is valid. | Write the exact change: file, section, replacement text. |
| **CONTEST** | The finding is wrong, and you can point to evidence the reviewer could have read — a line in a target file or the standard. | No change. Quote the evidence. |
| **ESCALATE** | It looks wrong, but the evidence is outside what the reviewer could read — something the user said, a team convention, a business fact. | No change yet. The user decides. |
| **DECLINE** | A nit that isn't worth changing. | Recorded only. |

Rules:

- **A contest must be checkable.** "This was intentional" is not evidence. If you can't cite something the reviewer could read, use ESCALATE or PROPOSE FIX.
- **Don't add context only to satisfy a reviewer.** Add it when a human reader needs it. If only a zero-context reviewer would need it, ESCALATE.
- **Checkpoint C is the exception.** The coding agent that will build from `06-build-spec.md` is a zero-context reader, so anything reviewer C needs, the spec needs.
- **Never contest a comprehension gap.** If a fresh reader couldn't follow it, the document is missing something.
- **Don't change a severity.** If you think a Blocker is a Nit, CONTEST it and say why.
- **You wrote these files.** Wanting to contest a finding is not evidence that the reviewer is wrong.
- **Fact-checker vs. builder cookbook.** Some entries in `builder/references/strapi-build-cookbook.md` were verified by testing and aren't in the official docs. If the fact-checker flags something the cookbook marks "verified on v5.x", ESCALATE with both sources — Strapi may have changed, and the cookbook may need updating.

## 2. Update the report

Fill in the **Resolution** line of every finding in the checkpoint report:

```markdown
- **Resolution:** PROPOSE FIX — <one-line reason>
  - **Edit:** 05-tech-requirements.md › Permissions & roles — <exact change>
```

## 3. Ask once, then wait

Send one chat message:

1. **Escalations first** — one line each, with the question the user needs to answer.
2. **Counts** — how many of each label.
3. **One question** with these answers:
   - **Apply all proposed fixes** — apply every PROPOSE FIX, plus any escalation the user answered with a change.
   - **Walk me through them** — one finding per turn: show the finding, its label, and the edit; ask accept, skip, or discuss. Edit nothing until every finding is decided, then apply the accepted ones together.
   - **No changes** — continue without editing.

The user can also answer in their own words. Then stop and wait for them.

## 4. After applying

- **Ripple check.** If you changed an earlier stage file, ask whether later files need updating (the builder's "revise an earlier stage" protocol). Don't change them silently.
- **Re-run, at most once.** Offer to re-run the checkpoint only if a Blocker was fixed; the re-run writes `<X>-<name>-review-rerun.md`. After one re-run, record anything still open as an accepted trade-off. At checkpoint C, list open Blockers and Majors under "Open questions / parked items" in `06-build-spec.md`.
- **Log it.** Append an entry to `<product>/reviews/review-log.md`.

## 5. Review-log entry

```markdown
## Checkpoint <X> — <YYYY-MM-DD>

- **EGM:** v<version> · **Reviewers:** <list> · **Dispatch option:** <1–4> · **Re-run:** yes/no
- **Findings:** 🔴 <n> · 🟡 <n> · 🟢 <n> → fixed <n> · contested <n> · escalated <n> · declined <n>
- **Lessons for strapi-product-builder** (from accepted Blockers and Majors only):
  - <the interview question, template section, standard line, or cookbook entry that would have prevented it>
- **Reviewer quality:** <findings that were wrong or noise, and which lens produced them>
```

The last two bullets are the point of this experiment. Be specific: "Stage 3 should ask who edits each content type — B found three types with no author" is useful; "improve requirements" is not.
