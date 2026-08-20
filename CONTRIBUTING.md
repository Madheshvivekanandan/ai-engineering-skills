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
6. Record what you actually read in [SOURCES.md](SOURCES.md), under a heading for
   your skill. Two rules make that file worth having:

   - **Cite only what you opened.** If you found a page in search results but
     never read it, it is not a source. A short list of pages you actually read
     beats a long list you assembled from search titles.
   - **Give every entry a verification date**, and check the page still says what
     you claim. Vendor documentation gets reorganised — and some doc sites serve
     "page not found" with an HTTP 200, so a link checker will call a dead URL
     healthy. Open it.

   Group entries by how much authority they carry (specifications and RFCs first,
   then official vendor docs, then industry guidelines, then books), and note
   anything you could not verify rather than quietly dropping it. A reader should
   be able to tell the difference between a rule backed by an RFC and a rule
   backed by a blog post.
7. Run the lint check locally before opening a PR:

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
