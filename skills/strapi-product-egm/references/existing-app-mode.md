# Existing-app mode

Use this when the user has a product built on Strapi that wasn't planned with this skill — or whose plan no longer matches the code — and wants it reviewed and improved. The review covers the whole product in the repo: the Strapi app, every frontend, any other apps (workers, other APIs), the outside services they call, and hosting. It follows EGM's pattern for existing code: document what's there, check the documents against the code, review the design, then write and review a change plan before touching anything.

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

- **Read-only until E8.** Before E8, the only files you write are the planning docs and reviews. One exception: Step 0's EGM install, with the user's yes. A project-scope install writes `.claude/settings.json` in the repo, and Step 0's scope question says so.
- **Never read `.env` values.** Use `.env.example` and code for variable *names*. Never copy a secret into a doc or a prompt.
- **E8 runs on a new git branch** (in each repo it changes), never pushes, and never touches production data or credentials. Migrations run against a scratch database only (see "Running the checks").
- **E8 always overrides production settings.** Strapi and the frontend frameworks read their `.env` files themselves, and you can't read those files, so every override in "Running the checks" applies whatever the user says.
- **Before you boot anything in E8, ask the user once** whether any app's local env files (`.env`, `.env.local`, and the like, in every app folder) point at a production service: database, payments, email, storage, a paid API, or a production Strapi URL and API token that a frontend or worker calls. If any does, list the variables you'll override and confirm none is missing. If you can't override one, stop.

---

## E1 — Find the app and interview the owner

1. **Map the whole repo.** List every app and package, not only Strapi and the frontend:
   - The Strapi app is the folder whose `package.json` depends on `@strapi/strapi` (usually `.`, `backend/`, `server/`, `apps/cms/`, or `strapi/`).
   - Frontends depend on `next`, `astro`, `nuxt`, `@tanstack/react-start`, and so on.
   - Everything else counts too: workers, other APIs, scripts that write data, shared packages. Find them through the workspace settings (`workspaces` in the root `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`) and every other `package.json` outside `node_modules`.

   Note each app's root folder and the versions of Strapi and each frontend framework (from `package.json` and the lockfile), and the current commit of each repo (`git rev-parse --short HEAD`). Each reviewer later gets the app roots its row in E3, E4, or E7 names. If the Strapi app is the repo root, "the Strapi app" means that root without the other app roots inside it.
2. **Read what's there:** README files, `CLAUDE.md` / `AGENTS.md`, existing docs. If the repo has earlier run folders (`docs/designs/*/reviews/review-log.md`), apply their open lessons (`learning-loop.md`, section 2).
3. **Interview** — one question per turn, as in Step 1. Draft each answer from the README and code first, and ask the user to correct it:
   - What the app does and for whom (confirm your one-liner).
   - Who uses it, and the action they repeat (the core loop).
   - **What's wrong, or what they want to change** — the goal of this round.
   - **Live constraints:** is it in production, with real users and data? Where is it deployed? This decides how careful data changes must be.
   - **What must not change:** public URLs, API consumers (mobile apps, other services), integrations.
   - **Parts in other repos:** does any part of the product (a frontend, a worker, another API) live outside this repo? If it's on this computer, add its folder to the app roots. Otherwise record it under **Constraints** in `03` as out of scope for this review.
4. **Write `01`–`03`** with the builder's templates, marked `> As-is — <date>` at the top. Keep them short. Add two sections to `03`: **Change goals** (the user's own words) and **Constraints** (live data, must-not-change).

Checkpoint A is optional here. Offer it only if the change goals are about the product itself (a new audience, a new core loop).

## E2 — Reconstruct the design as built

Write `04-tech-decisions.md` and `05-tech-requirements.md` with the builder's templates, describing **what the code does**, not what it should do.

- **Header:** `> As built — reconstructed from <repo> @ <commit>, <date>. Describes the code, not intentions.` If the product spans more than one repo, give one `<repo> @ <commit>` for each.
- **Every claim cites a file** — for example `backend/src/api/summary/routes/summary.ts`. If you can't cite it, don't write it.
- **A citation shows what a file says, not what works.** `"engines": "<=22"` in `package.json` is cited as "declared in `package.json`, not verified", never as "requires Node ≤ 22".
- **Markers** (use these three, and no others):
  - `⚠️ not in code — <what to confirm>`: something the code can't tell you, such as permissions clicked in the admin panel, data in the database, or hosting settings. Collect these and ask the user in one message at the end of E2.
  - `⚠️ framework behavior — <claim>`: the claim depends on how the installed framework behaves, for example "stock `PUT /api/users/:id` has no owner check". The fact-checker verifies these at B against the installed source.
  - `not verified — <why>`: a claim nobody has tried, such as runtime support.
