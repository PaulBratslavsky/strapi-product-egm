# Field note: full review of the Trailhead example (2026-10-27)

All three checkpoints run on an unchanged copy of the builder's Trailhead example, with the installed plugin (v0.1.0) and EGM v0.1.0. The per-checkpoint reports (A, B, C) and raw reviewer output stayed in the run folder (`~/trailhead-review/reviews/`). This is the run's review log.

**Run:** 2026-10-27 · strapi-product-egm v0.1.0 · EGM v0.1.0 · all three checkpoints on an unchanged copy of the builder's Trailhead example (strapi-product-builder@6dacea4). Reviewers ran in parallel headless sessions with the installed plugins. No product owner, so no fixes were applied and nothing was re-run.

## Checkpoint A — Concept — 2026-10-27

- **Reviewers (option):** egm-zoom-out (1), egm-design (1), egm-comprehension (1), skeptical-customer (1) · **Re-run:** no
- **Findings:** 🔴 2 · 🟡 18 · 🟢 7 → proposed fix 18 · contested 1 · escalated 9 · declined 4 (partial labels counted under each)
- **Lessons for strapi-product-builder:**
  - Stage 1 never asks for the riskiest assumption, an early signal, or why users would switch from the tools they actually use. Three of four lenses independently found the same Blocker (report density / cold start). Add the Heilmeier questions to stage 1 and the 01 template.
  - When the product's value rests on a metric ("freshness"), define it in stage 3, not in the stage 5 sweep. All four lenses flagged it.
  - When content is user-generated, stage 3 should ask "who can remove bad content, and how?" Moderation was deferred wholesale, leaving no takedown path.
  - Stage 3 should ask where the initial content comes from (import, licence) and what users do when the thing they want to post about isn't listed.
  - The moderator role was ambiguous across admin accounts and end-user roles. Add a per-role "which account system" line to the 03 template.
- **Reviewer quality:** Very high signal. One contest: zoom-out wanted the frontend scoped in 03, which the builder deliberately leaves for stage 4. The skeptical-customer lens added the most product insight (reporter motivation, trust, the moderator's workload).

## Checkpoint B — Design — 2026-10-27

- **Reviewers (option):** egm-zoom-out (1), egm-design (1), strapi-fact-checker (1, with the strapi-docs MCP) · **Re-run:** no
- **Findings:** 🔴 5 · 🟡 17 · 🟢 10 → proposed fix 24 · contested 2 (+1 partial) · escalated 6 · declined 1
- **Lessons for strapi-product-builder:**
  - **Stage 4 must decide the session topology when frontend and backend are on different domains**, not defer it "to stage 5/6". `*.vercel.app` and `*.strapiapp.com` are both public suffixes, so cookies are third-party. Two lenses caught it as a Blocker. It's a new cookbook entry, and an auth-reference entry for the Better Auth path.
  - **Better Auth needs a stated gap.** The example chose it "for Google sign-in", which Users & Permissions already supports. Stage 4 should require "what does U&P lack?" before choosing Better Auth.
  - **New Better Auth trap:** the generated `user`, `session`, `account` and `verification` types must be denied to every content-API role, and `author` populate must be whitelisted. Add it to the cookbook and auth reference.
  - **Facts to fix in the builder:**
    - Node ≥ 22, not ≥ 20 — `templates/06-build-spec.template.md` L14, `references/auth-better-auth.md` L17.
    - Strapi Cloud "free tier is fine for POCs" (`references/strapi-cloud-deploy.md` L28) is contradicted by the docs — verify.
    - `@better-auth/cli` vs `npx auth@latest generate` — verify against the Strapi adapter.
    - "Never set `DATABASE_*` on Cloud"; `ENCRYPTION_KEY` is missing from env lists.
  - The 05 template needs the Operations (robustness sweep) section. The example has none, so B counted it as a Major.
- **Reviewer quality:** egm-design was the strongest lens (5 Blockers, all valid). egm-zoom-out produced both contests by challenging builder conventions it couldn't see (slug middleware for seeded data, populate middleware). The fact-checker found 6 real issues in 25 claims, including two the builder's own references get wrong.

## Checkpoint C — Build readiness — 2026-10-27

- **Reviewers (option):** egm-implementation-readiness (1), egm-comprehension (1), strapi-fact-checker (1, with the strapi-docs MCP) · **Re-run:** no
- **Findings:** 🔴 7 · 🟡 13 · 🟢 4 → proposed fix 21 · escalated 3 (+2 partial) · contested 0 · declined 0
- **Lessons for strapi-product-builder:**
  - **The showcase example fails the builder's own promise.** "See stage 5" stands where the schemas should be. Stage 6's "reference them as background" invites it, and the template's "from stage 5" markers reinforce it. Require inline `schema.json` and seeded permissions in 06.
  - **The example predates the builder's current rules** (no deviation-protocol header, no e2e milestone, missing `--no-example --no-git-init`). Regenerate Trailhead with the current builder, then re-run this review as a regression test.
  - **Template bug:** `templates/06-build-spec.template.md` runs `cd apps/cms && npm install` and then scaffolds `apps/web`, which lands in `apps/cms/apps/web`. Use subshells. Also add `--yes` to `create-next-app`.
  - The Better Auth path needs `BETTER_AUTH_DASHBOARD_SECRET` if the dashboard plugin is installed. It's missing from the auth reference's env list.
- **Reviewer quality:** No contests. Implementation-readiness and comprehension overlapped heavily (the same Blockers found independently), which is good for confidence and a little expensive. The fact-checker's npx `-y` catch was one neither of the others made.

## Lessons for strapi-product-egm itself

- Give egm-zoom-out the checkpoint's Strapi standard as background at B. Without it, zoom-out argues against builder conventions, which caused both contests.
- In review-only mode on files nobody here owns, the hypothesis gate and resolve gate have no one to answer them. The runner drafted the hypothesis without writing it into 01, and applied no edits. Document this as the expected behaviour for example and third-party files.
- Raw output was ~12k words for 10 reviewers. Consolidating it is real work for the Elephant; the per-checkpoint reports are worth keeping.
