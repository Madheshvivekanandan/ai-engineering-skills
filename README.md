# AI Engineering Skills

A curated collection of portable, opinionated coding standards for AI coding
assistants — packaged as [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills),
but plain markdown underneath, so they work with **any** assistant that reads
a system prompt or a context file. Each one gets loaded at the right moment
(e.g. "before writing Python code") so the assistant behaves like a senior
engineer who already knows your standards — regardless of which tool you're
running.

Each skill is a single `SKILL.md` file with YAML frontmatter (`name`,
`description`) followed by the actual guidance. The frontmatter is what
Claude Code uses to auto-decide *when* to load the skill; every other
assistant just uses the plain markdown body below it as static instructions.

## Available skills

| Skill | Use when |
|---|---|
| [python-best-practices](skills/python-best-practices/SKILL.md) | Writing, modifying, or reviewing Python: FastAPI routes, SQLAlchemy models, Pydantic schemas, pytest tests, async code, Alembic migrations. |
| [react-best-practices](skills/react-best-practices/SKILL.md) | Writing, modifying, or reviewing React/TypeScript in a Vite + React 18 SPA: Refine, MUI, react-hook-form, react-router v6 components, hooks, data fetching, forms, and theming. |
| [n8n-workflow-best-practices](skills/n8n-workflow-best-practices/SKILL.md) | Creating or editing n8n workflows: node/workflow naming, sub-workflow modularity, error handling, credential security, git version control & CI/CD, and testing with pinned data. |

## Usage

These work with any AI coding assistant — Claude Code just gets automatic,
context-aware loading via its native skills mechanism; everywhere else, you
paste the guidance in as static instructions.

### Claude Code (auto-loading)

Copy (or symlink) the skill folder you want into your project's or your
user-level skills directory:

```bash
# Project-level (this repo's skill only applies to one project)
cp -r skills/python-best-practices /path/to/your-project/.claude/skills/

# User-level (available in every project)
cp -r skills/python-best-practices ~/.claude/skills/
```

Claude Code auto-discovers skills placed there and loads the matching one
when its `description` matches the task at hand.

### Any other assistant (static instructions)

Any assistant that accepts a system prompt or a context file — Cursor,
Windsurf, GitHub Copilot, Codex, a raw API system prompt, etc. — can use
these too. Just paste the body of `SKILL.md` (everything below the
frontmatter) into that tool's equivalent file, e.g. `.cursorrules`,
`AGENTS.md`, `CLAUDE.md`, or your system prompt. There's no auto-routing by
task outside Claude Code, so it's always loaded rather than conditionally
triggered — which is fine for a single, focused skill like this one.

## Repository structure

```
skills/
  <skill-name>/
    SKILL.md          # required: frontmatter + guidance
    references/        # optional: supporting docs the skill can point to
    scripts/            # optional: helper scripts the skill can invoke
```

## Adding a new skill

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — see the license file for details. These skills synthesize
guidance from public standards (PEP 8/257, Google style guides, OWASP, etc.);
the license covers this repository's curation, structure, and wording, not
the underlying public conventions themselves.
