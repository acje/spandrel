#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

echo "==> Running git fsck --no-reflogs..."
git fsck --no-reflogs

echo "==> Running conformance vector check..."
node -e 'JSON.parse(require("fs").readFileSync("conformance/vectors/projection-fold.draft.json"))'

echo "==> All spandrel verification checks passed."
