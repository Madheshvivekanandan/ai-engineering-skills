# Contributing

## Adding a new skill

1. Create a folder: `skills/<kebab-case-name>/`.
2. Add `skills/<kebab-case-name>/SKILL.md` with frontmatter:

   ```markdown
   ---
   name: <kebab-case-name>
   description: <One or two sentences. State exactly when this skill should
     load — file types, frameworks, task shapes — so an assistant's skill
     router can match it reliably. Be specific, not aspirational.>
   ---

   # <Title>

   ...guidance...
   ```

3. Keep guidance opinionated and actionable — concrete rules, short
   examples, a review checklist — not a survey of options. State exceptions
   ("when this document conflicts with an existing in-repo convention,
   follow the repo") explicitly.
4. If the skill needs supporting material, put it under
   `skills/<name>/references/` and link to it from `SKILL.md`; keep
   executable helpers under `skills/<name>/scripts/`.
5. Add a row to the table in [README.md](README.md).
6. Run the lint check locally before opening a PR:

   ```bash
   ./scripts/lint-skills.sh
   ```

## Editing an existing skill

- Keep changes scoped to one logical update per PR.
- If you're changing a rule (not just wording), say why in the PR
  description — these documents get reused verbatim in other people's
  projects, so silent behavior changes are surprising.

## Style

- Markdown, GitHub-flavored. Wrap prose naturally; don't hard-wrap.
- Prefer tables and short code blocks over long prose.
- No emojis.
