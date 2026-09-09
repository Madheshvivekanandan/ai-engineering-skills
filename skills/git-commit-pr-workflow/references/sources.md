# Git Commit and Pull Request Workflow — Sources

Provenance for [`../SKILL.md`](../SKILL.md). This file is deliberately kept
out of the skill body so it costs no tokens at load time; read it to verify a
rule, not to follow one. Repository-wide provenance tiers and known gaps:
[SOURCES.md](../../../SOURCES.md).

Throughout this file, "this document" and section references like §4 point to
`../SKILL.md`, whose rules these sources support. This text was moved out of that
file verbatim, so "the rules above" likewise means the rules there.


Only sources retrieved and read while writing this document.

**Specifications**

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) — the header grammar, the 16 normative rules, the `feat`/`fix`/`BREAKING CHANGE` to MINOR/PATCH/MAJOR mapping, the `!` marker, the footer/git-trailer rules, and the case-insensitivity exception for `BREAKING CHANGE`. Note: the spec normatively requires only `feat` and `fix` and sets no character limits.
- [Semantic Versioning 2.0.0](https://semver.org/) — MAJOR/MINOR/PATCH definitions, release immutability, `0.y.z` instability, the meaning of `1.0.0`, pre-release precedence, and build metadata being ignored for precedence.
- [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) — the six change types, the `Unreleased` section, newest-first ordering, ISO 8601 dates, and the "do not dump a commit log" anti-patterns. Served as the current spec; its own changelog lists 1.1.1 and 1.1.2 (2024-09-27) as later editorial revisions.
- [Conventional Comments](https://conventionalcomments.org/) — the `<label> [decorations]: <subject>` template, the primary label set, and the `(non-blocking)`/`(blocking)`/`(if-minor)` decorations. The site displays no version number.

**Git itself**

- Pro Git, 2nd Edition: [Contributing to a Project (Commit Guidelines)](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project) — atomic commits, `git diff --check`, `git add --patch`, the 50/72 imperative template; [Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) — the golden rule, the perils-of-rebasing duplicate-commit scenario, history-as-record vs history-as-story; [Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging) — annotated vs lightweight tags and tags not being pushed by default.
- [git-commit(1)](https://git-scm.com/docs/git-commit) — the DISCUSSION section's 50-character summary guidance (explicitly soft) and title-to-first-blank-line rule; `--fixup`, `--squash`, `--signoff`, and `--no-verify` bypassing both `pre-commit` and `commit-msg`.
- [git-rebase(1)](https://git-scm.com/docs/git-rebase) — RECOVERING FROM UPSTREAM REBASE, the interactive todo commands, `--autosquash`; confirms `--force-with-lease` is not a rebase option. [Git 2.44 release notes](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.44.0.adoc) — "`git rebase --autosquash` is now enabled for non-interactive rebase, but it is still incompatible with the apply backend", the version boundary cited in sections 10, 12, and 14. [git-push(1)](https://git-scm.com/docs/git-push) — `--force-with-lease` versus bare `--force`, `--force-if-includes`, and background `git fetch` weakening the lease.
- [Git Documentation/SubmittingPatches](https://git-scm.com/docs/SubmittingPatches) — imperative mood, the 50-character soft limit, the "state the problem, justify the approach, name rejected alternatives" body structure, separate commits for separate changes, and the DCO's origin-and-rights certification.
- [Git Documentation/SubmittingPatches, "Use of Artificial Intelligence" (raw, master)](https://raw.githubusercontent.com/git/git/master/Documentation/SubmittingPatches) — the Git project's own stance that it is not yet clear the DCO can be satisfied for significant AI-generated content, and that it will reject contributions that look AI generated or that senders cannot explain. One authoritative project's policy and a strong precedent, not a cross-industry standard.

**Code review**

Google Engineering Practices (each page retrieved individually):

- [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html) — approve on overall code health rather than perfection, technical facts over preference, the escalation path; [What to Look For](https://google.github.io/eng-practices/review/reviewer/looking-for.html) — the review priority order and the definition of "too complex".
- [Writing Good Code Review Comments](https://google.github.io/eng-practices/review/reviewer/comments.html) — comment on the code not the developer, always give the reason, the `Nit:`/`Optional:`/`FYI:` prefixes; [Speed of Code Reviews](https://google.github.io/eng-practices/review/reviewer/speed.html) — the one-business-day maximum and "LGTM with comments".
- [Small CLs](https://google.github.io/eng-practices/review/developer/small-cls.html) — the ~100-line target and ~1000-line ceiling, splitting strategies, per-change working state, keeping refactors separate; [Writing Good CL Descriptions](https://google.github.io/eng-practices/review/developer/cl-descriptions.html) — imperative summary plus what-and-why body, the named bad examples, updating the description before submitting.
- [Handling Reviewer Comments](https://google.github.io/eng-practices/review/developer/handling-comments.html) — fix the code rather than only explaining it in the thread, never respond in anger; [Emergencies](https://google.github.io/eng-practices/review/emergencies.html) — what does and does not qualify, and the minimal-scope plus re-review requirement.

**Branching and delivery**

- [Trunk Based Development](https://trunkbaseddevelopment.com/) — the single-trunk model, resisting long-lived development branches, just-in-time release branches, feature flags and branch by abstraction; it gives no numeric branch-lifetime figure. [DORA — Trunk-based development](https://dora.dev/capabilities/trunk-based-development/) — the source of every number in section 6: three or fewer active branches, merge to trunk at least once a day, branches lasting no more than a few hours, no code freezes.

- GitHub Docs: [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow) — the six-step branch → commit → PR → review → merge → delete-the-branch loop in section 6, short descriptive branch names, and the instruction to delete the branch after merge so nobody reuses it.

**CI/CD**

- GitHub Docs: [Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets) — the exact rule names in section 13's ruleset table: require a pull request before merging, require status checks to pass before merging, require signed commits, require linear history, block force pushes, restrict deletions, require deployments to succeed before merging.
- GitHub Docs: [Troubleshooting required status checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks) — a required workflow skipped by a `paths`, `branches`, or commit-message filter leaves its check *pending* and permanently blocks the merge, plus the documented same-name inverse-filter workaround; and the requirement to add the `merge_group` trigger to any workflow that is a required check under a merge queue.
- GitHub Docs: [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax) — `concurrency.group` / `cancel-in-progress` (default `false`), the top-level `permissions` key and the rule that unlisted permissions become `none` once any is set, `paths`/`paths-ignore` filters, and the `pull_request` versus `pull_request_target` distinction (`pull_request_target` gets a read/write `GITHUB_TOKEN` even from a public fork).
- GitHub Docs: [Managing environments for deployment](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments) — the `environment:` job key, environment secrets and variables, and the three deployment protection rules cited in section 13: required reviewers, wait timer, and deployment branch policies.
- [`gh pr checks`](https://cli.github.com/manual/gh_pr_checks) — the `--required`, `--watch`, and `--fail-fast` flags used in the section 12 gate block.

**Tooling and platform**

- [semantic-release/commit-analyzer — `lib/default-release-rules.js`](https://github.com/semantic-release/commit-analyzer/blob/master/lib/default-release-rules.js) — the default rules (`breaking: true` → MAJOR, `type: feat` → MINOR, `type: fix` and `type: perf` → PATCH, and `revert: true` — the parser's parsed-revert flag, not a `revert:` type — → PATCH), which is why the release-effect column in section 5 describes the spec and not your pipeline.
- [pre-commit](https://pre-commit.com/) — `.pre-commit-config.yaml` structure with pinned `rev`, `pre-commit install`, the `commit-msg` and other hook stages, `run --all-files` in CI, and `autoupdate`. [gitleaks](https://github.com/gitleaks/gitleaks) — the current `git`/`dir`/`stdin` scanning commands, the v8.19.0 deprecation of `detect` and `protect` (still available but hidden from `--help`), and the documented `.pre-commit-config.yaml` hook (`id: gitleaks`) used in section 12.
- [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/blob/master/%40commitlint/config-conventional/README.md) — the enforceable 11-type enum and the `header-max-length` / `body-max-line-length` / `footer-max-line-length` value of 100 (that config's values, not the spec's); [commitlint — Rules configuration](https://commitlint.js.org/reference/rules-configuration.html) — the `[level, applicable, value]` rule shape with level 0/1/2 and `always`/`never`.
- [Angular commit message guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) — the convention Conventional Commits derives from, Angular's narrower 8-type list, and its `revert: <original header>` handling. A living document on `main`; it states no header character limit.
- GitHub Docs: [About pull request merges](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges) — the three merge methods, what each does to SHAs and history, and the squash-a-long-running-branch conflict warning; [About pull requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) — draft PRs cannot be merged and do not auto-request code owners.
- GitHub Docs: [Linking a pull request to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue) — the nine closing keywords, per-issue keyword repetition, cross-repo syntax, default-branch-only closure; [Creating a commit with multiple authors](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors) — the exact `Co-authored-by:` trailer format, the required blank line, and the account-email requirement.

**Books**

- *Pro Git*, 2nd Edition (2014), Scott Chacon and Ben Straub — the primary reference for commit hygiene and history management; freely readable at git-scm.com under CC BY-NC-SA 3.0, published by Apress. Chapters cited individually above.
- *Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation* (2010), Jez Humble and David Farley — the underlying argument that delayed integration causes painful releases and that every commit should be a release candidate flowing through an automated pipeline. Cited as background only; nothing here is quoted from it.
