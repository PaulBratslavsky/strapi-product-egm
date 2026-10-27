# Field note: checkpoint C on the Trailhead example (2026-10-27)

**What ran:** checkpoint C (build readiness) on `skills/strapi-product-egm/builder/examples/trailhead/06-build-spec.md` — the builder's own worked example — in a headless Claude Code session with this plugin and EGM v0.1.0 loaded via `--plugin-dir`.

**Reviewers:** `egm:egm-implementation-readiness` with `standards/strapi-build-spec-standard.md`, and `strapi-product-egm:strapi-fact-checker` (web docs only — the `strapi-docs` MCP was blocked by headless permissions). `egm:egm-comprehension` was not part of this run.

**Standard version:** the first draft of `strapi-build-spec-standard.md`, before it gained Better Auth variants the same day. Trailhead uses Better Auth, so a re-run with the current standard may differ slightly.

**Not resolved.** These are raw reviewer findings, not checked against the elephant's knowledge. Some may be wrong — for example, the builder's `content-modeling.md` says draft & publish is off by default, while the reviewer says it is on by default in v5. That disagreement is exactly what the resolve step's ESCALATE label is for.

## Lessons for strapi-product-builder (first pass)

- The example spec still points at "See stage 5" for schemas — the dead-reference problem the builder's stage 6 rules warn about. Stage 6 should require inline `schema.json` for every type.
- Permissions are described, not seeded in code, and the matrix is incomplete (update/delete, upload, owner-scoped reads).
- The ownership patterns (is-owner policy, create override, "my reports" read) are named but not written out, though the builder says to inline them.
- Several milestones have no "Done when"; there is no end-to-end test milestone.
- Facts to re-verify: supported Node versions for current Strapi (reviewer: 22/24/26, not ≥ 20), and the Better Auth CLI package name (`@better-auth/cli` reported deprecated).

## Raw reviewer output

## egm:egm-implementation-readiness

# Implementation Readiness Review: Trailhead build spec (`06-build-spec.md`)

**Verdict: not ready to build.** I read the persona file, the target and the standard in full. A build agent with only this spec and the official docs could not build the data model, the permissions or the owner-scoped flows without making design decisions itself.


## Blockers

**1. The schemas point to a file the agent can't open, and none are given.**
- **Scope:** "Strapi schemas" (L90–91); M1 (L48); M2 (L53).
- **Finding:** "See stage 5" is a dead reference. There is no `schema.json` for Trail, Region or Report, and no component JSON under `src/components/shared/` for `location` or `seo`. The agent would have to choose:
  - every field and its type, such as the report's rating scale, `note` length and `photo` (single or multiple media);
  - which fields are required;
  - the relations and their cardinality: Report→Trail, Trail→Region and Report→author;
  - the field that "featured" on the home page (L104) is based on.
- **Recommendation:** Put the full Content-Type Builder JSON for all three types and both components inline.

**2. Draft & publish is not decided for Report and Region.**
- **Scope:** M2 (L53); acceptance (L132).
- **Finding:** Draft & publish is only specified for Trail. In Strapi v5 it is on by default. If Report keeps it, user-posted reports become drafts and never appear publicly, so the acceptance criterion on L132 fails.
- **Recommendation:** Set `draftAndPublish` explicitly in each schema. For Report it should be `false`.

**3. The target of the `author` relation is undefined.**
- **Scope:** M3 (L62–63); M4 (L71).
- **Finding:** With Users & Permissions removed, the `user` type comes from the Better Auth generate step. The spec doesn't say:
  - its UID (for example `api::user.user` or `plugin::better-auth.user`), which `Report.author` must point at;
  - whether the plugin actually fills `ctx.state.user`, or where the session comes from instead.
- **Recommendation:** Give the exact UID, the relation definition, and the exact way the controller reads the current user.

**4. Permissions are incomplete and not set in code.**
- **Scope:** M3 (L65); API surface (L94).
- **Finding:**
  - The spec grants anonymous read and authenticated create on report. It never grants authenticated update/delete on report, so the `is-owner` policy has nothing to guard.
  - Authenticated upload is not granted, so the report photo on L132 can't be posted.
  - There is no grant for the owner-scoped read behind `/my-reports`.
  - Nothing says how permissions are applied (admin UI or code). The standard requires them to be seeded in code.
- **Recommendation:** Add a full permission matrix (role × action × content type, including `plugin::upload`). Seed it in `bootstrap()` with the exact API calls for `plugin-api-permissions`.

**5. The owner-scoped Strapi patterns are named but not written out.**
- **Scope:** M4 (L70–73).
- **Finding:** The standard requires these patterns inline as code or exact steps. The spec gives none of the following:
  - code for the `global::is-owner` policy, and how it loads the report (`strapi.documents('api::report.report').findOne` with populate on `author`) and compares IDs;
  - how it is attached in `src/api/report/routes/report.ts`;
  - the controller's `create` override, including removing any client-supplied `author`;
  - how `/my-reports` reads only the user's own reports (a custom `GET /api/reports/me` route or a forced filter in the controller). It is not in the API surface on L94.
