# Field note: builder gaps found while wiring up EGM (2026-10-27)

A fresh-context subagent reviewed this plugin against the vendored `strapi-product-builder` (commit `6dacea4`). Most of its findings were about this plugin and are fixed. These are about the builder itself; the plugin works around them with stage overrides in `SKILL.md`.

| Gap in strapi-product-builder | Where | Workaround here | Suggested builder change |
|---|---|---|---|
| Stage 6 says "reference [the other files] as background", and the 06 template carries "from stage 4/5" markers. The Trailhead spec ended up with "See stage 5" where its schemas should be. | `BUILDER.md` stage 6; `templates/06-build-spec.template.md` | Stage 6 override: never point at another file *instead of* the content | Require inline `schema.json` and permission seeding in 06; drop the stage markers from the template |
| The stage-6 scaffold reminder omits `--no-example --no-git-init`, which the cookbook says are needed for a fully non-interactive run. | `BUILDER.md` stage 6 reminder vs `references/strapi-build-cookbook.md` › Scaffold | Stage 6 override: use the cookbook's full flags | Fix the reminder and the 06 template |
| Declined robustness-sweep items have nowhere to go, so nothing records that the user decided them. | `BUILDER.md` robustness sweep; `templates/05-tech-requirements.template.md` | Stage 5 override: an "Operations (robustness sweep)" section in 05 | Add that section to the 05 template |
| Stage 1 never asks how the problem is handled today, what the riskiest assumption is, or what early signal shows it's working. | `BUILDER.md` stage 1; `templates/01-product.template.md` | Stage 1 override: three extra questions and sections, plus a Hypothesis section at the end of stage 3 | Add them to stage 1 and the 01 template if the reviews show they help |
| `content-modeling.md` says draft & publish is off by default; a reviewer said it's on by default in v5. | `references/content-modeling.md` › Draft & publish | None | Check against current docs and fix whichever is wrong |
