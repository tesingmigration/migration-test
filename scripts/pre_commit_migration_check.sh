#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Pre-commit: Checking staged migration file names..."

# Get all staged migration files (adds, modifies, deletes, renames)
staged_files=$(git diff --cached --name-status | grep -P "^[AMR]\t$MIGRATIONS_DIR/" || true)

if [[ -z "$staged_files" ]]; then
  echo "✅ No migration files staged for add/modify/rename"
  exit 0
fi

file_count=$(echo "$staged_files" | wc -l | tr -d ' ')

# Rule: if more than one file is added/modified/renamed,
#       all must have numeric prefixes
if [[ "$file_count" -gt 1 ]]; then
  while IFS=$'\t' read -r status file; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^[0-9]+_.* ]]; then
      echo "❌ Multiple migration files staged and $basename has no numeric prefix."
      echo "👉 Please ensure all migration files have numeric prefixes."
      exit 1
    fi
  done <<< "$staged_files"
fi

echo "✅ Pre-commit check passed"
