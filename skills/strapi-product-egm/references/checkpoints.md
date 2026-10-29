# Running a goldfish checkpoint

Read this before the first checkpoint. The rosters (who reviews what, against which standard) are the table in `SKILL.md` for new products, and the tables in `existing-app-mode.md` for existing apps.

## 1. Before dispatch

1. **Re-read the target files.** They may have changed since you wrote them.
2. **Copy the standard** for this checkpoint from this skill's `standards/` into `<product>/reviews/standards/` (overwrite an older copy). Reviewers read the copy: it sits inside the user's project, so there's no extra permission prompt, and it records exactly what was applied.
3. **Use absolute paths** for every file you hand a reviewer.

## 2. Dispatch

Start every reviewer for the checkpoint **in one message**, so they run in parallel. Each one is a **new** subagent. Never fork or resume this conversation into a reviewer.

Choose the option **per reviewer** — the first one that works for that reviewer — and record it in the report:

| # | When | How |
|---|---|---|
| 1 | The reviewer's agent type exists (`egm:egm-…` or `strapi-product-egm:…`) | Spawn it by type. These agents are read-only and start without CLAUDE.md. |
| 2 | The persona file can be read, but the type isn't registered (the skill was installed without the plugin, Codex, or plugins not reloaded) | Spawn a general-purpose subagent. First line of its prompt: *"Read `<persona file>` and act as that persona. You are read-only: do not create or edit files."* See the paths below. |
| 3 | No persona file (EGM declined, or a harness EGM doesn't support) | Spawn a general-purpose subagent with the fallback role line below, plus the same prompt. |
| 4 | No subagent tool at all | Manual fallback (section 5). Never review in this conversation. |

**Persona paths for option 2:**

- **This skill's lenses:** `lenses/skeptical-customer.md`, `lenses/strapi-fact-checker.md`, `lenses/strapi-code-auditor.md`, and `lenses/frontend-auditor.md` in this skill's folder.
- **EGM reviewers:** `<EGM root>/agents/` — `zoom_out.md`, `design_critic.md`, `comprehension.md`, `implementation_readiness.md`, `codebase_details.md`. In Claude Code, take `<EGM root>` from the `egm@…` entry in `claude plugin list --json` (`egm@strapi-product-egm`, or `egm@egm` if it was installed from Google's own marketplace). In Codex, use the installed plugin path from Codex's skill inventory or install metadata (see EGM's `docs/codex.md`). Never guess a path.
- EGM personas refer to their standards by relative path, which a general-purpose subagent can't resolve. So for `zoom_out.md`, also pass `Target Standard: <EGM root>/resources/document_standards/zoom-out-standard.md`.

**Fallback role lines** (option 3 only):

- **zoom-out:** "You are a skeptical architect who hates unnecessary scope. Find features, content types, jobs, and abstractions the product doesn't need yet, and simpler existing products, services, or Strapi built-ins that would do the job."
- **design:** "You are a hostile design critic. Check the targets against the standard: flag every question it requires that the targets don't answer, every unbacked assumption, and every unmitigated risk."
- **comprehension:** "You are a new team member with no background. Flag every term, system, or step that isn't defined in the document or linked."
- **implementation-readiness:** "You are the engineer who must build this from the document alone. Flag every place where you would have to guess or make a design decision."
- **codebase-details:** "You are a pedantic auditor. Check every statement in the document against the code it describes, and flag anything wrong, uncited, or missing."

## 3. Prompt templates

Fill in the `<…>` parts. Add nothing else — no summary of the conversation, no hints about what to look for.

**EGM reviewer, review mode** (`egm-design`, `egm-comprehension`, `egm-implementation-readiness`, and `egm-zoom-out` in checkpoint B):

```text
Mode: REVIEW
Targets (read in full): <abs path>, <abs path>
Target Standard: <abs path to reviews/standards/<standard>.md>
Background (read for context, do not review): <abs path to 03-requirements.md>
Platform note: This is a greenfield product plan. There is no codebase to search yet.
The platform is Strapi v5 (a headless CMS). "Existing solutions" means existing products
and services, Strapi built-in features, and official Strapi plugins.
For each finding give: Severity (Blocker | Major | Nit), Affected Scope (file and section
or lines), and the finding with your recommendation.
```

- Leave out `Target Standard` for `egm-zoom-out` (it applies its own zoom-out standard — except under dispatch option 2, see above) and for `egm-comprehension` (it needs none).
- Leave out `Background` everywhere except checkpoint B. At B, `egm-zoom-out` gets two background files: `03-requirements.md` and the copied `strapi-design-standard.md`. Without the standard, zoom-out argues against Strapi conventions it can't see, such as slug middleware for seeded data.

**EGM zoom-out, brainstorm mode** (checkpoint A only):

```text
Mode: BRAINSTORM
FeatureConcept: <the anchored hypothesis, verbatim>
Concept files (read in full): <abs path 01>, <abs path 02>, <abs path 03>
Platform note: <same as above>
For each finding give: Severity, Challenge/Risk, and the simpler alternative or existing
product/service that already covers it.
```

**Strapi lens** (`strapi-product-egm:skeptical-customer`, `strapi-product-egm:strapi-fact-checker`):

```text
Targets (read in full): <abs path>, <abs path>
Lens file: <abs path to this skill's lenses/<name>.md>
```

The registered agents already know to read their lens file; the path is there for options 2 and 3.

**Code-aware variants (existing-app mode).** Replace the platform note with the mode note from `existing-app-mode.md`, and add the codebase and the folder rule:

```text
Codebase (read code as needed to check claims): <abs path to every app root from E1>
Folder rule: never open or search .env files (.env.example is fine), and skip node_modules except to check an installed package.
```

- `egm-codebase-details` treats the codebase as its GoldfishContext.
- **The code auditors** get folders as targets, so their prompts say "search as needed" instead of "read in full":
  - `strapi-product-egm:strapi-code-auditor`: `Targets (search as needed):` the Strapi app root and every frontend root, plus `Target Standard:`, `Background: <abs path to 03>, <abs path to 05>`, and the folder rule.
  - `strapi-product-egm:frontend-auditor`: this prompt, plus the mode note:

    ```text
    Targets (search as needed): <abs path to every app root except the Strapi app>
    Lens file: <abs path to this skill's lenses/frontend-auditor.md>
    Target Standard: <abs path to reviews/standards/strapi-design-standard.md>
    Background (read for context, do not review): <abs path to 03>, <abs path to 05>
    Strapi app (read only the files the lens names): <abs path to the Strapi app root>
    Folder rule: never open or search .env files (.env.example is fine), and skip node_modules except to check an installed package.
    ```
- `strapi-product-egm:strapi-fact-checker` also gets every app's `package.json` and lockfile as targets, and, where they exist, each app's `node_modules` folder for installed source, so it can check the installed versions.
- Never include `.env` files in any list.

## 4. Consolidate

1. **Incomplete reviews.** A reviewer that couldn't read its persona, standard, or a target hasn't reviewed. Say so in the report and don't count it as clean.
2. **Merge duplicates.** The same issue from two reviewers is one finding: list both lenses and keep the higher severity. Two lenses agreeing is a stronger signal, so say so.
   - Items a reviewer lists under **To confirm** (facts outside the code, such as admin-panel or host settings) aren't findings. They go to the user as ESCALATE items.
3. **Group** by severity: 🔴 Blocker, 🟡 Major, 🟢 Nit. When a reviewer names a **root cause** behind several findings (zoom-out often does), lead the report with a short "Root causes" list and point each finding at its cause. A fix plan built on root causes is smaller than one that patches every symptom.
4. **Write** `<product>/reviews/<X>-<name>-review.md` (a re-run writes `<X>-<name>-review-rerun.md`):

   ```markdown
   # Checkpoint <X> — <name>

   - **Targets:** <files>
   - **Date:** <YYYY-MM-DD> · **EGM:** v<version>
   - **Reviewers (dispatch option):** <reviewer (1)>, <reviewer (2)>, …
   - **Standard:** <file>
   - **Totals:** 🔴 <n> · 🟡 <n> · 🟢 <n>

   ## Findings

   ### 1. <short title> — 🔴 Blocker
   - **Lens:** <reviewer(s)>
   - **Scope:** <file › section (lines)>
   - **Finding:** <what's wrong or missing>
   - **Recommendation:** <reviewer's advice>
   - **Resolution:** <added by the resolve step>
   ```

5. **Tell the user** in chat: the report path, the totals, and the top three Blockers or Majors in one line each. Don't paste the report. Then go straight to `resolve-protocol.md`.

## 5. Manual fallback (no subagent tool)

A brand-new chat is a goldfish too. For each reviewer, write `<product>/reviews/<X>-prompt-<reviewer>.md` (or render it as an artifact) containing:

1. The reviewer's role — the fallback role line from section 2, or the full lens file.
2. The standard, pasted in full.
3. The prompt template from section 3, with "Targets" replaced by: "The documents to review are pasted below this prompt."

Ask the user to open a new chat outside any Project (so it can't see this one), paste the prompt followed by the target files, and paste the reply back here. When all replies are in, consolidate and resolve as normal, and record dispatch option 4 for each reviewer in the report.

## 6. Cost

Checkpoint R runs one subagent; the others run three to five. If the user asks for a more thorough review, run each EGM reviewer twice as independent instances and merge the results (EGM's A/B option). That catches more and doubles the cost.
