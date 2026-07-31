#!/usr/bin/env bash
# Validate every skills/*/SKILL.md has the required frontmatter fields.
set -euo pipefail

status=0

for skill_dir in skills/*/; do
  name="$(basename "$skill_dir")"
  file="${skill_dir}SKILL.md"

  if [[ ! -f "$file" ]]; then
    echo "FAIL: $skill_dir has no SKILL.md"
    status=1
    continue
  fi

  if ! head -n1 "$file" | grep -q '^---$'; then
    echo "FAIL: $file missing frontmatter opening ---"
    status=1
    continue
  fi

  frontmatter="$(awk '/^---$/{c++; next} c==1' "$file")"

  if ! grep -q '^name:' <<<"$frontmatter"; then
    echo "FAIL: $file missing 'name' in frontmatter"
    status=1
  fi

  if ! grep -q '^description:' <<<"$frontmatter"; then
    echo "FAIL: $file missing 'description' in frontmatter"
    status=1
  fi

  fm_name="$(grep '^name:' <<<"$frontmatter" | head -n1 | sed 's/^name: *//')"
  if [[ -n "$fm_name" && "$fm_name" != "$name" ]]; then
    echo "FAIL: $file name '$fm_name' does not match folder '$name'"
    status=1
  fi
done

if [[ $status -eq 0 ]]; then
  echo "OK: all skills valid"
fi

exit $status
