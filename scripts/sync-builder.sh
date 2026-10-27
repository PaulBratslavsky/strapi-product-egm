#!/usr/bin/env bash
# Re-copy strapi-product-builder from a strapi/skills checkout into skills/strapi-product-egm/builder/.
#
# Usage: scripts/sync-builder.sh <path-to-strapi-skills-checkout> [git-ref]
#   git-ref defaults to origin/main. Set SRC_PATH if the builder moves upstream.
set -euo pipefail

SRC_REPO="${1:?usage: scripts/sync-builder.sh <path-to-strapi-skills-checkout> [git-ref]}"
REF="${2:-origin/main}"
SRC_PATH="${SRC_PATH:-skills/in-progress/strapi-product-builder}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/skills/strapi-product-egm/builder"

git -C "$SRC_REPO" fetch --quiet origin || echo "warning: fetch failed, using local refs" >&2
COMMIT="$(git -C "$SRC_REPO" rev-parse "$REF")"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git -C "$SRC_REPO" archive "$COMMIT" "$SRC_PATH" | tar -x -C "$TMP"
SRC="$TMP/$SRC_PATH"
[ -f "$SRC/SKILL.md" ] || { echo "error: no SKILL.md at $SRC_PATH in $COMMIT" >&2; exit 1; }

rm -rf "$DEST/references" "$DEST/templates" "$DEST/examples" "$DEST/BUILDER.md"
cp "$SRC/SKILL.md" "$DEST/BUILDER.md"
cp -R "$SRC/references" "$SRC/templates" "$SRC/examples" "$DEST/"

# Record the synced commit in SOURCE.md.
sed -i.bak -E "s|^- \*\*Commit:\*\* .*|- **Commit:** \`$COMMIT\`|" "$DEST/SOURCE.md"
rm -f "$DEST/SOURCE.md.bak"

echo "Synced builder from $SRC_PATH @ $COMMIT"
echo "Review the changes: git diff --stat -- skills/strapi-product-egm/builder"
