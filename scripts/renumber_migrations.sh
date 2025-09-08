#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "♻️ Renumbering migration files in $MIGRATIONS_DIR..."

# Collect all migration files (prefix, prefixless, tmp_)
files=($(ls "$MIGRATIONS_DIR" | grep -E '(^[0-9]+_.*\.sql$|^tmp_.*\.sql$|^[^.].*\.sql$)' | sort))
counter=1
changed=0

for file in "${files[@]}"; do
  basename=$(basename "$file")

  # Case 1: Properly prefixed (0001_name.sql)
  if [[ "$basename" =~ ^[0-9]+_(.*)\.sql$ ]]; then
    suffix="${BASH_REMATCH[1]}"

  # Case 2: tmp_*name.sql (inserted by hooks/CI)
  elif [[ "$basename" =~ ^tmp_(.*)\.sql$ ]]; then
    suffix="${BASH_REMATCH[1]}"

  # Case 3: Prefixless but valid SQL file (e.g. add_users.sql)
  elif [[ "$basename" =~ ^(.*)\.sql$ ]]; then
    suffix="${BASH_REMATCH[1]}"

  else
    echo "⚠️ Skipping unexpected file format: $basename"
    continue
  fi

  expected=$(printf "%04d" "$counter")_"$suffix".sql
  if [[ "$basename" != "$expected" ]]; then
    echo "Renaming $basename → $expected"
    git mv "$MIGRATIONS_DIR/$basename" "$MIGRATIONS_DIR/$expected"
    changed=1
  fi

  counter=$((counter + 1))
done

if [[ "$changed" -eq 0 ]]; then
  echo "✅ No renumbering needed"
else
  echo "✅ Renumbering complete"
fi
