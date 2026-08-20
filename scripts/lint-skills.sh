#!/usr/bin/env bash
# Validate every skills/*/SKILL.md has frontmatter that is present, correct, and
# actually parses as YAML. The last part matters: an assistant that cannot parse
# the frontmatter cannot load the skill at all, and the failure is silent.
set -euo pipefail

status=0

# Parse a YAML document on stdin. Prints the parser error and returns non-zero on
# failure; returns 0 (skipping the check) when no parser is available.
parse_yaml() {
  if python3 -c 'import yaml' 2>/dev/null; then
    python3 -c 'import sys, yaml; yaml.safe_load(sys.stdin.read())'
  elif command -v ruby >/dev/null 2>&1; then
    ruby -ryaml -e 'YAML.safe_load($stdin.read)'
  else
    cat >/dev/null
  fi
}

if ! python3 -c 'import yaml' 2>/dev/null && ! command -v ruby >/dev/null 2>&1; then
  echo "NOTE: no YAML parser found (python3+pyyaml or ruby); running text checks only"
fi

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

  # An unquoted YAML scalar may not contain ": " or " #" — the first is read as a
  # nested mapping, the second starts a comment. Both break the whole document.
  # Checked as text so this still fires with no YAML parser installed.
  while IFS= read -r line; do
    key="${line%%:*}"
    value="${line#*: }"
    case "$value" in
      '"'*|"'"*|'|'*|'>'*) continue ;;
    esac
    if [[ "$value" == *": "* ]]; then
      echo "FAIL: $file frontmatter '$key' has ': ' inside an unquoted value."
      echo "      YAML reads that as a nested mapping and the document fails to parse."
      echo "      Use a dash instead, or quote the whole value."
      status=1
    fi
    if [[ "$value" == *" #"* ]]; then
      echo "FAIL: $file frontmatter '$key' has ' #' inside an unquoted value,"
      echo "      which YAML treats as the start of a comment. Quote the value."
      status=1
    fi
  done < <(grep -E '^[[:space:]]*[A-Za-z_][A-Za-z0-9_-]*: .' <<<"$frontmatter" || true)

  # Defence in depth: a real parse catches anything the text checks miss.
  if ! err="$(parse_yaml <<<"$frontmatter" 2>&1)"; then
    echo "FAIL: $file frontmatter is not valid YAML"
    sed 's/^/      /' <<<"$err" | head -n 4
    status=1
  fi

  # The pointer left behind when references moved out must actually resolve.
  if grep -q 'references/sources\.md' "$file" && [[ ! -f "${skill_dir}references/sources.md" ]]; then
    echo "FAIL: $file links references/sources.md but ${skill_dir}references/sources.md is missing"
    status=1
  fi
done

if [[ $status -eq 0 ]]; then
  echo "OK: all skills valid"
fi

exit $status
