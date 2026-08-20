# Sources

Every skill in this repository states rules as if they were settled. This file
exists so you can check that claim before you adopt one. It records what each
skill was actually built from, how firmly, and when that was last confirmed.

Read it as a provenance record, not a reading list. The point is not to show a
long bibliography — it is to let you tell the difference between a rule backed by
an RFC and a rule backed by somebody's blog post, without opening either.

## How to read this file

Each source sits in one of five tiers. The tier describes how the source was
handled, not how good the source is.

| Tier | Meaning |
|---|---|
| **Verified** | The page was fetched and read while the skill was written, and it says what the skill claims. |
| **Cited, not read** | The URL is real and reachable, but its content was never read — it came from search results. Treat any claim resting only on this as unconfirmed. |
| **Named influence** | A public standard the document synthesizes, named in the skill but with no page fetched and no URL captured. |
| **Adapted with attribution** | Material derived from a named upstream project, with its licence and version recorded. |
| **Could not verify** | The fetch failed, or the source could not be confirmed. Listed deliberately rather than quietly dropped. |

## The verification standard

Two rules, both learned the hard way in this repository:

**A source counts only if someone opened it.** A page found in search results is
not a source. This distinction is not pedantic — an early version of one skill
here listed thirteen URLs assembled from search titles, and three of them were
dead.

**A status code is not verification.** Some documentation sites serve
"page not found" with an HTTP 200. When the n8n skill was audited on 2026-08-20, a
`curl` pass reported all fourteen of its citations healthy; actually reading them
exposed three dead pages that a link checker would never have caught. Every
`Verified` entry below means a human or agent read the page, not that a request
returned 200.

Dates matter for the same reason. The n8n documentation was reorganised in under
three weeks, which silently rotted half that skill's official citations. Anything
not re-checked since its stated date should be treated as stale.

## Summary

| Skill | Citations | Rests primarily on | Verified on |
|---|---|---|---|
| [llm-application-best-practices](skills/llm-application-best-practices/SKILL.md) | 37 | OWASP GenAI security material, provider API reference, NIST AI RMF, peer-reviewed papers | 2026-08-19 / 2026-08-20 |
| [sql-schema-design-best-practices](skills/sql-schema-design-best-practices/SKILL.md) | 37 | PostgreSQL official documentation (22 pages), RFC 9562, Use The Index Luke | 2026-08-19 |
| [api-contract-design-best-practices](skills/api-contract-design-best-practices/SKILL.md) | 27 | RFC 9110 and RFC 9457, Google AIP, the OpenAPI Specification, Stripe's API docs | 2026-08-19 |
| [docker-deployment-best-practices](skills/docker-deployment-best-practices/SKILL.md) | 33 | Docker official docs (14 pages), Kubernetes docs, NIST SP 800-190, CIS, OWASP | 2026-08-19 |
| [git-commit-pr-workflow](skills/git-commit-pr-workflow/SKILL.md) | 33 | Google eng-practices, git-scm.com and git(1), Conventional Commits, SemVer | 2026-08-19 |
| [n8n-workflow-best-practices](skills/n8n-workflow-best-practices/SKILL.md) | 13 | n8n official docs (4 pages), plus community and third-party guidance | 2026-08-20 (audited) |
| [python-best-practices](skills/python-best-practices/SKILL.md) | 0 URLs | Named public standards, no pages fetched | not verified |
| [react-best-practices](skills/react-best-practices/SKILL.md) | 1 URL | Adapted from an MIT-licensed upstream | not re-verified |

Fifteen of the API skill's twenty-seven citations are specifications or standards
documents. That ratio, more than any total, is what tells you what a skill rests
on.

## Per-skill detail

The five skills added on 2026-08-19 carry a full `References` section inside the
skill itself, with **per-rule attribution** — which source supplied which specific
claim, and what each source does *not* say. That itemised detail is the
authoritative record; it lives next to the rules it supports so the two cannot
drift apart. This file summarises it and does not restate it.

Those `References` sections also record their own limits. The SQL skill, for
example, states plainly that its normalization guidance rests on general practice
with no primary source consulted and no clause of ISO/IEC 9075 cited; that its
antipattern names come from the publisher's table of contents rather than the book
text; and that one widely-cited book is listed as further reading only and must
not be treated as support for any rule. Read those notes before leaning on a rule.

The three older skills have no comparable section, so their provenance is recorded
here in full.

### python-best-practices

Authored 2026-07-31. **No pages were fetched while it was written.** Its opening
paragraph names what it synthesizes: the Google Python Style Guide, PEP 8, PEP 257,
FastAPI, SQLAlchemy, pytest, ruff, black, mypy, OWASP, Clean Architecture, SOLID,
and Domain-Driven Design.

