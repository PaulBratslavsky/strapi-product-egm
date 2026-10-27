# [App name] — Change spec: [short title]

> **For the implementing agent.** You have the repo checked out. This spec plus the code and the official docs is everything you need.
> **Deviation protocol:** the files, commands, and structures in this spec are the owner's decisions. If the code makes a step wrong or impossible, STOP and ask — don't improvise a substitute.
> **Safety:** work on branch `egm/[short-name]`. Commit once per milestone. Don't push. Never use production data or credentials, and never print secrets.
> **Docs lookup:** the `strapi-docs` MCP, or https://docs.strapi.io (Strapi [version]); frontend: [framework docs URL]. Check version-sensitive APIs against the installed versions.
> **Based on:** `04`/`05` as built @ `[commit]`; findings from `reviews/B-design-review.md`.

## Goals

- **G1** (owner): [the user's change goal, in their words]
- **B-[n]** (finding): [one line — what's wrong and the intended outcome]

## Non-goals

- Deferred findings: **B-[n]** [one line — why it's deferred]
- [Anything else explicitly not changing]

## Current state

[The few facts these changes depend on, each with a file citation: Strapi and Node versions, frontend, auth path, hosting, relevant content types.]

## Milestones

### M1 — [title]

- **Why:** G1, B-[n]
- **Files:**
  - `[path]` — [what changes]

    ```ts
    // the exact code, or a diff
    ```

  - `[new path]` — new file: [purpose]
- **Data:** [migration or backfill with its file path, and how to test it on a copy of real data — or "none"]
- **Callers updated:** [every file that uses what changed — or "none"]
- **Verify:**
  - `[command or HTTP request]` → [expected result]
  - Negative test: `[request]` → [expected 401/403/no field]
- **Done when:** [one checkable sentence]
- **Rollback:** [revert the commit plus undo the data step — or "not reversible because …"]

### M2 — [title]

[same shape]

## Environment variables

| Variable | App | Change | Example value | Notes |
|---|---|---|---|---|
| `[NAME]` | backend / frontend | add / change / remove | `[example — never a real secret]` | [server-only, or browser-safe with the framework's public prefix] |

## Deployment

1. [Order — for example, deploy the backend first]
2. [When migrations run]
3. [Environment changes per environment, and host-specific steps]

## Open questions

- [Anything still unconfirmed — `⚠️` items carried over from the as-built docs]
