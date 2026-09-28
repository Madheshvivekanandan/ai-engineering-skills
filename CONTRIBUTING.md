# Contributing

## What belongs in a SKILL.md

A skill's body is loaded into a model's context every time it triggers, often alongside three or four other skills. Assume the reader is a Sonnet-class model or stronger: it already knows the textbook. A line earns its tokens only if it changes what that model would otherwise do.

**Keep:**

| Kind | Example |
|---|---|
| House decision: one choice among valid alternatives | Squash-merge by default; cursor pagination named `page_size`/`page_token`; one class per file |
| Threshold or number | Functions ≤ 30 lines; PRs ~100 changed lines; Argon2id `m ≥ 19 MiB, t = 2, p = 1` |
| Non-obvious gotcha: the model's default is plausibly wrong, or the failure is silent | `CHECK` passes on `NULL`; a path-filtered required check stays pending forever; React 18 removed the unmounted-`setState` warning |
| Stack or project fact | Vite + React 18 (not 19), Refine + MUI, money in INR |
| Post-training or volatile fact | Current API parameter shapes, spec editions, renamed CLI subcommands, each with a note to re-verify |
| Domain-specific agent guardrail the model would not follow unprompted | No commit, push, or PR unless asked; never invent a `sha256` digest; never edit an applied migration |
| An example that encodes several house choices more compactly than prose | The problem+json error body; the multi-stage Dockerfile |

**Cut:**

- **Philosophy sections and platitudes.** If a principle is a rule, state it once where it applies.
- **Textbook knowledge.** Definitions (HTTP method properties, status-code meanings, normal forms, Rules of Hooks, PEP 8 casing) and practice any senior engineer applies by default (parameterized queries, no `eval` on untrusted input, return early).
- **Rationale for well-known rules.** Keep a reason only when it is one short clause and changes how an edge case is handled.
- **Provenance.** Citations, quotations, author names, and verification dates belong in `references/sources.md`, never in `SKILL.md`. The one exception is a spec name or version that *is* the rule ("problem+json per RFC 9457").
- **Review checklists.** They restate the body as questions. A capable reviewer checks against the rules directly.
- **Repetition.** Each rule appears once per file. Across skills, the owning skill states a rule and the others only add their own mechanics. For example, migration sequencing lives in the SQL skill, and the Python skill adds only the Alembic mechanics.
- **Agent boilerplate** every capable coding agent already follows ("read neighbouring code first", "report real test output").
- **Long, occasionally-needed material** such as full CI scripts or provider-specific API tables. Move it to `references/<topic>` and leave a one-line pointer saying when to read it.

**Shape:** frontmatter; a title with at most three lines of scope (target stack, and "when this conflicts with an in-repo convention, follow the repo and say so"); numbered sections of terse rules, preferring tables; a gates section with the commands; an "Agent rules" section holding only guardrails not already stated above it. No `## References` section, no review checklist, no emojis.

**Budget:** `scripts/lint-skills.sh` fails any `SKILL.md` over 24,000 bytes (about 6k tokens). Hitting the ceiling means something above belongs in `references/`, not that the ceiling should move.

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

3. Write the body to the standard above.
4. If the skill needs supporting material, put it under `skills/<name>/references/` and point to it from `SKILL.md` with the condition for reading it; keep executable helpers under `skills/<name>/scripts/`.
5. Add a row to the table in [README.md](README.md).
6. Record what you actually read in `skills/<kebab-case-name>/references/sources.md`, and add a row for your skill to the summary table in [SOURCES.md](SOURCES.md). `SKILL.md` carries no pointer to it: sources are read by a human deciding whether to trust the skill, not by the model applying it.

   Two rules make the sources file worth having:

   - **Cite only what you opened.** If you found a page in search results but never read it, it is not a source. A short list of pages you actually read beats a long list you assembled from search titles.
   - **Give every entry a verification date**, and check the page still says what you claim. Vendor documentation gets reorganised — and some doc sites serve "page not found" with an HTTP 200, so a link checker will call a dead URL healthy. Open it.

   Group entries by how much authority they carry (specifications and RFCs first, then official vendor docs, then industry guidelines, then books), and note anything you could not verify rather than quietly dropping it. A reader should be able to tell the difference between a rule backed by an RFC and a rule backed by a blog post.
7. Run the lint check locally before opening a PR:

   ```bash
   ./scripts/lint-skills.sh
   ```

## Editing an existing skill

- Keep changes scoped to one logical update per PR.
- If you're changing a rule (not just wording), say why in the PR description — these documents get reused verbatim in other people's projects, so silent behavior changes are surprising.
- Adding a line? Check it against "What belongs in a SKILL.md" first, and check that no other section or skill already says it.

## Style

- Markdown, GitHub-flavored. Wrap prose naturally; don't hard-wrap.
- Prefer tables and short code blocks over long prose.
- No emojis.
