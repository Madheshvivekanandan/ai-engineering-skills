---
name: n8n-workflow-best-practices
description: Production engineering standard for building, documenting, securing, and version-controlling n8n workflows. Load BEFORE creating, editing, or reviewing any n8n workflow, node, sub-workflow, credential, or workflow JSON export/import. Covers naming, sticky-note documentation, modularity via sub-workflows, error handling, credential security, git-based version control and CI/CD, testing with pinned data, and monitoring.
---

# n8n Workflow Best Practices

Applies to n8n workflows, sub-workflows, credentials and their JSON exports in git, self-hosted or cloud.
When this conflicts with an in-repo convention, follow the repo and say so.

## 1. Naming

- Rename every default-named node (`HTTP Request 1`, `IF 2`, `Set 3`); a change is not complete while one remains.
- Nodes: verb-first, naming the action, not the node type: `Fetch Stripe Invoice`, `Check: User Has Email`, `Send Slack Alert: Sync Failed`.
- Workflows: `[Area] – Description – vN`, e.g. `[Sales] – Lead Sync HubSpot → CRM – v2`.

## 2. Sticky Notes

- A sticky note on every non-obvious branch or transformation, so a complex `IF`/`Switch`/`Merge` is understood without opening the node.
- One note per logical phase (e.g. Validate Input → Enrich → Write to CRM → Notify), stating the phase's objective and, ideally, its start and end nodes.
- Update the note in the same change that adds or materially alters a branch, transformation or phase.
- No ticket or story numbers in notes.

## 3. Sub-workflows

- One workflow, one job; keep each at or under 15–20 nodes and decompose past that.
- Extract a sub-workflow when a second caller appears; call or extend an existing one instead of copying node groups.
- Define an explicit, minimal input/output contract on the `Execute Sub-workflow Trigger` node.
- Shared sub-workflows are broadly viewable but narrowly editable: restrict write access.

## 4. Error Handling

- Every production workflow sets Settings → Error Workflow. The Error Workflow starts with an `Error Trigger` node, need not be active, and one can serve many workflows.
- Its alert carries the workflow name, failed node, error message and a link to the failed execution.
- It also records each failure in one central store (a Postgres table, a sheet, or the observability stack).
- The Error Workflow never fires for a workflow that stops running without an error (deactivated by hand, or its trigger stops receiving events); for scheduled production workflows, also check Executions for missing expected runs.
- `Retry On Fail` on nodes exposed to transient faults (timeouts, rate limits, flaky upstreams): `Max. Tries` 2-5 with a fixed `Wait Between Tries` (at most 5000 ms; n8n has no backoff); after the cap, escalate, never loop. It retries every error, 4xx included, so leave it off where a 4xx must not repeat (a paid or side-effecting call) and branch on the error instead.
- `On Error` → `Continue` (the legacy `Continue On Fail`) only where the failure is acceptable, such as an optional enrichment step.
- Map failure classes to actions: retry `5xx` and timeouts; refresh the credential or alert on `401`; route `422` to a human review queue. Branch on the error with `On Error` → `Continue (using error output)`. A continued error usually does not fail the execution, so the Error Workflow does not see it: end every error branch that is not a recovery in a `Stop and Error` node.

## 5. Credentials and Execution Data

- Secrets live only in n8n's credential store, never in a node parameter, a `Set` node, a sticky note or a `$env` expression; an export then references each credential only as `credentials.<type>: {id, name}` on the node.
- Self-hosted: set a persistent `N8N_ENCRYPTION_KEY`; the key auto-generated on first launch (in `~/.n8n`) is unfit for production. Losing or rotating it silently invalidates every stored credential.
- Give each environment's credentials identical names, so a promoted workflow resolves to that environment's credentials without an edit.
- Prefer an OAuth2 credential over a static API key where the service offers both.
- Set an execution-data retention policy (`EXECUTIONS_DATA_PRUNE=true`, `EXECUTIONS_DATA_MAX_AGE` in hours) and redact PII and full request/response payloads from the central failure log and error alerts.

## 6. Version Control and Environments

- The instance database is the source of truth for what runs; the committed JSON export is the git artifact.
- Know the sync direction before touching either side: last change in the n8n UI → export DB → file; last change in the file, or a UI "Download" (which captures unsaved canvas state, not the DB) → import file → DB. Check for uncommitted diffs before exporting; the wrong direction silently overwrites the newer side.
- One workflow per file.
- When editing exported JSON programmatically, keep the serialization n8n produced (do not reformat).
- Each environment is its own n8n instance, or at minimum its own credential and variable set. Promote via export/import or the API, one environment at a time (dev → staging → prod); never edit production directly, including to make it match git.

## 7. Testing

- Pin a node's output after a real run and re-execute downstream nodes against it.
- Edit pinned data to reach hard-to-trigger branches: turn a success into a failure shape, empty an array, null a field.
- Pins apply only to manual editor runs, never to production executions; clear stale pins before trusting a manual run.
- Exercise failure paths (malformed input, expired credential, upstream timeout) and confirm the Error Workflow fires and alerts. The `Error Trigger` fires only when an automatic execution fails, never for a manual run, so test it through the real trigger.
- A webhook's test and production URLs are different endpoints; verify against the production URL, whose runs appear under Executions rather than on the canvas, before calling a webhook workflow done.

## 8. Gates

Run the export and `jq` checks before committing an export and in CI; run import only to promote. Confirm flags with `n8n <command> --help` on the installed version.

```bash
n8n export:workflow --all --separate --output=workflows/   # DB -> files, one <id>.json per workflow
n8n import:workflow --separate --input=workflows/          # files -> DB; deactivates every imported workflow (--activeState=fromJson keeps each file's state: queue/multi-main mode only)
jq empty workflows/*.json
jq -r 'select(.settings.errorWorkflow == null) | .name' workflows/*.json
```

## 9. Agent Rules

- If a needed credential does not exist, ask the user to create it; never insert a realistic-looking placeholder.
- State in the summary which sync direction you used and why, and flag any production workflow with no Error Workflow set.
- If a commit hook conflicts with the required sync direction, say so and ask.
