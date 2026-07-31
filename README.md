# AI Engineering Skills

A curated collection of [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills) —
reusable, opinionated instruction sets that get loaded into an AI coding
assistant's context at the right moment (e.g. "before writing Python code")
so it behaves like a senior engineer who already knows your standards.

Each skill is a single `SKILL.md` file with YAML frontmatter (`name`,
`description`) followed by the actual guidance. The `description` is what the
assistant uses to decide *when* to load the skill, so it's written to trigger
on relevant file types, frameworks, and tasks.

## Available skills

| Skill | Use when |
|---|---|
| [python-best-practices](skills/python-best-practices/SKILL.md) | Writing, modifying, or reviewing Python: FastAPI routes, SQLAlchemy models, Pydantic schemas, pytest tests, async code, Alembic migrations. |

## Usage

### Claude Code

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

### Other assistants

Any assistant that accepts a system prompt or context file can use these
directly — paste the body of `SKILL.md` (below the frontmatter) into a
project instructions file (e.g. `CLAUDE.md`, `.cursorrules`, `AGENTS.md`).

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
