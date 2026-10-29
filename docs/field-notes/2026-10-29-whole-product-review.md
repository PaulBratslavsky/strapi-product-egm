# Field note: reviews cover the whole product (2026-10-29, v0.3.0)

## Why

The owner's direction: this skill plans a whole product, not only a Strapi app. The product is the whole system: the Strapi backend, the frontend, other apps, outside services, and hosting.

Before this change:

- **The planning interview already covered the whole product.** Stages 4–6 ask about the frontend, hosting, CI, payments, and email.
- **The reviews mostly checked Strapi.** The design standard had two frontend rules: the framework is chosen explicitly, and server tokens get no public prefix. The code auditor looked only for Strapi problems. In existing-app mode, the as-built docs covered only "frontend routes that call Strapi, and how the frontend sends the session", so pages, workers, and other services were never described or reviewed.

This is a change of scope, not a lesson from one run. So each new rule below names its source.

## What changed

| File | Change |
|---|---|
| `standards/strapi-design-standard.md` | Says it covers the whole product. New sections: §9 Frontend, §10 Outside services and other apps, §11 Hosting and environments. Risks moves from §9 to §12. §7 adds that an N/A in the sweep doesn't waive §9 or §10. |
| `standards/as-built-standard.md` | Coverage lists every app in the repo: each frontend's full route tree, server handlers, the session from sign-in to expiry, outside services, CORS, hosting and deploy config, and tests. Adds the `⚠️ framework behavior` marker. |
| `standards/strapi-build-spec-standard.md` | Frontend milestones name their routes and data calls. Protected routes also name the server-side session check, and core-loop routes their loading, empty, and error states. Adds CORS origins per environment, and a test mode for each outside service. |
| `standards/strapi-change-spec-standard.md` | Frontend changes are verified through the frontend. Core-loop page changes name their states. |
| `references/existing-app-mode.md` | E1 maps the whole repo and asks about parts in other repos. E2 adds the new 05 sections. B adds the frontend auditor, and the mode note says to judge the whole product. The E8 safety question covers every app's env files and the Strapi URL each frontend uses. The baseline boots every app the core loop needs, pointed at the local Strapi. |
| `references/checkpoints.md` | Codebase line is every app root. The frontend auditor's full prompt is given. Cost: R runs one subagent; the others run three to five. |
| `lenses/frontend-auditor.md`, `agents/frontend-auditor.md` | New goldfish lens: audits the code outside the Strapi app against §6–11, with file:line evidence. |
| `lenses/strapi-code-auditor.md` | Adds the rule never to open `.env` files or quote secret or personal values. |
| `SKILL.md` | Description and modes table say "whole product". The stage-5 override adds the new 05 sections. |
| `README.md`, `.claude-plugin/*.json` | Wording: the whole product. The existing-app prompt asks for the whole repo. |

## Sources for the new rules

"Test run" means the 2026-10-29 audit of `strapi-5-next-15-store` below.

| Rule | Source |
|---|---|
| Session decided end to end; the cross-site choice | Trailhead full review: two lenses flagged the undecided session topology as a Blocker. Epic Next checkpoint R: the first reconstruction got the session flow wrong. Test run, finding 2: the cookie domain breaks sign-up and sign-out outside localhost. |
| Session cookie flags | Test run, finding 2: the sign-in cookie had no `httpOnly`, `secure`, or `sameSite` flag. |
| Access enforced on the server; handlers don't widen access | Test run, findings 1 and 8: "my cart" was only a filter the client sent, the owner came from the request body, and `/order` had no server-side check. |
| CORS origins, no wildcard with credentials | Trailhead checkpoint C: CORS origins and `credentials` were left to the build agent. Test run, finding 13: a bare `strapi::cors` entry. |
| Loading, empty, and error states on core-loop pages | Trailhead checkpoint C, finding 9: empty and error states undefined. Test run, finding 7: no error, loading, or empty states. |
| Failure of a service the core loop depends on | Epic Next E8: `youtubei.js` failed for every video, and nothing showed it until the app ran. |
| Test mode for each outside service | Epic Next E8: OpenAI was tested through a local mock on its base-URL setting. The change-spec standard already required this for changes. |
| Environments listed, with the Strapi each frontend calls | Test run, findings 5, 6, and 14: two different Strapi URL variables, and images allowed only from localhost. |
| Other apps and scripts that write data | Test run, finding 12: a seed script that force-imports with no check of which database it targets. |
| Every route described | Builder stage 5 already asks for each route's data source; this makes it checkable. |
| Published content reaches the live site | Builder `references/frontend-frameworks.md` (refresh options per framework). **Not yet seen in a run.** The test app renders every page per request. |
| A preview that can write production data needs a reason; search metadata; CI | Builder stage 4 (hosting and CI/CD decisions) and the `shared.seo` component in its 05 template. **Not yet seen in a run as a rule**; the test run found no CI and boilerplate page titles. |
| Verify frontend changes through the frontend | **Not yet seen in a run.** |