- **Recommendation:** Add the code, file paths and route config for each of these.

**6. Slug identity is undefined.**
- **Scope:** M4 (L70); route `/trails/[slug]` (L107).
- **Finding:** The spec doesn't say:
  - which field the slug is built from;
  - how name collisions are handled;
  - whether the slug changes when the name is edited;
  - which document actions the middleware runs on (create, update);
  - whether the slug field is `unique` with a real database index.
- **Recommendation:** Give the middleware code inline. Mark `slug` as `unique: true` in the schema and state the collision rule.

**7. The cross-origin auth wiring is missing.**
- **Scope:** M3 (L64); M8 (L86); Deployment (L128).
- **Finding:** The spec doesn't give:
  - `config/middlewares.ts` CORS settings (Vercel origin, `credentials: true`);
  - how the Next.js app sends authenticated `POST /api/reports` (a cookie with `credentials: 'include'`, or a bearer token);
  - the actual `advanced.defaultCookieAttributes` code.

  Also, `SameSite=None` cookies across two different domains are blocked by Safari ITP and are being phased out in Chrome. The spec doesn't choose a mitigation, such as a shared parent custom domain or proxying `/api/auth` through Next.js rewrites. This is an auth decision left to the implementer.
- **Recommendation:** Pick the approach and give the config code inline.

**8. The Better Auth setup code is not inline.**
- **Scope:** M3 (L61–64).
- **Finding:** The spec doesn't give:
  - the contents of `config/plugins.ts`;
  - the body of `src/lib/auth.ts`: adapter import, `emailAndPassword`, `socialProviders.google`, `trustedOrigins`;
  - whether email verification or password reset is on. Resend is in the stack but never wired up.

  Line 5 sends the agent to a blog tutorial. That is not the official docs, so it fails the self-contained rule.
- **Recommendation:** Inline the config files. Decide on email verification and password reset, and wire Resend if it is used.

## Majors

**1. The header is incomplete.** (L3–5)
- There is no deviation protocol (commands and conventions are user decisions; stop and ask before substituting).
- The docs lookup has no Next.js docs URL and no instruction to check version-sensitive conventions against the current major version.

**2. The setup commands are not fully non-interactive.** (L33–41)
- `create-strapi-app` is missing `--no-example --no-git-init`.
- `create-next-app` has no flags (`--ts --app --tailwind --eslint --use-npm --yes`, etc.), so it will prompt.
- There is no `shadcn init` step.
- Nothing says how to start local Postgres (for example with Docker), yet M1's "Done when" depends on it.
- L37 and L59 install different package sets. `@better-auth/infra` has no stated purpose.

**3. The monorepo setup conflicts with Strapi Cloud.** (L22–28, L49, L126)
- With root `package.json` workspaces, the lockfile ends up at the repo root. Strapi Cloud with root dir `apps/cms` may not install correctly.
- **Recommendation:** Decide on workspaces versus independent apps, and say where the lockfile lives.

**4. Milestone structure and ordering problems.**
- M1 (L48) and M2 duplicate content-type creation.
- M3's "Done when" (L67) needs the Next.js sign-up UI, which isn't built until M5/M6.
- M4, M5, M6 and M7 have no "Done when".
- The `populate-trail` middleware is listed in both M2 (L53) and M4 (L73), and its populate tree is never given.

**5. Route and API mismatch.** (L94, L107)
- The trail page is keyed by `slug`, but the API surface only lists `GET /api/trails/:documentId`.
- **Recommendation:** Give the exact queries, for example `filters[slug][$eq]` and `filters[trail][slug][$eq]&sort=createdAt:desc`, and the fetch helpers.
- Search on L106 has no defined fields, operator (`$containsi`?), region filter or pagination.

**6. The term "moderator" is undefined.** (L8, L54, L134)
- It's unclear whether this is a Strapi admin role (Editor or a custom role) or a Better Auth role.
- **Recommendation:** Define it and say how a moderator account is created.

**7. Environment variables don't match the rest of the spec.** (L113–123)
- `CLIENT_URL` (L64) is missing from the list.
- `JWT_SECRET` is listed, yet Users & Permissions is removed. Say whether it is still needed.
- `RESEND_API_KEY` is listed but nothing uses it.
- No variable has a description and example value.
- `STRAPI_API_TOKEN` has no creation step (admin UI, read-only) and it isn't stated whether `api-permissions` honors API tokens.
- The Node version for Strapi Cloud is not set.