- **In 04, "Considered" is usually unknown.** Write "unknown (pre-existing)". Fill in "Why" only if the README or commit history says.
- **No judgments.** "The `find` route has no owner filter" is a description. "This is insecure" is a finding — leave it for the reviewers.
- **Include the Operations (robustness sweep) section,** with each line saying what the code does, or "not handled".
- **Add the sections the design standard asks for that the builder's templates lack**, in `05`:
  - "Outside services and other apps" (§10) and "Hosting and environments" (§11);
  - for each route in "Pages & components", the answers §9 asks for, and which routes are on the core loop;
  - a "Session" subsection under Auth (§9: storage, how it's sent, expiry);
  - a "Server-side handlers" table for each frontend: handler, the credential it calls Strapi with, and what it checks first (§9).

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
| CORS | the `strapi::cors` entry in `config/middlewares.*` |
| Frontend | its `package.json`; the full route tree; server-side handlers (route handlers, server actions, `server/api`, API routes) and middleware or proxy files; the helpers that call Strapi or other services; caching and revalidation settings; env var names; how the session is stored, sent, and checked |
| Other apps | each one's `package.json` and entry point; what calls it (a queue, a schedule, an HTTP route); what it writes |
| Outside services | SDK imports and HTTP calls to other APIs (payments, email, AI, storage, search); the env var each key comes from; webhook handlers; what happens when a call fails |
| Tests | test folders, end-to-end config (`playwright.config.*`, `cypress.config.*`), and the test steps in CI |
| Deployment | `Dockerfile`, CI workflows, host config files (`vercel.json`, `netlify.toml`, `wrangler.toml`), hosting notes in the README |

**Large codebase:** split the reading by area across helper subagents (for example Explore agents). They aren't goldfish — they read for you, and you write the docs. The user can also run `/egm:egm-bootstrap` first to generate per-folder READMEs.

## E3 — Checkpoint R: reconstruction check

Checkpoint B reviews the docs. If the reconstruction is wrong, B reviews fiction — so check it first.

- **Reviewer:** `egm:egm-codebase-details` in REVIEW mode. Targets: `04`, `05`. Target Standard: `standards/as-built-standard.md`. Codebase: every app root from E1. (Prompt template in `checkpoints.md`.)
- **Report:** `reviews/R-reconstruction-review.md`.
- **Resolve:** R's fixes correct facts, not decisions, so apply every PROPOSE FIX directly and list them for the user. ESCALATE items still go to the user. Re-run at most once.

## E4 — Checkpoint B: design review of the existing app

Reviewers, in parallel (templates in `checkpoints.md`, "code-aware" variants):

| Reviewer | Targets | Standard | Background |
|---|---|---|---|
| `egm:egm-design` | 04, 05 | `strapi-design-standard.md` | 03, codebase |
| `egm:egm-zoom-out` | 04, 05 | its own | 03, `strapi-design-standard.md`, codebase |
| `strapi-product-egm:strapi-code-auditor` | the Strapi app root and every frontend root | `strapi-design-standard.md` | 03, 05 |
| `strapi-product-egm:frontend-auditor` | every app root except the Strapi app (frontends, workers, other APIs) | `strapi-design-standard.md` | 03, 05, and the Strapi app root (for the files its lens names) |
| `strapi-product-egm:strapi-fact-checker` | 04, 05, every app's `package.json` and lockfile (and installed packages in `node_modules`, where they exist) | — | — |

If E1 found no app root besides the Strapi app, leave out the frontend auditor and say so in the report.

Both auditors read the frontend. The Strapi code auditor checks how the frontend uses Strapi's API; the frontend auditor checks the frontend against §6–11.

Add this mode note to every prompt: *"These are as-built documents of an existing product. Judge the design the code implements across the whole product: the Strapi app, every frontend, any other apps, the outside services they call, and hosting. Parts that `03` lists as out of scope aren't reviewed; don't flag them as missing. 'Considered' and 'Why' in 04 may be unknown; don't flag that. Rules that require a stated reason for a risky choice still apply: flag those, and the owner can accept the risk. Flag gaps against the standard, risks, and any place where the code contradicts the documents."*

For the fact-checker, add: *"Check the installed versions of Strapi, its plugins, each frontend framework, and the other apps' main packages for published security advisories, and verify every item the documents mark '⚠️ framework behavior' against the installed version's source."* In the first test run this produced the most serious findings (an account takeover through a stock route, and RCE advisories on the installed Next.js).

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
3. **Baseline: run the app before you change it.** Install, boot and build the Strapi app, each frontend, and any other app the core loop needs, the way the README says. Then try the core loop once, and write down what already fails. Without a baseline you can't tell your bugs from old ones.
   - **Every rule in "Running the checks" applies to the baseline too.** Above all, use a scratch database, and use no production services.
   - **Use the runtime the user already has.** `engines` in `package.json` is a declaration, not a test, so try the current Node version first. A package manager that refuses because of `engines` is not evidence: retry with `--ignore-engines` (yarn 1) or `engine-strict=false` (npm). Finish the fresh-clone setup (next bullet) first. Switch versions only when an error points at the runtime itself, such as a native module that won't build or an unsupported API. Record that error, and record the version you used in `E8-implementation-log.md`.
   - **Fresh clones miss generated files.** Strapi writes `types/generated/` on the first `strapi develop`, and `public/uploads/` may be missing (create it). `strapi build` can fail on types until `develop` has run once. These are setup steps, not app bugs.
   - **Fill the scratch database** the way the repo does: import its seed archive (`strapi import -f <archive> --force`, against the scratch database), create users through the API, and create an admin with `strapi admin:create-user` if a check needs one.
   - **Try the external calls the core loop depends on, safely.** Try only calls that read data, or that use a sandbox or test key (a public transcript API, a payment provider's test mode). Never trigger a real charge, and never send email to a real address. For anything else, write "not verified" and use a mock (see below).
     - If a call is already broken, report it as a pre-existing problem and don't fix it in this change.
     - If a milestone's checks depend on that call, stub it only to reach the check. If the milestone itself can't work without it, stop and ask.
4. Work milestone by milestone, following `06` exactly. If something in the code makes a step wrong or impossible, stop and ask — that is the deviation protocol, and it applies to you too.
5. Run each milestone's verification (see "Running the checks"). Commit once per milestone, with the milestone title as the message.
6. Never push. Never point anything at production data or credentials.
7. Write `reviews/E8-implementation-log.md`. Include:
   - the runtime versions you used;
   - the commits;
   - each check and its result;
   - what was tested against a mock or a stub;
   - pre-existing problems you found;
   - spec steps that were wrong.

   Then capture lessons, once, in the review log (`references/learning-loop.md`, section 1).

### Running the checks

- **Overrides go on every command that loads env files:** install scripts, build, start, seed, and import. Leaving a variable off the command line doesn't unset it, because the app reads its `.env` files itself. Public-prefixed frontend variables are fixed at build time, so override them on the build too.
- **Use a scratch database**, never the user's data. Set every database variable on the command line, taking the names from the Strapi app's `config/database.*`. For SQLite: `DATABASE_CLIENT=sqlite DATABASE_FILENAME=.tmp/<name>.db`. For Postgres: a throwaway database on localhost.
- **No production services.** Set every variable for a paid or outward-facing service (payments, email, storage, AI keys) to an empty or fake value, or to a test key. Use a mock where a call must succeed.
- **Point every frontend and worker at the local Strapi.** Set each one's Strapi URL (and API token, if it uses one) on the command line, because its env files may name a production instance.
- **Restart Strapi after backend edits.** Auto-reload didn't pick up new files in Strapi 5.21. Confirm that the new code is live, for example that a new route no longer returns 404 or 405.
- **Admin-panel steps can run headlessly, for check set-up only.** Set a field through the API or the scratch database, or simulate "ticking" a permission by inserting its row, and say which steps you replaced. Permissions that `06` adds or changes are seeded in `bootstrap()` (change-spec standard §5), never by a database insert. Permissions the app already relies on but doesn't seed in code (set in the admin panel) may be inserted into the scratch database for the baseline and checks; report that as a pre-existing problem.
- **Third-party APIs without test keys:**
  - Test the failure path with an empty or fake key.
  - For the success path, point the SDK at a small local mock through its base-URL setting, with a fake key (for example `OPENAI_BASE_URL` for the AI SDK's OpenAI provider).
  - A client with no base-URL setting gets a temporary stub instead (next bullet).
  - Never use the user's production keys.
- **Temporary stubs in app code**, only to reach a check (for example, a canned transcript while the real API is down). Revert them before you commit, confirm that `git diff` shows none of the stub's lines, and report the stub.
- **Report what each check proved, and what it didn't**, for example "success path tested against a local mock, not real OpenAI". Don't round "not tested" up to "works".

## E9 — Close the loop

- Update `04`/`05` to the new as-built state, with fresh citations and the new commit.
- Add an entry to `reviews/review-log.md`, above its `## Lessons` section: what was found, what was fixed, and what was deferred. Cite the IDs of the lessons captured in E8; don't capture them again.
- Suggest that the user run `/egm:egm-drift-report docs/designs/<app-name>` now and then, to catch drift as the code moves on.
