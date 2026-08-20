# Sources

Every skill in this repository states rules as if they were settled. This file
exists so you can check that claim before you adopt one. It records what each
skill was actually built from, how firmly, and when that was last confirmed.

Read it as a provenance record, not a reading list. The point is not to show a
long bibliography — it is to let you tell the difference between a rule backed by
an RFC and a rule backed by somebody's blog post, without opening either.

## How to read this file

Each source sits in one of six tiers. The tier describes how the source was
handled, not how good the source is.

| Tier | Meaning |
|---|---|
| **Verified** | The page was fetched and read while the skill was written, and it says what the skill claims. |
| **Verified retroactively** | The page was fetched and read *after* the skill was written, and either it says what the skill claims or the divergence is now recorded at the rule. The provenance is real; the rule was not derived from the page, so the date of verification is stated separately from the date of authoring. |
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
| [python-best-practices](skills/python-best-practices/SKILL.md) | 56 | PEP 8 and PEP 257, the Google Python Style Guide, tool documentation (ruff, black, mypy, pytest, SQLAlchemy 2.0, FastAPI), OWASP Top 10:2025 + nine Cheat Sheets + ASVS 5.0.0, Martin's and Evans's own writing | 2026-08-20 (retroactive) |
| [react-best-practices](skills/react-best-practices/SKILL.md) | 86 | Vercel's MIT-licensed upstream skill (verified), react.dev (23 pages), W3C WCAG 2.2 (19), and each library's own docs | 2026-08-20 (retroactive) |

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

`python-best-practices` and `react-best-practices` now carry one too, both added
retroactively on 2026-08-20: their §20 and §15 `References` sections are the itemised
records for those skills, and the subsections below summarise how each came about and
what each did not settle. Only `n8n-workflow-best-practices` still has no comparable
section, so its provenance is recorded here in full.

### python-best-practices

Authored 2026-07-31. **No pages were fetched while it was written** — the opening
paragraph named what it synthesizes, and nothing more. On **2026-08-20** each named
standard was fetched, read, and attached to the rules that depend on it. That record
lives in the skill's own §20 `References`, next to the rules it supports.

Tier: **Verified (retroactively, 2026-08-20)** — 56 pages and documents read on that
date, every one of them re-fetched and re-read in an adversarial review the same day.
Order of authoring and verification matters here: the document was written first and
checked afterwards, so the References section says so plainly rather than implying the
sources were open while it was drafted.

What it rests on now: PEP 8 and PEP 257 (peps.python.org); the Google Python Style
Guide; Black's current-style page and seven Ruff documentation pages; four mypy pages;
three pytest pages plus pytest-cov; eight SQLAlchemy 2.0 pages; ten FastAPI pages;
OWASP Top 10:2025, the Cheat Sheet Series index and nine individual cheat sheets, and
ASVS 5.0.0's V3/V5/V6/V16 and Appendix C; and, for the architecture material, Martin's
2012 "The Clean Architecture", his 2014 SRP post, his 2020 "Solid Relevance", and
Evans's free 2015 DDD Reference.

**Verification did not merely confirm the document — it exposed contradictions**, and
they are now written into the body rather than papered over. The largest ones:

