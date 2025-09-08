#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Renumbering migration files (resolving duplicates)..."

# Collect all migration files, excluding deletions
files=$(git ls-files -- "$MIGRATIONS_DIR" | sort)

if [[ -z "$files" ]]; then
  echo "✅ No migration files found"
  exit 0
fi

# Assign fresh sequential numbers
i=1
for f in $files; do
  dirname=$(dirname "$f")
  base=$(basename "$f")

  # Strip prefix if it exists
  name_without_prefix=$(echo "$base" | sed -E 's/^[0-9]+_//')

  # New number padded to 4 digits
  new_prefix=$(printf "%04d" $i)
  new_name="${new_prefix}_${name_without_prefix}"

  new_path="$dirname/$new_name"

  if [[ "$f" != "$new_path" ]]; then
    echo "♻️ Renaming $f → $new_path"
    git mv "$f" "$new_path"
  fi

  i=$((i + 1))
done

echo "✅ Renumbering complete"
