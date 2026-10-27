# Vendored: strapi-product-builder

This folder is a copy of the `strapi-product-builder` skill. The EGM skill (`../SKILL.md`) runs it as its interview and adds goldfish reviews on top.

- **Upstream:** https://github.com/strapi/skills — `skills/in-progress/strapi-product-builder`
- **Commit:** `6dacea481ab3c65f33b1020301491cd92904aa52`

## What changed from upstream

- `SKILL.md` is renamed to `BUILDER.md`, so agents don't load it as a second skill.
- The upstream `README.md` (install docs) and `scripts/` (placeholder) are not copied.
- Nothing else. Don't edit these files here — change the EGM skill, or change the builder upstream and re-sync.

## Paths

Paths inside `BUILDER.md` (`references/…`, `templates/…`, `examples/…`) are relative to this folder.

## Re-sync

```bash
scripts/sync-builder.sh /path/to/strapi-skills-checkout            # default ref: origin/main
scripts/sync-builder.sh /path/to/strapi-skills-checkout my-branch  # any ref
```

The script replaces this folder's copied files and updates the commit above. Review the diff before committing.
