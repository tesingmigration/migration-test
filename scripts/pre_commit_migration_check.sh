#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Pre-commit: Checking staged migration file names..."

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
      echo "👉 Please add prefixes before committing."
      exit 1
    fi
  done
fi

echo "✅ Pre-commit check passed"
