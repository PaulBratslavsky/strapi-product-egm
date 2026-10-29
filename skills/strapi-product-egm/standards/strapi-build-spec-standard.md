# Strapi Build-Spec Standard

**Applies to:** `06-build-spec.md` (stage 6), read on its own.
**Based on:** EGM's implementation-readiness standard (the zero-decision rule), plus `strapi-product-builder`'s stage 6 rules and build cookbook.

## Core principle

The spec passes if a coding agent that has **only this file and the official docs** (Strapi, plus the chosen frontend framework) can build the POC milestone by milestone without asking a question or making a design decision.

## 1. Zero-decision rule

Flag every place where the build agent would have to choose something itself: a field type, a relation's cardinality, a route path, a permission, where a piece of logic lives, a library, how an error or empty state behaves, an environment variable's name.

- **Blocker** if the choice affects the data model, auth, or permissions.
- **Major** otherwise.

## 2. Self-contained

- **No dead references.** Nothing points at a file the build agent can't open — other stage files, `references/…`, "the skill" — *in place of* the content. "See stage 5" where the schemas should be is a Blocker. A background mention ("decided in stage 4") is fine when the content itself is in this file.
- **Every term is defined.** Product-specific names, roles, and statuses are explained in the spec.
- **Non-obvious Strapi patterns are inline** in the milestone that needs them — as code or exact steps, not as a pointer. Check whichever of these the product uses:
  - stamping `owner` / `author` through the Document Service in the controller;
  - the `is-owner` policy, and owner-scoped reads through the Document Service;
  - slug generation in Document Service middleware for every slug that is filtered on;
  - seeding users who can log in, through the auth system's own service or sign-up API so passwords are hashed (Users & Permissions service, or Better Auth's sign-up API);
  - seeding permissions for both Public and Authenticated in code (Users & Permissions roles, or `plugin-api-permissions` on the Better Auth path);
  - a real database unique index for identity keys;
  - an overlap guard and retry cap on cron jobs;
  - transactions for multi-write workflow steps;
  - Better Auth path: `generateId: 'serial'`, Users & Permissions removed, the content-type generate step.

## 3. Header

- The **deviation protocol** is at the top: the commands, structures, and conventions in the spec are user decisions, and the build agent stops and asks before substituting any of them.
- The **docs lookup** names the `strapi-docs` MCP or https://docs.strapi.io **and** the chosen frontend's docs URL, and tells the agent to check version-sensitive conventions (file names, config keys, async APIs) against the current major version.

## 4. Setup

- The Strapi scaffold is `npx create-strapi-app@latest <dir>` run **non-interactively** (`--non-interactive --skip-cloud --dbclient=… --dbhost=… … --no-example --no-git-init`, or the current equivalents). Never `--quickstart`.
- `.env` covers the auth secrets for the chosen path (`JWT_SECRET` on the Users & Permissions path; the Better Auth secret and URLs on that path) and, for local SQLite, `DATABASE_FILENAME=.tmp/data.db`.
- No automated step uses `strapi generate`. It is interactive only, so a build agent hangs or does nothing; files are written directly.
- The frontend is scaffolded with the chosen framework's command.
- The repo layout is shown.

## 5. Milestones

- In order, and each has a **"Done when"** that a person or a test can check.
- Each milestone leaves the project bootable.
- Content types are given as `schema.json` (Content-Type Builder format); components as JSON under `src/components/<category>/`.
- The auth milestone matches the chosen path: Users & Permissions roles, or Better Auth's three plugins with Users & Permissions removed and providers configured.
- The seed milestone creates users who can log in (see section 2) and seeds both roles' permissions in code.
- Each frontend milestone names its routes and the data call behind each one. For protected routes, it says where the session is checked on the server; for core-loop routes, what users see while the page loads, with no data, and on error.

## 6. Internal consistency

The stack section, milestones, schemas, environment variables, and deployment steps agree: same framework, same auth path, same names throughout. Any mismatch is a Major.

## 7. Environment variables and deployment

- A full list for backend and frontend, each with a description and an example value. No real secrets.
- The public prefix (`NEXT_PUBLIC_`, `VITE_`, `PUBLIC_`, `NUXT_PUBLIC_`) appears only on browser-safe values. Server-only tokens are unprefixed — a prefixed `STRAPI_API_TOKEN` ships to the browser (Blocker).
- Deployment steps for the chosen backend host — Strapi Cloud (create the project, link the repo, set env vars, set the Node version) or self-hosted (Dockerfile and a Postgres service) — and for the frontend host.
- Better Auth path: `trustedOrigins`, and the cookie settings that the session option chosen in the design (shared parent domain or proxy) needs in production.
- Strapi's CORS settings list the exact origins whose browsers call Strapi directly, for each environment, or say "none" when every call goes through the frontend's server or a proxy.
- Each outside service has its environment variable names and the test mode used before launch (a sandbox or test key, a local mock, or a stub), so no milestone needs a production key.

## 8. Acceptance

- The POC acceptance criteria come from the core loop and can be tested.
- An end-to-end milestone turns them into tests that create their own data through the app's real entry points, so they don't depend on seed data.
- "Open questions / parked items" lists every `⚠️ assumption` that appears elsewhere in the spec.
