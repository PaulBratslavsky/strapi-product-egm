# Strapi Change-Spec Standard

**Applies to:** `06-change-spec.md` in existing-app mode, read together with the codebase.
**Based on:** EGM's implementation-readiness standard (the zero-decision rule and phasing), plus what changing a live Strapi app requires.

## Core principle

The spec passes if a coding agent with **this spec, the codebase, and the official docs** can make every change correctly on the first attempt — without making design decisions, and without breaking existing data or clients.

Severity guide: anything that could lose data, break a core flow, or leave a security hole open is a **Blocker**. Anything that forces the agent to guess is a **Major**.

## 1. Zero-decision rule

Flag every place where the implementer would have to choose: a field type, a route path, where logic lives, a library, an error or empty-state behaviour, a name.

## 2. Scope

- **Goals** list the user's change goals and the accepted review findings, by ID (for example `B-4`).
- **Every change traces to a goal.** Unrelated refactors or "while we're here" changes are a Major.
- **Non-goals** list the deferred findings.

## 3. Every change names its files

Each edit lists the exact files and the change, as code or a precise description. Paths to existing files must exist in the codebase; new files say where they go. A wrong or missing path is a Blocker.

## 4. Every caller is updated

A change to a schema, a route, a response shape, a permission, or an environment variable lists **every** place that uses it — frontend data helpers, components, seed scripts, tests, MCP tools — and updates them in the same milestone. A missed caller is a Major, or a Blocker if it breaks a core flow.

## 5. Data safety

- **Schema changes** say what happens to existing rows: default values, backfills. Strapi doesn't migrate data for a renamed or retyped field — the spec moves the data explicitly. Possible data loss is a Blocker.
- **Data migrations** go in `database/migrations` (they run on startup) or in a one-off script, and the spec says how to test them on a copy of real data.
- **New unique constraints** first find and merge existing duplicates.
- **Permission changes** are seeded in code (`bootstrap()`), not clicked in the admin panel.
- **Destructive steps** come with a backup step. Every milestone has a rollback — revert the commit and undo the data step — or says plainly that it can't be rolled back.

## 6. Milestones

- **Ordered:** data and schema before the code that needs them; backend before the frontend that calls it.
- **Each one leaves the app bootable**, and is committed on its own.
- **Each has a "Done when"** that a command, a request, or a test can check.

## 7. Verification

Each milestone says how to verify it: HTTP requests with the expected status, a test command, or a UI step. **Security fixes include a negative test** — for example, another user's record returns 403, or `?populate=*` returns no email.

## 8. Header

- The **deviation protocol**: if the code makes a step wrong or impossible, stop and ask; don't improvise.
- **Docs lookup:** the `strapi-docs` MCP or https://docs.strapi.io, plus the frontend framework's docs.
- **Safety:** work on a branch, don't push, never use production data or credentials.

## 9. Deployment

- Environment variables added, changed, or removed, for each environment.
- Deploy order (for example, the backend first when the frontend depends on a new endpoint).
- When migrations run, and any host-specific steps (Strapi Cloud, Docker).
