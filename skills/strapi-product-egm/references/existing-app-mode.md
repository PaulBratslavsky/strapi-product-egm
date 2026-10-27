# Existing-app mode

Use this when the user has a Strapi app that wasn't planned with this skill — or whose plan no longer matches the code — and wants it reviewed and improved. It follows EGM's pattern for existing code: document what's there, check the documents against the code, review the design, then write and review a change plan before touching anything.

## The flow

| # | Elephant (you) | Goldfish checkpoint |
|---|---|---|
| E1 | Find the app, read what's there, short interview → `01`–`03` as-is, plus change goals | (A is optional) |
| E2 | Reconstruct `04`, `05` **as built**, from the code | **R — Reconstruction check:** do the docs match the code? |
| E3 | Correct the docs | |
| E4 | | **B — Design review** of the docs **and** the code |
| E5 | Resolve B; the user picks which findings to fix now | |
| E6 | Write `06-change-spec.md` | **C — Change readiness** |
| E7 | Resolve C | |
| E8 | Implement on a branch — only if the user says go | |
| E9 | Update `04`/`05` to the new as-built state | |

**Where files go:** in the app's repo, under `docs/designs/<app-name>/` (EGM's convention), with `reviews/` inside it. If the repo already has planning docs (from strapi-product-builder or elsewhere), don't overwrite them: treat them as background, and report any place they disagree with the code — that drift is a finding.

## Safety rules

- **Read-only until E8.** Before E8, the only files you write are the planning docs and reviews.
- **Never read `.env` values.** Use `.env.example` and code for variable *names*. Never copy a secret into a doc or a prompt.
- **E8 runs on a new git branch**, never pushes, and never touches production data or credentials. Migrations run against a local or dev database only.

---

## E1 — Find the app and interview the owner

1. **Find the code.** The Strapi app is the folder whose `package.json` depends on `@strapi/strapi` (usually `.`, `backend/`, `server/`, `apps/cms/`, or `strapi/`). Frontends depend on `next`, `astro`, `nuxt`, `@tanstack/react-start`, and so on. Note the Strapi version from `package.json` and the lockfile, and the current commit (`git rev-parse --short HEAD`).
2. **Read what's there:** README files, `CLAUDE.md` / `AGENTS.md`, existing docs.
3. **Interview** — one question per turn, as in Step 1. Draft each answer from the README and code first, and ask the user to correct it:
   - What the app does and for whom (confirm your one-liner).
   - Who uses it, and the action they repeat (the core loop).
   - **What's wrong, or what they want to change** — the goal of this round.
   - **Live constraints:** is it in production, with real users and data? Where is it deployed? This decides how careful data changes must be.
   - **What must not change:** public URLs, API consumers (mobile apps, other services), integrations.
4. **Write `01`–`03`** with the builder's templates, marked `> As-is — <date>` at the top. Keep them short. Add two sections to `03`: **Change goals** (the user's own words) and **Constraints** (live data, must-not-change).

Checkpoint A is optional here. Offer it only if the change goals are about the product itself (a new audience, a new core loop).

## E2 — Reconstruct the design as built

Write `04-tech-decisions.md` and `05-tech-requirements.md` with the builder's templates, describing **what the code does**, not what it should do.

- **Header:** `> As built — reconstructed from <repo> @ <commit>, <date>. Describes the code, not intentions.`
- **Every claim cites a file** — for example `backend/src/api/summary/routes/summary.ts`. If you can't cite it, don't write it.
- **Things the code can't tell you** — permissions clicked in the admin panel, data in the database, hosting settings — are written as `⚠️ not in code — <what to confirm>`. Collect them and ask the user in one message at the end of E2.
- **In 04, "Considered" is usually unknown.** Write "unknown (pre-existing)". Fill in "Why" only if the README or commit history says.
- **No judgments.** "The `find` route has no owner filter" is a description. "This is insecure" is a finding — leave it for the reviewers.
- **Include the Operations (robustness sweep) section,** with each line saying what the code does, or "not handled".

**Where to look (Strapi v5):**

| Area | Look in |
|---|---|
| Versions, plugins | `package.json`, the lockfile, `config/plugins.*` |
| Content types | `src/api/*/content-types/*/schema.json`; components in `src/components/**`; extensions in `src/extensions/*/content-types/*/schema.json` |
| Routes, controllers, services | `src/api/*/routes`, `controllers`, `services` |
| Policies, middlewares | `src/policies`, `src/middlewares`, `src/api/*/policies`, `src/api/*/middlewares`, `config/middlewares.*` |
| Lifecycle hooks, Document Service middleware, seeding | `src/api/*/content-types/*/lifecycles.*`; `register()` and `bootstrap()` in `src/index.*` |
| Auth | Users & Permissions settings in `config/plugins.*`; Better Auth packages; permission seeding in `bootstrap()` |
| Cron | `config/cron-tasks.*`, cron settings in `config/server.*` |
| Local plugins, MCP | `src/plugins/*`; `mcp` in `config/server.*`; `strapi.ai.mcp` registrations |
| Seed or export archives | `*.tar.gz` from `strapi export` (often `seed-data.tar.gz`): list the record types with `tar -xzOf <file> entities/entities_00001.jsonl`. Users & Permissions roles and permissions often live here rather than in code. |
| Environment | `.env.example` — names only |
| Migrations | `database/migrations` |
| Frontend | its `package.json`, the route tree, the helpers that call Strapi, env var names, how the session is stored and sent |
| Deployment | `Dockerfile`, CI workflows, hosting notes in the README |

