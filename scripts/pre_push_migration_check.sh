#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Pre-push: Validating migrations..."

staged_files=$(git diff --cached --name-only | grep "^$MIGRATIONS_DIR/" || true)

if [[ -z "$staged_files" ]]; then
  echo "✅ No migration files staged"
  exit 0
fi

file_count=$(echo "$staged_files" | wc -l | tr -d ' ')

if [[ "$file_count" -gt 1 ]]; then
  for file in $staged_files; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^[0-9]+_.*\.sql$ ]]; then
      echo "❌ Multiple migration files detected and $basename has no numeric prefix."
      exit 1
    fi
  done
fi

# Renumber migrations
bash scripts/renumber_migrations.sh

# Commit if changes were made
if [[ -n "$(git status --porcelain $MIGRATIONS_DIR)" ]]; then
  echo "♻️ Renumbering adjusted migration filenames. Adding changes..."
  git add "$MIGRATIONS_DIR"
  git commit -m "chore: auto-renumber migrations [pre-push]"
  echo "❌ Push aborted. Renumber commit created. Please push again."
  exit 1
fi

# Final validation
bash scripts/check_no_duplicate_migrations.sh

echo "✅ Pre-push migration validation passed"
