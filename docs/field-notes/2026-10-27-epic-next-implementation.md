# Field note: implementing the change spec on epic-next-course (E8, 2026-10-27)

The change spec from the existing-app run (see `2026-10-27-existing-app-epic-next.md`) was implemented on a copy of the app. Branch `egm/harden-accounts-credits`, one commit per milestone, nothing pushed. The implementation log is in the run folder: `docs/designs/epic-next-course/reviews/E8-implementation-log.md`.

**Result:** all five milestones were implemented as written, with no deviations, and every check passed. Generation was tested with no OpenAI key (the refund path) and against a local mock of the OpenAI API (the success path, and the double-spend race: 8 parallel requests with 2 credits gave exactly 2 summaries).

## What E8 showed about the method

- The goldfish checkpoints worked. Nothing the reviewers had passed failed in implementation. Every STOP guard was checked against the installed code, and none triggered.
- The weak spots were outside the reviews: running the app, the test environment, and a claim the Elephant made without checking it.

## Lessons

### L1 — Don't call a runtime unsupported, or switch runtimes, because of a declaration such as `engines`: try it first, or mark it "not verified"
- **Seen:** epic-next copy, E8 setup, 2026-10-27
- **Evidence:** The Elephant switched to Node 22 and told the user the backend "doesn't run on Node 24", based only on `"engines": { "node": ">=18.0.0 <=22.x.x" }`. Node 24 was never tried. The owner caught it.
- **Target:** `SKILL.md` Elephant rules; `existing-app-mode.md` E8 baseline; `strapi-change-spec-standard.md` §8; `lenses/strapi-fact-checker.md`; `as-built-standard.md` §6
- **Scope:** general
- **Status:** applied in v0.2.4

### L2 — Run a baseline (install, boot, build, core loop) before the first milestone
- **Seen:** epic-next copy, E8 setup
- **Evidence:** The copy didn't boot as cloned: `types/generated/` and `public/uploads/` were missing, and `yarn build` failed on unchanged code (`credits` unknown in `on-summary-create.ts`). Without a baseline, these would have looked like milestone bugs.
- **Target:** `existing-app-mode.md` E8 step 3
- **Scope:** Strapi 5
- **Status:** applied in v0.2.4

### L3 — During the baseline, try every external call the core loop depends on
- **Seen:** epic-next copy, M4 UI check
- **Evidence:** `youtubei.js` 15.0.1 gets HTTP 400 from YouTube for every video, so the app's core loop was already broken before the change. It was found only at M4; R and B couldn't see it from code alone.
- **Target:** `existing-app-mode.md` E8 step 3
- **Scope:** general
- **Status:** applied in v0.2.4

### L4 — Give every admin-panel check a scripted version
- **Seen:** epic-next change spec, M2 and M4 checks
- **Evidence:** Creating an admin, ticking a permission and setting credits were written as admin-panel clicks. The agent ran them as database inserts and updates on the local test DB instead.
- **Target:** `strapi-change-spec-standard.md` §7; `existing-app-mode.md` "Running the checks"
- **Scope:** general
- **Status:** applied in v0.2.4

### L5 — Check JSON with `jq`, not `grep` on formatted text
- **Seen:** epic-next change spec, M4 check
- **Evidence:** `grep -o '"maxDuration":[0-9]*'` printed no value: the manifest is pretty-printed as `"maxDuration": 150`. `jq` showed all routes at 150.
- **Target:** `strapi-change-spec-standard.md` §7
- **Scope:** general
- **Status:** applied in v0.2.4

### L6 — Test third-party API paths without production keys: no key for the failure path, a local mock for success
- **Seen:** epic-next copy, M4
- **Evidence:** The spec's success and race checks assumed a real OpenAI key. A 40-line local mock, reached through `OPENAI_BASE_URL` with a fake key, covered the success path, the race, and the UI redirect.
- **Target:** `strapi-change-spec-standard.md` §7; `existing-app-mode.md` "Running the checks"
- **Scope:** general (the base-URL variable name depends on the SDK)
- **Status:** applied in v0.2.4

### L7 — Restart Strapi after backend edits, and confirm the new code is live
- **Seen:** epic-next copy, M3
- **Evidence:** `strapi develop` didn't reload after new files in `src/api/profile/`. The new route returned 405 until a manual restart.
- **Target:** `existing-app-mode.md` "Running the checks"
- **Scope:** Strapi 5 (seen on 5.21)
- **Status:** applied in v0.2.4

## Goldfish check of the v0.2.4 edit

One fresh `egm:egm-comprehension` reviewer checked the changed `SKILL.md`, `learning-loop.md`, `existing-app-mode.md` and the change-spec standard against this note. It found 🔴 1 · 🟡 12 · 🟢 9. All but two were fixed before commit.

- **Blocker:** the new E8 baseline said "try every external call (… payment provider, email)" and "boot the way the README says", but nothing stopped the boot from using a production `.env`, which the agent may not read. Fixed:
  - the baseline runs under every "Running the checks" rule;
  - database variables are set explicitly on the command line;
  - the agent asks the user once whether `.env` points at production;
  - external calls are limited to read-only or test-mode calls, with no real charge or email.
- **Majors fixed:**
  - "Check before you claim" and lesson reuse sat in steps that existing-app and review-only modes skip.
  - The rule was broader than its evidence, and it clashed with "read-only until E8".
  - A yarn `engines` refusal could still trigger the Node switch.
  - Lesson statuses had no "open" definition and no scope matching.
  - Three files disagreed on where lessons go.
  - Reused lessons could have overridden the safety rules.
  - Scripted permission "ticks" could be mistaken for seeding.
  - E2 citations could state `engines` as fact.
  - The mock wasn't specified in the spec standard.
- **Not reviewed:** the one-line edits to `lenses/strapi-fact-checker.md` and `standards/as-built-standard.md` (L1) weren't among the reviewer's targets.
- **Lesson about the loop itself:** the Elephant's own skill edit had a safety Blocker, just as its change spec did at checkpoint C. Goldfish-checking skill edits (learning-loop §3 step 5) is necessary.

## Held (app-specific, not skill lessons)

- `extractYouTubeID` rejects `youtu.be` short links. That's an app bug, for the owner.
- The escalated old-cookie (`Domain=`) problem couldn't be reproduced on localhost. It still needs a check on a real domain.
