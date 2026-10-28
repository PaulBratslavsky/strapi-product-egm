# Field note: existing-app mode on epic-next-course (2026-10-27)

> **Update:** the change spec was later implemented (E8). See `2026-10-27-epic-next-implementation.md`.

First full test of existing-app mode on a copy of the Epic Next.js + Strapi 5 course app (Strapi 5.21.0, Next.js 15.4.6; about 5,500 lines). The runner acted as owner. Stopped before implementation (E8). The full docs, reports and the change spec stayed in the run folder.

**Run:** 2026-10-27 · strapi-product-egm 0.2.x · EGM v0.1.0 · copy of `epic-next-course` @ `89ed75e`. The runner acted as owner (goal G1 set by the runner, marked unconfirmed). Nothing was implemented.

## Checkpoint R — 2026-10-27
- **Findings:** 🔴 4 · 🟡 10 · 🟢 7 → all applied as factual corrections; 2 ⚠️ left for the owner
- **Lesson:** the first-draft reconstruction got the session flow wrong (it said "server action"; in fact the browser calls Strapi with a token it fetched). Without R, B would have reviewed fiction. **R is essential.**

## Checkpoint B — 2026-10-27
- **Findings:** 🔴 7 · 🟡 13 · 🟢 10 → 10 into the change spec, 3 escalated, 7 deferred
- **Highest-value findings:**
  - account takeover through stock `PUT /api/users/:id` (fact-checker read 5.21 source to confirm);
  - unbounded OpenAI spend (zoom-out named the root cause);
  - Strapi and Next.js security advisories (fact-checker, when asked to look).
- **Reviewer quality:** all four lenses added unique value. The code auditor ran as a general-purpose agent (dispatch option 2) and still found traps with file:line evidence.

## Checkpoint C — 2026-10-27
- **Findings:** 🔴 4 · 🟡 9 · 🟢 14 → 25 fixed, 1 contested, 1 escalated, 1 declined
- **Lesson:** the Elephant's own change spec had a build-breaking type error and a new stored-XSS hole. Two reviewers found both independently. **C is essential even when the author is careful.**

## Lessons for strapi-product-egm
- Make the fact-checker always check installed versions for security advisories in existing-app mode (done).
- Lead reports with root causes (done).
- The fact-checker tried to send docs feedback through an MCP tool; it's now limited to docs search (done).
- Add to the change-spec standard: new code must compile under the project's TypeScript settings; upload validation checks extension and file bytes, not the declared type; verification never deletes local data.
- Reviewers are slow on real code (R about 11 min; B and C about 6–15 min each in parallel; two B reviewers took much longer in wall-clock time). Tell users to expect this.

## Totals

| Checkpoint | Blockers | Majors | Nits | Reviewers |
|---|---|---|---|---|
| R (reconstruction) | 4 | 10 | 7 | codebase-details |
| B (design + code) | 7 | 13 | 10 | design, zoom-out, code auditor, fact-checker |
| C (change spec) | 4 | 9 | 14 | implementation-readiness, codebase-details, fact-checker |

The change spec has 5 milestones: stop logging secrets; Users & Permissions grants in code; an own-profile API instead of stock user update and upload; summary generation as one server-side operation with an atomic credit charge and refund; session hardening. Upgrades (Strapi and Next.js security advisories) are a separate change, done first.