**8. Seeding is unspecified.** (M7, L82)
- The spec doesn't say:
  - where the script lives or how it runs (`bootstrap` or a standalone `createStrapi().load()`);
  - whether it is idempotent;
  - how hero images are uploaded (through the upload service, not the Document Service);
  - how login-capable test users are created (Better Auth `auth.api.signUpEmail`, so passwords are hashed);
  - the permission seeding.

**9. Empty and error states are undefined.** (M5)
- Missing:
  - trail not found (`notFound()`);
  - a trail with no reports;
  - post-report validation errors;
  - what happens when an unauthenticated user clicks post;
  - redirect targets for protected routes.

**10. There is no end-to-end test milestone.** (L130–135)
- The acceptance criteria aren't turned into tests that create their own data through the app's real entry points.
- L135 ("read → hike → post") can't be tested as written.

**11. The open questions list is incomplete.** (L137–141)
- It doesn't list the surviving assumptions or the Blockers above.

## Nits

1. Plugin maturity is stated two ways: `plugin-api-permissions` is "beta" on L15 and "alpha" on L65. Pick one.
2. M4 (L71) returns 403 for unauthenticated requests. Use 401, and 403 for a request from someone who isn't the owner.
3. TanStack Query needs a `QueryClientProvider` in `layout.tsx` or a client providers file. Say which.
4. M1 assumes a git remote exists but has no step to create the repo or push it.

## strapi-product-egm:strapi-fact-checker

I found 5 problems in the Trailhead build spec. One is a version error that would break the setup and one is a deprecated command; the other three aren't covered by the official sources. The `strapi-docs` MCP tool was blocked by permissions, so I checked everything against docs.strapi.io, the official Better Auth tutorial, better-auth.com and the npm registry.

**1. Major**
- **Scope:** 06-build-spec.md › Stack (line 11)
- **Claim:** "Strapi v5 (Node ≥ 20)"
- **Verdict:** Wrong
- **Source:** https://docs.strapi.io/cms/installation/cli ("Only Active LTS or Maintenance LTS versions are supported (currently `v22`, `v24`, and `v26`)")
- **Correction:** Use Node 22, 24 or 26. Node 20 is no longer supported. Strapi Cloud's build fails if the chosen Node version doesn't match the Strapi version.

**2. Major**
- **Scope:** 06-build-spec.md › M3 (line 63)
- **Claim:** `npx @better-auth/cli generate --config src/lib/auth.ts --yes`
- **Verdict:** Outdated
- **Source:** https://registry.npmjs.org/@better-auth/cli/latest (marked deprecated: "Package no longer supported"); https://www.better-auth.com/docs/concepts/cli
- **Correction:** `npx auth@latest generate --config src/lib/auth.ts --yes`. It takes the same `--config` and `--yes` flags. The Strapi tutorial still uses `npx -y @better-auth/cli …`, so if the new CLI fails with the Strapi adapter, fall back to that.

**3. Nit (not in docs)**
- **Scope:** 06-build-spec.md › M3 line 64, Env vars line 117, Auth/Deployment
- **Claim:** The Strapi side sets `BETTER_AUTH_URL` as the base URL.
- **Verdict:** Unverifiable
- **Source:** The Strapi tutorial (https://strapi.io/blog/strapi-better-auth-tutorial-setup-guide-for-strapi-v5-and-next-js-16) uses `STRAPI_URL` → `baseURL`, and `BETTER_AUTH_URL` doesn't appear in it. Better Auth does read `BETTER_AUTH_URL` natively (https://www.better-auth.com/docs/installation).
- **Correction:** Say which one the build uses. If the builder copies the tutorial's `auth.ts`, set `STRAPI_URL` as well, or change `baseURL` to read `BETTER_AUTH_URL`.

**4. Nit (not in docs)**
- **Scope:** 06-build-spec.md › M4 (line 71)
- **Claim:** The Report controller stamps `author` from `ctx.state.user`, with Better Auth installed and Users & Permissions (U&P) removed.
- **Verdict:** Unverifiable
- **Source:** None found. The tutorial never says how controllers read the signed-in user.
- **Correction:** Check what `plugin-better-auth` / `plugin-api-permissions` puts on `ctx.state` before relying on `ctx.state.user`.

**5. Nit (not in docs)**
- **Scope:** 06-build-spec.md › Environment variables (line 116)
- **Claim:** "`DATABASE_URL` (Strapi Cloud injects)"
- **Verdict:** Unverifiable
- **Source:** https://docs.strapi.io/cloud/getting-started/deployment says Cloud provides a default PostgreSQL database and lets you override it with `DATABASE_*` variables. It doesn't say Cloud injects `DATABASE_URL`.
- **Correction:** Don't set any database variables on Cloud so it uses its default database. Don't depend on `DATABASE_URL` being present.

Checked 23 claims; 18 confirmed.