**Large codebase:** split the reading by area across helper subagents (for example Explore agents). They aren't goldfish — they read for you, and you write the docs. The user can also run `/egm:egm-bootstrap` first to generate per-folder READMEs.

## E3 — Checkpoint R: reconstruction check

Checkpoint B reviews the docs. If the reconstruction is wrong, B reviews fiction — so check it first.

- **Reviewer:** `egm:egm-codebase-details` in REVIEW mode. Targets: `04`, `05`. Target Standard: `standards/as-built-standard.md`. Codebase: the Strapi and frontend roots. (Prompt template in `checkpoints.md`.)
- **Report:** `reviews/R-reconstruction-review.md`.
- **Resolve:** R's fixes correct facts, not decisions, so apply every PROPOSE FIX directly and list them for the user. ESCALATE items still go to the user. Re-run at most once.

## E4 — Checkpoint B: design review of the existing app

Reviewers, in parallel (templates in `checkpoints.md`, "code-aware" variants):

| Reviewer | Targets | Standard | Background |
|---|---|---|---|
| `egm:egm-design` | 04, 05 | `strapi-design-standard.md` | 03, codebase |
| `egm:egm-zoom-out` | 04, 05 | its own | 03, `strapi-design-standard.md`, codebase |
| `strapi-product-egm:strapi-code-auditor` | the codebase | `strapi-design-standard.md` | 05 |
| `strapi-product-egm:strapi-fact-checker` | 04, 05, the `package.json` files | — | — |

Add this mode note to every prompt: *"These are as-built documents of an existing app. Judge the design the code implements. 'Considered' and 'Why' may be unknown; don't flag that. Flag gaps against the standard, risks, and any place where the code contradicts the documents."*

**Report:** `reviews/B-design-review.md`.

## E5 — Resolve B and choose the scope

Label the findings as usual (`resolve-protocol.md`). In this mode, **PROPOSE FIX means "change the app"**, not "edit 05" — `04` and `05` stay as-built until E9.

Then ask one question: **which findings go into this change?**

- **All Blockers and Majors, plus your change goals**
- **Walk me through them** — one finding per turn: include or defer
- **Only my change goals**

Everything not chosen goes into the change spec's **Deferred findings** list. If nothing is chosen, stop: hand over the reports and the review log.

## E6 — Write the change spec

Read `standards/strapi-change-spec-standard.md` first. Then write `06-change-spec.md` from `templates/06-change-spec.template.md`:

- Goals trace to the user's change goals and to finding IDs (for example `B-4`).
- Milestones are ordered (data before code that needs it; backend before the frontend that calls it). Each one names its files, the exact edits, the data steps, every caller it affects, how to verify it, and how to roll it back.
- Read the code you're changing before you specify an edit. A change spec with wrong paths fails checkpoint C.

## E7 — Checkpoint C: change readiness

Reviewers, in parallel:

| Reviewer | Targets | Standard | Background |
|---|---|---|---|
| `egm:egm-implementation-readiness` | 06 | `strapi-change-spec-standard.md` | codebase |
| `egm:egm-codebase-details` | 06 | `strapi-change-spec-standard.md` | codebase |
| `strapi-product-egm:strapi-fact-checker` | 06 | — | — |

Unlike greenfield checkpoint C, these reviewers get the codebase: the agent that implements the change will have it too. The spec must be complete *given* the code and the official docs.

**Report:** `reviews/C-change-readiness-review.md`. Resolve as usual; here PROPOSE FIX edits `06`.

## E8 — Implement (only on the user's go)

Ask one question: implement now on a new branch, or stop here (the user can hand `06` to another session)?

If they say go:

1. Check the working tree is clean. If not, stop and ask.
2. Create a branch: `egm/<short-change-name>`.
3. Work milestone by milestone, following `06` exactly. If something in the code makes a step wrong or impossible, stop and ask — that is the deviation protocol, and it applies to you too.
4. Run each milestone's verification. Commit once per milestone, with the milestone title as the message.
5. Never push. Never point anything at production data or credentials.

## E9 — Close the loop

- Update `04`/`05` to the new as-built state, with fresh citations and the new commit.
- Append to `reviews/review-log.md`: what was found, what was fixed, what was deferred.
- Suggest that the user run `/egm:egm-drift-report docs/designs/<app-name>` now and then, to catch drift as the code moves on.
