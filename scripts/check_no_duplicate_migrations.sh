#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Checking for duplicate migration numbers..."

# Extract numeric prefixes
prefixes=$(find "$MIGRATIONS_DIR" -type f -name '*.sql' \
  | sed -E 's|.*/([0-9]+)_.*|\1|' \
  | sort)

# Look for duplicates
dupes=$(echo "$prefixes" | uniq -d || true)

if [[ -n "$dupes" ]]; then
  echo "❌ Duplicate migration numbers detected:"
  echo "$dupes"
  exit 1
fi

echo "✅ No duplicate migration numbers"
