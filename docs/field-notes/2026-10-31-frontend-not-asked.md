# Field note: the frontend was never asked (2026-10-31, v0.3.2)

## What happened

A new-product run (a local audio-generation app, stage 4 on 2026-10-29) recorded Next.js as decided without asking the user which framework to use:

1. Stage 4 asked four questions in one message: what runs the model, the interface, where the model runs, and the database.
2. The interface question's first option was "A. A Next.js web app in your browser (recommended)". The others were a desktop wrapper and Strapi's admin panel. Other frameworks got one line at the end.
3. The user answered only the first question.
4. Later the agent listed its recommendations, starting with "your own screens, built in Next.js". The user replied "Use these", and 04 recorded Next.js as decided, with TanStack Start, Astro and Nuxt under "Considered".

The user noticed only once the build had started.

## Why the rule didn't hold

The builder said "Frontend — always ask, never assume", but the same stage also says to suggest options when the user is undecided. Nothing stopped the agent from folding the framework into another option, marking one framework as recommended, or counting a general approval as the choice. 04 still had **Choice · Considered · Why**, which was all this skill's design standard asked for.

## Changes

| Where | Change |
|---|---|
| Builder (https://github.com/strapi/skills/pull/10, commit `9f389bb`) | Stage 4 step 2: ask the framework as its own question and wait; mark no option as recommended unless the user asks; a general approval of a list doesn't pick it. The 04 template gets **Frontend framework › Chosen by**. |
| `builder/` | Re-synced at `9f389bb`. |
| Design standard §1 | **Chosen by** quotes the user's answer. Recommended only, or approved in a list, is a Major. As-built 04s say "pre-existing". |
| `existing-app-mode.md` | As-built 04s write "pre-existing" under **Chosen by**. |

## Not verified

- A stage 4 run with the new wording.