## Goldfish check

One `egm:egm-comprehension` reviewer read every changed file: 🔴 2 · 🟡 9 · 🟢 15.

- **Blockers, both fixed:**
  1. The new lens searched for TOKEN, SECRET, and KEY names and quoted evidence, but never said to stay out of `.env` files. It could have copied a secret into a committed report. Both code auditors now get the rule.
  2. The E8 safety question asked only about "the local `.env`". A frontend pointed at production Strapi would have written production data during the baseline. Now it covers every app's env files and the Strapi URL each frontend uses, and the baseline points them at the local Strapi.
- **Majors, all fixed:**
  - the session-check rule was scoped to handlers that read private data or write on a user's behalf (exemptions for auth entry points, public reads, machine callers, and browser-only apps);
  - CORS covers proxy and server-only designs, defines a wildcard, and says how to handle previews;
  - the lens table now maps each check to a standard section, and §9 gained the cookie rules;
  - which folders each reviewer gets is consistent, and the frontend auditor's prompt is given in full;
  - an N/A in the sweep doesn't waive §9 or §10;
  - E2 adds the new 05 sections;
  - parts of the product in other repos are handled;
  - the test-mode rule allows a stub;
  - the Better Auth cookie line matches §9's options.
- **Nits:** 14 fixed. Declined one, on duplicate findings from the two code auditors counting as "two lenses agreeing": they are still two independent reviewers. E4 now says what each auditor owns.

**Second pass** (Blockers and Majors only, on the four most-changed files): 🔴 1 · 🟡 13, all fixed. Five were in older E8 text that this change made more pressing:

- **The Blocker:** "override, or leave unset" didn't unset anything, because Strapi and the frontend frameworks read their `.env` files themselves. So a baseline could have run with real payment or email keys. Overrides now apply on every command that loads env files, whatever the user answers, with empty or fake values.
- **Majors:**
  - Access is tied to where private data is read: on the frontend's server, or from the browser with the user's own credential.
  - Public reads with an API token: read-only passes, full-access is a Major, and a write or a passed-through visitor input is a Blocker.
  - An N/A passes only its own sweep line; "not handled" is graded as missing; "the product's value depends on it" is defined.
  - The frontend auditor may read named Strapi files, and reports settings outside the code under "To confirm", which become escalations.
  - Both auditors get 03 for the core loop.
  - The fact-checker gets lockfiles and installed packages.
  - Multi-repo products: a commit per repo, and the auditor rule is based on E1's app roots.
  - Every code-aware prompt carries a folder rule: no `.env` files, and no `node_modules` except to check an installed package.
  - E2 adds a "Session" subsection and a "Server-side handlers" table.
  - The mode note waives only 04's Considered and Why, not "needs a stated reason" rules.
  - Older E8 rules: a scratch database only, with database variable names taken from `config/database.*`; pre-existing admin-panel permissions may be inserted into the scratch database; the stub check looks for the stub's lines, not the whole file.

## Test run

The frontend auditor ran as a general-purpose subagent (dispatch option 2), from the first version of the lens. It reviewed a copy of `~/projects/strapi-5-next-15-store` (Next.js 15.0.0-rc.0 and Strapi 5.0.0-rc.12; 51 frontend TypeScript files). The copy had no `.env` files and no `node_modules`. No 05 existed, so it had no background file.

- **Result:** 🔴 3 · 🟡 11 · 🟢 2, every finding with file:line evidence. The highest-value findings:
  - any signed-in user could read every account's email and every customer's address, because "my cart" was only a filter the client sent;
  - the session cookie's domain broke sign-up and sign-out on any real domain;
  - checkout dropped quantities and prices;
  - checkout wasn't atomic, so it could create duplicate orders.
- **What the run changed in the lens:**
  - **Scope drift:** it reported problems that live in the Strapi app, such as the order data model and permissions. The lens now says to report Strapi-side problems only when frontend code depends on them, and to cite that code first.
  - **Personal data:** it read the seed archive, which holds user emails, password hashes, and addresses. It quoted no values, but the lens didn't forbid it. Now it does.
- **Not checked:** the updated lens hasn't been run again. One finding cites a security advisory by ID; it was marked for the fact-checker, and nobody has verified it.

## Upstream candidates (strapi-product-builder)

`builder/` is a synced copy, so these are for the pull request to `strapi/skills`, not edits here:

- 05 template: add "Outside services and other apps" and "Hosting and environments" sections.
- 05 template: in "Pages & components", give each route its access, data source and credential, rendering, and states.

Until then, this skill's stage-5 override and E2 ask for them.

## Not verified

- A full existing-app run (R → B → C) with the new rules and the five-reviewer B.
- New-product mode with the new 05 sections.
- The updated frontend-auditor lens (only its first version was run).
