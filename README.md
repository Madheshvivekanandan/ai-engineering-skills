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
| [llm-application-best-practices](skills/llm-application-best-practices/SKILL.md) | Building or reviewing anything that calls an LLM: prompt and context design, tool/function-calling schemas, structured output, RAG grounding and citations, evals, cost and latency budgets, prompt-injection defence, PII handling, and observability. |
| [sql-schema-design-best-practices](skills/sql-schema-design-best-practices/SKILL.md) | Designing or evolving a relational schema: DDL, migrations, keys and constraints, money/timestamp types, indexing and EXPLAIN, zero-downtime changes, backfills, multi-tenancy, and partitioning. |
| [api-contract-design-best-practices](skills/api-contract-design-best-practices/SKILL.md) | Designing or changing HTTP/REST API contracts: resource modeling, method and status-code semantics, problem+json errors, idempotency keys, pagination, versioning and breaking changes, ETags, rate limits, webhooks, and OpenAPI with CI gates. |
| [docker-deployment-best-practices](skills/docker-deployment-best-practices/SKILL.md) | Writing or reviewing a Dockerfile, .dockerignore, Compose file, Kubernetes manifest, or a CI job that builds, scans, tags, deploys, or rolls back a container image. |
| [git-commit-pr-workflow](skills/git-commit-pr-workflow/SKILL.md) | Committing, branching, or opening a pull request: atomic commits, Conventional Commits, trunk-based branching, PR scope and description, review etiquette, rebase vs merge, CI/CD required checks, semantic versioning, tags, changelogs, and pre-commit hooks. |

## Loading several skills together

A real project loads several of these at once, for example Python, React, SQL, and git for a full-stack app. They are written for that:

- **For capable models.** Each `SKILL.md` assumes a Sonnet-class model or stronger. It carries house decisions, thresholds, non-obvious gotchas, stack facts, and guardrails. It carries no textbook material, no philosophy sections, and no review checklist. [CONTRIBUTING.md](CONTRIBUTING.md) has the full keep/cut standard.
- **Each rule lives in one skill.** Shared topics have an owner, and the other skills add only their own mechanics. SQL owns migration sequencing and Python adds the Alembic specifics. The API skill owns status codes and pagination, and Python adds the FastAPI wiring. Git owns commits and CI rules, so no other skill restates them.
- **Long material loads on demand.** Full CI gate scripts, contract-test tables, and the Anthropic API reference live in `skills/<name>/references/`. `SKILL.md` names the moment to read each one.

| Skill | `SKILL.md` size |
|---|---|
| python-best-practices | 19.9 KB (~5.0k tokens) |
| react-best-practices | 15.5 KB (~3.9k tokens) |
| sql-schema-design-best-practices | 21.8 KB (~5.5k tokens) |
| git-commit-pr-workflow | 18.3 KB (~4.6k tokens) |
| api-contract-design-best-practices | 19.6 KB (~4.9k tokens) |
| docker-deployment-best-practices | 17.0 KB (~4.2k tokens) |
| llm-application-best-practices | 17.7 KB (~4.4k tokens) |
| n8n-workflow-best-practices | 6.9 KB (~1.7k tokens) |
| Python + React + SQL + git together | 75.6 KB (~19k tokens) |

Token counts are estimates at about four bytes per token.

Every source consulted while writing these skills is recorded: per skill in
`skills/<name>/references/sources.md`, and repo-wide — with provenance tiers and
known gaps — in [SOURCES.md](SOURCES.md). Every entry carries a verification
date, so you can see what each skill actually rests on. Those files sit outside
`SKILL.md` deliberately: provenance is for a human deciding whether to trust a
skill, so it shouldn't spend tokens every time an assistant loads one.

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
triggered — which is fine for a single, focused skill like this one. When a
skill points at a file under its `references/` folder, copy that folder into
the project too and adjust the pointer's path, so the assistant can open the
file when the skill tells it to.

## Repository structure

```
skills/
  <skill-name>/
    SKILL.md              # required: frontmatter + guidance (lint budget: 24,000 bytes)
    references/
      sources.md          # provenance: every source, with verification dates
      ...                 # optional: long material SKILL.md tells the model when to read
    scripts/              # optional: helper scripts the skill can invoke
```

## Adding a new skill

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — see the license file for details. These skills synthesize
guidance from public standards (PEP 8/257, Google style guides, OWASP, etc.);
the license covers this repository's curation, structure, and wording, not
the underlying public conventions themselves.
