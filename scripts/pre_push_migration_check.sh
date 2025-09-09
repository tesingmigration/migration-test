#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Pre-push: Validating migrations..."

# Get staged migration files, ignoring deletions
staged_files=$(git diff --cached --name-status | grep -P "^[AMR]\t$MIGRATIONS_DIR/" | cut -f2 || true)

if [[ -z "$staged_files" ]]; then
  echo "✅ No added/modified migration files staged"
  exit 0
fi

file_count=$(echo "$staged_files" | wc -l | tr -d ' ')

if [[ "$file_count" -gt 1 ]]; then
  for file in $staged_files; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^[0-9]+_.* ]]; then
      echo "❌ Multiple migration files staged and $basename has no numeric prefix."
      echo "👉 Please ensure all migration files have numeric prefixes."
      exit 1
    fi
  done
fi

# Run renumbering (handles single unprefixed too)
bash scripts/renumber_migrations.sh

# If renumbering changed things, commit the fix
if [[ -n "$(git status --porcelain $MIGRATIONS_DIR)" ]]; then
  echo "♻️ Renumbering adjusted migration filenames. Adding changes..."
  git add "$MIGRATIONS_DIR"
  git commit -m "chore: auto-renumber migrations [pre-push]"
  echo "❌ Push aborted. Renumber commit created. Please push again."
  exit 1
fi

# Final validation (duplicate check, etc.)
bash scripts/check_no_duplicate_migrations.sh

echo "✅ Pre-push migration validation passed"
