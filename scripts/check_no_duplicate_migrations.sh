#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="migrations"

echo "🔍 Validating sequential migration numbering..."

files=($(ls "$MIGRATIONS_DIR" | grep -E '^[0-9]+_.*\.sql$' | sort))
counter=1
errors=0

for file in "${files[@]}"; do
  expected=$(printf "%04d" "$counter")
  current=$(echo "$file" | cut -d'_' -f1)

  if [[ "$current" != "$expected" ]]; then
    echo "❌ Expected prefix $expected but found $current in $file"
    errors=1
  fi

  counter=$((counter + 1))
done

if [[ "$errors" -eq 0 ]]; then
  echo "✅ Migration numbers sequential and unique"
else
  exit 1
fi