Tier: **Named influence** for all of the above.

Every one of those is a real, public, well-regarded standard, and the guidance in
the skill is consistent with them. But no URL was captured and no page was
confirmed on that date, so nothing in this skill is currently traceable to a
specific sentence in a specific source. If you want it on the same footing as the
newer skills, the work is to fetch each named standard, attach the rules that
depend on it, and date the result.

### react-best-practices

Authored 2026-07-31. **No pages were fetched while it was written**, but it has the
cleanest attribution of the three older skills, recorded in its own frontmatter:

```yaml
license: MIT
metadata:
  perf-rules-adapted-from: vercel-labs/agent-skills — skills/react-best-practices (MIT, v1.0.0)
```

Tier: **Adapted with attribution** —
`https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices/rules`

The performance rule identifiers in the skill (`async-parallel`, `rerender-memo`,
and the rest) are kept deliberately unchanged so each one stays traceable to that
upstream. Naming the project, its licence, and its version is what makes this
honest rather than borrowed, and it is the pattern to copy when adapting anyone
else's material.

Not re-verified since authoring: the upstream may have revised or renamed rules.

### n8n-workflow-best-practices

Authored 2026-08-07 with genuine research — seven searches, three pages read. It
was **audited on 2026-08-20**, and the audit found real problems, all now fixed:

- **A factual error.** The skill claimed pinned data persists into production. n8n's
  documentation says the opposite: pinning "isn't available for production workflow
  executions." The rule was rewritten around the real failure mode, which is a
  stale pin making *manual* runs disagree with reality.
- **Three dead citations**, all returning HTTP 200 with 404 bodies after n8n
  restructured its documentation (`hosting/*` moved to `deploy/host-n8n/*`,
  `data/*` to `build/*`). Replaced with current URLs, each read to confirm it
  supports the claim attached to it. One replacement is a genuine improvement: the
  webhook `workflow-development` page documents the test-versus-production
  distinction in specifics the old citation never contained.
- **Ten citations that were never read** — listed from search-result metadata in the
  original session. These are now labelled honestly rather than presented as
  though they had been consulted.

Current state of its thirteen citations:

| Tier | Count | Which |
|---|---|---|
| **Verified** (read 2026-08-20) | 4 | The four `docs.n8n.io` pages: Error Trigger, pin and mock data, set a custom encryption key, webhook workflow development |
| **Verified** (read 2026-08-07) | 2 | The n8n community thread on structuring workflows for scale; the HatchWorks production checklist |
| **Cited, not read** | 6 | `blog.n8n.io`, and five third-party guides (`n8nautomation.cloud` x2, `lumadock.com` x2, `evalics.com`). Reachable, never opened. |
| **Could not verify** | 1 | `n8nlab.io` — returns 403 to automated requests |

Note that `hatchworks.com` also now returns 403 to automated requests; it is listed
as Verified because it was successfully read on 2026-08-07.

This is the weakest source profile in the repository: only four official
documentation pages, against six pieces of third-party guidance that nobody has
read. The rules themselves are sound and mostly mechanical, but if you are relying
on this skill for anything consequential, prefer the four official pages.

## Known gaps

Recorded so the absence of proof is visible rather than hidden.

| Gap | Where |
|---|---|
| NIST AI 100-2e2025 (adversarial ML taxonomy) — fetch failed via DOI | llm-application-best-practices |
| OWASP GenAI LLM Top 10 2026 resource page — fetch failed; the underlying content was verified through other OWASP GenAI material | llm-application-best-practices |
| *Accelerate* (Forsgren, Humble, Kim) — could not confirm details from a retrieved page, so it is not cited as support for any rule | git-commit-pr-workflow |
| *Database Design for Mere Mortals* (Hernandez) — same | sql-schema-design-best-practices |
| Normalization guidance rests on general practice; no clause of ISO/IEC 9075 cited | sql-schema-design-best-practices |
| Ten of thirteen citations never read at authoring time; six still unread | n8n-workflow-best-practices |
| No URLs captured; all provenance is by name only | python-best-practices |
| Upstream not re-verified since 2026-07-31 | react-best-practices |

## Maintaining this file

A provenance file that is not maintained becomes a false assurance, which is worse
than none. [CONTRIBUTING.md](CONTRIBUTING.md) step 6 requires a new skill to record
its sources here, cite only pages it actually opened, and date every entry.

When re-verifying, open the pages. Do not rely on a link checker: as the n8n audit
showed, a dead documentation URL can return HTTP 200 and read as healthy.
