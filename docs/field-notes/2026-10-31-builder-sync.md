# Field note: builder re-synced, standards catch up (2026-10-31, v0.3.1)

## Why

The strapi-product-builder pull request (https://github.com/strapi/skills/pull/10, still a draft) folds in the lessons from this skill's reviews, plus a final build-readiness review of its own. `builder/` was still the copy from `6dacea4`, so this skill ran the old interview. And one of its own rules was unsafe: it told reviewers a read-only token was right for public reads.

## What changed

| Where | Change |
|---|---|
| `builder/` | Synced from the PR branch at `648a079`, not `main` (see `SOURCE.md`). |
| `SKILL.md` stage overrides | Removed stage 1 (three questions), stage 6 (inlining, scaffold flags) and most of stage 5: the builder does them now. Stage 5 keeps one line: the Outside services table also gives the side that calls each service, its key's env var, and how the team finds out about a failure (§10). |
| Design standard §9 | A public read that sends a token uses a custom token limited to its read actions. Read-only is now a Major, like full-access. |
| Design standard §4 | No Public upload action. U&P never grants `user.update` (a Blocker), and sets Strapi's `url` when email confirmation or social login is on. Better Auth's generated `user` UID may be left to a build step after the generate step. |
| Build-spec standard §5, §7 | Schema paths and core files; on Better Auth, every type created before auth, with user-targeting attributes added later as one-way relations; permissions seeded in `bootstrap()`; the first admin right after the first deploy; a custom frontend token; U&P's `url`. |
| Lenses | The frontend auditor sends the token's type to **To confirm**. The code auditor searches for `user.update`, upload grants, and a missing `url`. |
| `existing-app-mode.md` | The as-built 05 fills in the template's own sections instead of adding them. |

## Sources

Read in the Strapi v5 source (develop branch) for the builder PR:

- **Read-only tokens:** `packages/core/admin/server/src/strategies/content-api-token.ts`, where `isReadScope` passes any action ending in `find` or `findOne`.
- **Upload:** `packages/core/utils/src/sanitize/visitors/remove-restricted-relations.ts` and `validate/visitors/throw-restricted-relations.ts` only check `relation` attributes, so media fields populate without upload `find`.
- **`url`:** `packages/core/core/src/configuration/urls.ts`, and U&P's `server/src/services/providers.js` and `services/user.js`.
- **`user.update`:** found exploitable on Strapi 5.21 during a review, and confirmed in the v5 source.

## How it was checked

A fresh reviewer read this change against the synced builder: five Majors, no Blockers, all fixed in this version. The fixes weren't reviewed again.

## Not verified

- A run of either mode with the synced builder.
- The re-sync from `main` once the PR merges; the PR may still change.