- **Line length.** The skill mandated 100 while citing PEP 8 (79 for code, 72 for
  prose, 99 only by team agreement), the Google guide (80), and Black and Ruff (both
  default to 88, and Black's docs warn specifically against exceeding 100). The number
  stays — it is a defensible house style — but §16 now states every source's value, and
  says outright that PEP 8's 72-character prose rule is dropped because the formatters
  this document delegates to do not reflow prose.
- **Docstring format misattributed.** "PEP 257 docstrings (Google style)" credited PEP
  257 with the `Args:`/`Returns:`/`Raises:` sections, which PEP 257 does not define at
  all. §17 now splits the citation: shape and imperative mood from PEP 257, the named
  sections and the triviality exemption from Google 3.8.3.
- **"Document every raised exception"** instructed the opposite of its source: Google
  3.8.3 says not to document exceptions raised when the documented API is violated.
  Narrowed to the function's contract.
- **A broken example.** `type CustomerId = NewType("CustomerId", int)` does not type-check
  under the strict mypy the same section mandates; mypy requires the literal to equal the
  variable name. Corrected, with a note that `NewType` is not a type alias.
- **File-upload validation was backwards** — it dismissed extension allow-listing (which
  both the File Upload Cheat Sheet and ASVS V5.2.2 require) and endorsed "type", i.e. the
  client-supplied `Content-Type` that OWASP says cannot be trusted. Rewritten.
- **Gate commands that did not do what their comments claimed.** `mypy app` does not run
  strict mode; `ruff check --fix` mutates files and cannot clear most `S`/`ANN` findings, so
  it is a poor CI gate; selecting the whole `E` family re-enables the rules Ruff documents
  as conflicting with the formatter; and "cyclomatic complexity ≤ 8" was never measured,
  because `C4` is flake8-comprehensions and complexity lives in the `C90`/mccabe namespace.
- **Architecture divergences now stated as such.** Clean Architecture forbids passing
  Entities or database rows across a boundary and forbids inner layers depending on outer
  ones; DDD keeps entities and value objects in one isolated layer and names modules from
  the ubiquitous language. This skill does none of those three, deliberately. §2, §11 and
  §14 now say so, so the layering rules stop borrowing authority they contradict.
- **OWASP tightenings**, where the sources were more specific than the skill: hash
  parameters and the PBKDF2/FIPS carve-out that a flat "never SHA" wrongly banned, a
  credential-length policy the skill had omitted entirely, the security events that must be
  logged (A09:2025), the CORS rule restated around sensitive data rather than credentials
  alone, and secret rotation. Also an honest divergence in the other direction: OWASP rates
  environment variables a fallback mechanism, not a recommended one, and this skill still
  permits them.

The `References` section was then audited against the same pages, and three defects in it were
fixed rather than left standing. One was a **misquotation**: the DDD Reference entry attributed to
Evans a scope disclaimer ("does not contain full explanations of DDD") that does not appear anywhere
in the 59-page PDF. The entry now says what the document actually is — a set of pattern summaries, by
its own subtitle and acknowledgements — and says explicitly that it carries no such disclaimer to
quote. The second was an **overstated default**: Ruff publishes its default rule set as an
enumeration of individual codes, not families, so "`I` and `N` are on by default" was wrong (only
`I001` and `N999` are), and §16's claim that Ruff's default narrows `E` to `E4,E7,E9` was wrong in
the other direction — the default takes no `E4` rule at all and only `E722`/`E902` from pycodestyle.
The third was a **quotation with no listed home**: §16's "omitting any stylistic rules that overlap
with the use of a formatter" is real but lives on Ruff's Tutorial page, which was not among the 55;
it is now the 56th entry, with the tension between its family-level summary and the enumerated
default recorded.

Also settled in the negative, which is worth as much: nothing in sections 11 and 12 was
found to be deprecated, renamed, or invented. Every SQLAlchemy 2.0.52 and FastAPI 0.141.1
API the skill names exists with that spelling, and all fourteen Ruff rule families it
selects are real.

### react-best-practices

Authored 2026-07-31 as an adaptation of Vercel's MIT-licensed react-best-practices
skill plus established React/TypeScript practice. **No pages were fetched while it was
written**, but it had the cleanest attribution of the older skills, recorded in its own
frontmatter:

```yaml
license: MIT
metadata:
  perf-rules-adapted-from: vercel-labs/agent-skills — skills/react-best-practices (MIT, v1.0.0)
```

Tier: **Adapted with attribution, sources verified 2026-08-20.** The skill now carries a
`References` section (§15) with 86 entries, every one fetched and read on that date:
9 for upstream attribution (Vercel's announcement post, seven files and directories in
`vercel-labs/agent-skills`, and one entry covering the 16 individual rule files read to
check specific claims), 23 react.dev pages plus React's `CHANGELOG.md`, the archived
`legacy.reactjs.org` error-boundaries page and the archived `18.react.dev` `Component`
page, 19 W3C WCAG 2.2 and WAI pages, 4 MDN pages, 9 react-hook-form docs pages, 3
TypeScript handbook pages, 3 TanStack Query pages, 3 `mui.com` pages plus the MUI v5 and
MUI X v6 docs sources read from their release branches, 2 Refine pages, 2 `unpkg` type
declarations, the `@hookform/resolvers` README, and one page each from React Router, Zod,
the npm registry, and the React TypeScript Cheatsheet. As with the Python skill, the
document was written first and checked afterwards, and §15 says so plainly rather than
implying the sources were open while it was drafted.

**The attribution held up.** The upstream skill exists at exactly the path the document
cites; `license: MIT` and `version: "1.0.0"` are both what upstream itself states, in its
`SKILL.md` frontmatter and `metadata.json`; and — the load-bearing check — **all 59
performance rule identifiers the document names exist upstream as `rules/<id>.md`. None
was invented.** The frontmatter therefore needed no correction.

Two caveats, now recorded in the skill itself. Upstream has **no `LICENSE` file**: MIT is
asserted only in the root `README.md` and the skill frontmatter, the GitHub license
endpoint returns `null`, and there is no copyright line, so there is no MIT text or
copyright holder for a redistributor to reproduce. And upstream publishes **no tags and no
releases**, so "v1.0.0" is a string in a JSON file rather than a git-resolvable pin — the
skill's traceability link now points at the last commit to touch that directory
(`dc8367e6f91c`, 2026-04-14) instead of the moving `main`.

**Verification also found false claims, all now corrected in place.** A provenance file
that hides a correction is worth less than one that records it:

- **Three upstream rules cited as applicable are React 19 APIs**, while the skill targets
  React 18: `rendering-activity` (`<Activity>`, 19.2), `rendering-resource-hints`
  (`preload`/`preconnect` from `react-dom`, 19), and `advanced-effect-event-deps`
  (`useEffectEvent`, 19.2). All three moved into the "does not apply" table, with React 18
  alternatives given.
- **A warning that no longer exists.** The hooks section claimed a missing effect cleanup
  produces a set-state-after-unmount warning. React removed that warning in **18.0** — the
  exact version the skill targets — so a reader would have read silence as correctness.
- **Error boundaries were described too absolutely** ("render errors only"). They also
  catch lifecycle and constructor errors, and two documented cases do reach them: a throw
  inside `startTransition`, and a rejected `React.lazy()` import — which matters, because
  the skill makes `React.lazy` its route-splitting mechanism.
- **The MUI barrel-import rule was mis-rationalised.** It was filed as the biggest
  *bundle-size* win, asserting that component barrels are not erased. MUI's own guide says
  the opposite: modern bundlers already tree-shake barrel imports out of production builds,
  and the real cost is dev-server startup and rebuild time. The rule stands — MUI still
  prefers path imports — but as a DX and lint gate, not shipped bytes.
- **A library was blamed for a local defect.** One line stated that `useFieldArray` was
  "not exported from the installed `react-hook-form`". Every published version back to
  6.15.8 exports it, so that was an install or resolution problem; as written it would have
  steered an agent into hand-rolling the API.

Alongside those, about a dozen weaker tensions are now acknowledged in the text rather
than silently restated: upstream's `bundle-dynamic-imports` actually prescribes
`next/dynamic`; `async-suspense-boundaries` is an RSC-streaming rule that on React 18
covers only `React.lazy` chunks and an opted-in suspense data layer; the `React.FC` advice
cited implicit `children`, which `@types/react` 18 removed; `slots` on the MUI Data Grid is
a v6+ prop name; the `Controller` rule now uses react-hook-form's documented criterion
(ref exposure, not controlled-ness); and the accessibility section — which previously
carried **zero** citations — now names WCAG 2.2 criterion numbers and conformance levels,
adds the 3:1 non-text-contrast requirement and SC 2.4.11 Focus Not Obscured, and demotes
the `autoFocus` rule to what it is: a usability opinion, not a conformance failure.

One further defect, fixed the same day and recorded here so it does not resurface as a
gap: the document used to hard-code one private codebase's measurements — named oversized
files with line counts, "52 barrel imports", "78 existing `any`s", a "237 problems" lint
baseline, and a `file:line` violation pointer — as though they were facts about React.
Those are now instructions for measuring the reader's own project, so the skill is portable
and this file has no portability problem left to warn about.

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
| *Clean Architecture* (Martin, Pearson 2017) and *Domain-Driven Design* (Evans, Addison-Wesley 2003) — publisher metadata verified, neither book read; no rule attributed to either. The architecture rules cite Martin's 2012 blog post and Evans's free 2015 DDD Reference instead | python-best-practices |
| "Design Principles and Design Patterns" (Martin, 2000), where SOLID originated — not retrievable; objectmentor.com no longer serves it and the Internet Archive was unreachable. No URL is given for it and nothing rests on it | python-best-practices |
| Which OWASP artifacts the author actually consolidated, and which Top 10 vintage — "OWASP Security Guidelines" is not the title of any OWASP document, so §10's mapping to Top 10:2025, the cheat sheets and ASVS 5.0.0 is a reconstruction, not a record | python-best-practices |
| Numeric house thresholds with no cited backing: line length 100, ≤ 4 parameters, complexity ≤ 8, class ≤ 200 lines, > 7 public methods, inheritance depth ≤ 2, ~10 files per layer, coverage ≥ 85%, route handler ≤ 15 lines. Labelled as house rules in the skill; several resemble figures from Martin's *Clean Code*, which is not cited and was not read | python-best-practices |
| Section 13 (async) as a whole, the Alembic rules, and §11's `text()` bound-parameter spelling were not checked against any source in the 2026-08-20 pass | python-best-practices |
| No release number is pinned for Ruff or pytest — their documentation pages display none, so those confirmations hold only "as of 2026-08-20" | python-best-practices |
| Two cited OWASP artifacts disagree on argon2id parameters: ASVS 5.0.0 Appendix C approves `t = 1, m ≥ 46 MiB, p = 1`, the Password Storage Cheat Sheet's minimum is `m = 19 MiB, t = 2, p = 1`. §10 quotes the cheat sheet and flags the stricter figure; no reconciliation exists upstream to cite | python-best-practices |
| `domainlanguage.com` answers some automated fetchers with HTTP 403. The DDD Reference PDF was retrieved directly and text-extracted, so the citation is verified, but it cannot be re-checked with a page-fetch tool alone | python-best-practices |
| Upstream `vercel-labs/agent-skills` has no `LICENSE` file, no copyright line, and no git tags or releases — MIT and "v1.0.0" are asserted in prose and JSON only | react-best-practices |
| Whether the upstream rule set on 2026-07-31 matched the 2026-08-20 reading — the skill directory's last commit predates authoring, but with no upstream tags there is nothing to compare against | react-best-practices |
| "Avoid `React.FC`" rests on `@types/react` typings plus a community cheatsheet; neither react.dev nor the TypeScript handbook takes a position | react-best-practices |
| Assistive-technology support for `aria-errormessage` versus `aria-describedby` — no primary source quantifies it | react-best-practices |
| MUI's dev-time-only framing of barrel imports is documentation-based; not measured against a real `vite build` | react-best-practices |
| React 18's archived `Component` page did not return the error-boundary exclusion list, so that rule is confirmed only against the current React 19.2 page | react-best-practices |
| §5's "boundaries also catch lifecycle and constructor errors" is stated on no maintained React page — the current react.dev `Component` page says only "during rendering", so the claim rests on the archived `legacy.reactjs.org` docs | react-best-practices |
| Repo house thresholds with no cited backing: component ≤ 250 lines, body ≤ 120, JSX depth ≤ 4, ≤ 8 props, `useReducer` at 3+ fields | react-best-practices |

## Maintaining this file

A provenance file that is not maintained becomes a false assurance, which is worse
than none. [CONTRIBUTING.md](CONTRIBUTING.md) step 6 requires a new skill to record
its sources here, cite only pages it actually opened, and date every entry.

When re-verifying, open the pages. Do not rely on a link checker: as the n8n audit
showed, a dead documentation URL can return HTTP 200 and read as healthy.
