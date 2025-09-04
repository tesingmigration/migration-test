#!/bin/bash
# Script to assign next sequential migration number to a newly created file

MIGRATIONS_DIR="controlp/internal/cookiedb/migrations_postgres"
cd "$MIGRATIONS_DIR" || { echo "Directory not found"; exit 1; }

# Find all migration files and their prefixes
files=( $(ls | grep -E '^[0-9]{4}_.+\.sql$' | sort) )

# Determine next prefix
if [ ${#files[@]} -eq 0 ]; then
  next_prefix=1
else
  # Get highest prefix number
  highest=$(printf "%s\n" "${files[@]}" | sed -E 's/^0*([0-9]+)_.*/\1/' | sort -n | tail -1)
  next_prefix=$((highest + 1))
fi

# Detect the newly created file (most recently modified)
new_file=$(ls -t | grep -E '^[0-9]{4}_.+\.sql$' | head -1)

# Extract suffix
suffix=$(echo "$new_file" | sed -E 's/^[0-9]{4}_(.*)\.sql/\1/')

# Rename the new file to next sequential number
new_name=$(printf "%04d_%s.sql" "$next_prefix" "$suffix")
echo "Renaming $new_file -> $new_name"
mv "$new_file" "$new_name"
