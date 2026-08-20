# n8n Workflow Best Practices — Sources

Provenance for [`../SKILL.md`](../SKILL.md). This file is deliberately kept
out of the skill body so it costs no tokens at load time; read it to verify a
rule, not to follow one. Repository-wide provenance tiers and known gaps:
[SOURCES.md](../../../SOURCES.md).

Throughout this file, "this document" and section references like §4 point to
`../SKILL.md`, whose rules these sources support. This text was moved out of that
file verbatim, so "the rules above" likewise means the rules there.


This document synthesizes n8n's own docs plus current (2026) community and
production guidance. Primary sources used while writing it:

- [n8n Docs — Error Trigger node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.errortrigger) — official Error Trigger behavior and setup.
- [n8n Blog — Creating error workflows in n8n](https://blog.n8n.io/creating-error-workflows-in-n8n/) — official guidance on wiring an Error Workflow per production workflow.
- [n8n Docs — Pin and mock data](https://docs.n8n.io/build/work-with-data/pin-and-mock-data) — official pinned-data testing workflow; the source for pinning being a development-only feature that "isn't available for production workflow executions" (checked 2026-08-20).
- [n8n Docs — Webhook node, workflow development](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/workflow-development) — test and production webhook URLs are separate endpoints; the test URL stays active for 120 seconds and production traffic is not visible in the editor (checked 2026-08-20).
- [n8n Docs — Set a custom encryption key](https://docs.n8n.io/deploy/host-n8n/configure-n8n/basic-configuration/configuration-examples/set-a-custom-encryption-key) — the source for n8n creating "a random encryption key automatically on the first launch" and saving it in `~/.n8n` (checked 2026-08-20).
- [n8n Community — Best practices for structuring n8n workflows for scale and long-term maintainability](https://community.n8n.io/t/best-practices-for-structuring-n8n-workflows-for-scale-and-long-term-maintainability/248671) — sub-workflow modularity, naming-as-story, access control on shared workflows.
- [HatchWorks — n8n Best Practices Checklist for Production](https://hatchworks.com/blog/ai-agents/n8n-best-practices/) — "one workflow, one job," credential hygiene, error-context notifications, HTTP-status-to-action mapping, testing failure paths, monitoring/observability.
- [n8nautomation.cloud — n8n Sub-Workflows: A Complete Step-by-Step Guide (2026)](https://n8nautomation.cloud/blog/n8n-sub-workflows-complete-guide-2026) — sub-workflow size limits, single-responsibility guidance, reuse patterns.
- [n8nautomation.cloud — n8n Credentials: Setup & Security Guide (2026)](https://n8nautomation.cloud/blog/n8n-credentials-complete-setup-security-guide-2026) — credential storage, OAuth vs. static keys, per-environment separation.
- [n8nlab.io — n8n Error Handling: 7 Best Practices to Stop Workflow Failures](https://n8nlab.io/blog/n8n-error-handling-best-practices) — layered retry/Continue-On-Fail/global-Error-Trigger model, bounded retries.
- [LumaDock — CI/CD for n8n: Git, environments and safer releases](https://lumadock.com/tutorials/n8n-cicd) and [Version control and CI/CD for n8n: Dev to prod without surprises](https://lumadock.com/tutorials/n8n-ci-cd-version-control) — git branching, per-environment instances, CI/CD pipeline validation steps.
- [Evalics — n8n Workflow Docs: Naming, Git & Best Practices](https://evalics.com/blog/n8n-workflow-documentation-best-practices-complete-guide) — node/workflow naming conventions, verb-first node names.
