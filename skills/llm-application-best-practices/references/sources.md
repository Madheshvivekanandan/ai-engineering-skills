# LLM Application Best Practices — Sources

Provenance for [`../SKILL.md`](../SKILL.md). This file is deliberately kept
out of the skill body so it costs no tokens at load time; read it to verify a
rule, not to follow one. Repository-wide provenance tiers and known gaps:
[SOURCES.md](../../../SOURCES.md).

Throughout this file, "this document" and section references like §4 point to
`../SKILL.md`, whose rules these sources support. This text was moved out of that
file verbatim, so "the rules above" likewise means the rules there.


Sources retrieved and read while writing this document. Provider API specifics are dated by nature:
the section 14 values were last checked on 2026-08-20 — re-verify before relying on any number.

**Security standards.** The OWASP resource landing page returned HTTP 403 and could not be read, so
the project repository files below are the primary citation.

- [OWASP GenAI LLM Top 10 — repository README](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/README.md) — authoritative enumeration and ordering of the 2026 edition, used in preference to secondary coverage that disagreed with it.
- [LLM00:2026 Preface](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM00_Preface.md) — the governing thesis (build the system so that when the model is fooled, nothing important breaks) and the LLM-vs-agentic scope boundary.
- [LLM01:2026 Prompt Injection](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM01_PromptInjection.md) — no reliable prevention; the static-vs-adaptive attack-success gap; provenance-labelled data channel; invisible-Unicode ranges; memory writes as privileged operations; Rule of Two; adaptive red-teaming.
- [LLM02:2026 Sensitive Information Disclosure](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM02_SensitiveInformationDisclosure.md) — non-obvious disclosure surfaces, layered redaction, per-user query budgets, gating logprobs, the observability-platform leak pattern.
- [LLM03:2026 Excessive Agency](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM03_ExcessiveAgency.md) — minimize tools, functionality, and permissions; execute in the user's context across chained calls; complete mediation with a graduated policy; rate limiting with circuit breakers.
- [LLM04:2026 Supply Chain](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM04_SupplyChain.md) — AI/ML BOM inventory, model signing with a transparency log, "signing proves integrity and origin, not safety", verifying AI-suggested dependencies.
- [LLM05:2026 Data and Model Poisoning](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM05_DataModelPoisoning.md) — RAG trust boundaries, dataset version control for rollback, gating retraining and feedback loops, inference artifacts as security-relevant code.
- [LLM06:2026 Unbounded Consumption](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM06_UnboundedConsumption.md) — token-based rate limits, pre-flight estimation, hard non-overridable spend caps, agentic circuit breakers, graceful degradation.
- [LLM07:2026 Misinformation](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM07_Misinformation.md) — claim-check-act separation, validating tool arguments against current state, groundedness over self-reported confidence, mandatory structured fields to surface omissions.
- [LLM08:2026 Hidden Context Exposure](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM08_HiddenContextExposure.md) — renamed and broadened from the 2025 edition's System Prompt Leakage; assume all model context is user-visible; never rely on hidden context as a control.
- [LLM09:2026 Vector and Embedding Weaknesses](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM09_VectorAndEmbeddingWeaknesses.md) — tenant scoping inside the index query, chunk-level ACLs, index segregation by trust tier, ingest normalization, embedding deletion and re-embedding, embeddings-as-breach.
- [LLM10:2026 Improper Output Handling](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/LLM10_ImproperOutputHandling.md) — model-as-untrusted-user, parameterized queries, context-aware encoding, CSP, ANSI/control-character sanitization, disabling Markdown image and link-preview auto-fetch.
- [ASI 2026 framework mapping, in the OWASP LLM Top 10 repo](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/mappings/asi-2026.json) — the ASI01-ASI10 titles used in section 13, taken from this mapping rather than the ASI publication itself; secondary sources reword several, so prefer these forms.
- [NIST AI 600-1 GenAI risk categories, mapping file in the OWASP repo](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/mappings/nist-ai-600-1.json) — the 12 GenAI risk category names and the note that NIST assigns them no alphanumeric ids. Second-hand: the NIST PDF itself was not read for this document.
- [NIST AI RMF 1.0 core functions, mapping file in the OWASP repo](https://raw.githubusercontent.com/GenAI-Security-Project/GenAI-LLM-Top10/main/2026/final/mappings/nist-ai-rmf-1.0.json) and [NIST AI RMF Core, Section 5](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/) — the GOVERN/MAP/MEASURE/MANAGE structure and the risk-tracking and supply-chain obligations in section 13.
- [NIST — AI Risk Management Framework landing page](https://www.nist.gov/itl/ai-risk-management-framework) — version status: AI RMF 1.0 published January 2023 and currently under revision; AI 600-1 published July 2024; nothing formally withdrawn.
- [Help Net Security — OWASP 2026 LLM Top 10 released](https://www.helpnetsecurity.com/2026/08/06/owasp-2026-llm-top-10-released/) — independent corroboration of the 2026 rank movements and the August 2026 release.

**Provider API (Anthropic; section 14)**

- [Prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md) — prefix-hash mechanics and render order, breakpoint limit, per-model minimum cacheable lengths, read/write price multipliers, the invalidation matrix, verification via usage counters.
- [Structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs.md) — `output_config.format`, strict tool use requirements, the supported and unsupported JSON Schema keyword sets, refusals not being schema-guaranteed, truncation returning partial content.
- [Citations](https://platform.claude.com/docs/en/build-with-claude/citations.md) — all-or-none enablement, the three location types and their indexing conventions, guaranteed-valid parsed pointers versus prompt-based quoting, incompatibility with structured outputs.
- [Prompt engineering overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview.md) — the prerequisite ordering in section 2, and the point that latency and cost are usually better addressed by model choice than prompt wording.
- [Create strong empirical evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests.md) — distribution matching, the named edge classes, automating grading, volume over hand-grading, using a different model to grade than to generate.
- [Define your success criteria](https://platform.claude.com/docs/en/test-and-evaluate/define-success.md) — SMART criteria, quantifying subjective dimensions, and including latency and price per call among the criteria.
- [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) — the workflow-versus-agent distinction and the five named workflow patterns in section 12, plus the agent-computer-interface guidance.

**Research and specifications**

- [Liu et al., "Lost in the Middle: How Language Models Use Long Contexts" (arXiv:2307.03172)](https://arxiv.org/abs/2307.03172) — the context-ordering rule: performance is highest at the beginning or end of the input and degrades for information in the middle.
- [Zheng et al., "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena" (arXiv:2306.05685)](https://arxiv.org/abs/2306.05685) — position, verbosity, and self-enhancement bias plus limited judge reasoning; the >80% judge/human agreement figure is specific to those benchmarks.
- [Gao et al., "Enabling Large Language Models to Generate Text with Citations" (ALCE, arXiv:2305.14627)](https://arxiv.org/abs/2305.14627) — citation-quality evaluation, and the finding that the best models lacked complete citation support about half the time on ELI5.
- [Lewis et al., "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks" (arXiv:2005.11401)](https://arxiv.org/abs/2005.11401) — the originating RAG framing of parametric plus non-parametric memory.
- [Ragas — available metrics](https://docs.ragas.io/en/stable/concepts/metrics/available_metrics/) — the retriever/generator metric split in section 2. Class names and import paths were not verified against a pinned release; confirm them against the version you install.
- [OpenTelemetry — GenAI client spans](https://raw.githubusercontent.com/open-telemetry/semantic-conventions-genai/main/docs/gen-ai/gen-ai-spans.md) and [GenAI metrics](https://raw.githubusercontent.com/open-telemetry/semantic-conventions-genai/main/docs/gen-ai/gen-ai-metrics.md) — the span and metric contract in section 11, including the normative position that instrumentations should not capture instructions, inputs, or outputs by default. These conventions are at Development status and may change.
- [OpenTelemetry docs — GenAI semantic conventions relocation notice](https://opentelemetry.io/docs/specs/semconv/gen-ai/) — confirms the conventions moved to the `semantic-conventions-genai` repository and that the opentelemetry.io copy is no longer maintained.
- [IETF Internet-Draft — The Idempotency-Key HTTP Header Field, draft-ietf-httpapi-idempotency-key-header-07](https://www.ietf.org/archive/id/draft-ietf-httpapi-idempotency-key-header-07.html) — the idempotency contract in section 8: client-generated key, replay semantics, 409 for an in-flight duplicate, 422 for key reuse with a different payload, 400 for a missing required key, server-defined expiry. Expired and archived Internet-Draft (rev 07, last updated 15 Oct 2025); never published as an RFC.

**Further reading.** Book identities confirmed from the pages linked below; no claim in this document
is attributed to them.

- [Chip Huyen's books page](https://huyenchip.com/books/) — *AI Engineering: Building Applications with Foundation Models* (O'Reilly, 2025), the closest single book to this document's scope, and *Designing Machine Learning Systems* (O'Reilly, 2022) for the production-systems half.
- [Hands-On Large Language Models — official code repository](https://github.com/HandsOnLLM/Hands-On-Large-Language-Models) — Jay Alammar and Maarten Grootendorst, O'Reilly; practical grounding in tokenization, embeddings, and retrieval mechanics.
- [Prompt Engineering for LLMs, ISBN 9781098156152](https://www.amazon.com/Prompt-Engineering-LLMs-Model-Based-Applications/dp/1098156153) — John Berryman and Albert Ziegler; application-level prompt and context construction.
