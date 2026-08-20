---
name: react-best-practices
description: React/TypeScript engineering standard for Vite + React 18 SPAs built with Refine, MUI, react-hook-form, and react-router v6. Load BEFORE writing, modifying, or reviewing any React code in such an app — anything under src/ (pages/, components/, providers/, hooks) or any .tsx/.ts component, hook, data fetch, form, MUI DataGrid, or theme change. Covers component architecture, naming, state management, TypeScript, error handling, forms, testing, security, accessibility, performance (waterfalls, bundle size, re-renders), tooling gates, and a review checklist.
license: MIT
metadata:
  perf-rules-adapted-from: vercel-labs/agent-skills — skills/react-best-practices (MIT, v1.0.0)
  stack: vite + react 18 + typescript + refine + mui
---

# React Best Practices (Vite + Refine + MUI SPA)

Correctness and clarity first, then performance. Performance rule IDs
(`async-parallel`, `rerender-memo`, …) come from **Vercel Engineering's
react-best-practices** (MIT, `metadata.json` version 1.0.0) and stay traceable upstream:
`https://github.com/vercel-labs/agent-skills/tree/dc8367e6f91c/skills/react-best-practices/rules`

Every rule ID named in this document was checked against that directory on **2026-08-20** and
exists there as `rules/<id>.md`; none is invented. What is *not* inherited is the justification —
several upstream rules are written for Next.js/RSC or for React 19 APIs, and where this document
keeps such an ID it says so at the rule (§0, §8, §9). Upstream publishes no git tags or releases
and `main` is still moving, so the link above pins the last commit that touched the skill directory
(`dc8367e6f91c`, 2026-04-14) rather than `main`. MIT is stated in upstream's root `README.md` and
skill frontmatter; the repository has no `LICENSE` file, so there is no upstream copyright line to
reproduce. Full provenance in §15.

## 0. Target Stack & What Does Not Apply

This skill targets a **Vite + React 18 SPA** (TypeScript 5.4, `strict: true`), not Next.js:

```
src/
  pages/<feature>/          # route screens
    components/             #   feature-local components
  components/common/, components/layout/
  providers/                # Refine data/auth providers (dataProvider.ts, authProvider)
  interfaces/               # shared domain types
  config/, theme/, utils/
```

- Stack: `@refinedev/core` + `@refinedev/mui`, MUI 5 (`@mui/material`, `@mui/x-data-grid`,
  `@mui/x-date-pickers`), `react-hook-form`, `react-router-dom` v6, `axios`, `dayjs`.
- Import alias `@/*` → `src/*` is configured — prefer it over deep `../../..` chains.
- Money is **INR**. Use a shared formatter (`Intl.NumberFormat("en-IN", {currency:"INR"})`);
  never hand-concatenate a symbol, never float-accumulate currency.

**Next.js / RSC / React-19 concepts that DO NOT apply here — never suggest them.** Some rows name
a real upstream rule ID; others name a framework API upstream never wrote a rule for.

| Not applicable | Why |
|---|---|
| RSC / Server Components, `"use client"` | No RSC; everything is a client component. |
| `next/dynamic`, `next/script` (and Next's image/font components, which upstream has no rule for) | No Next.js. Use `React.lazy` + `<Suspense>`; plain `defer`/`async` on scripts in `index.html`. |
| Server actions, `server-auth-actions`, `after()` | No server runtime; this is a pure client SPA calling a separate backend API. |
| `server-cache-react` (`React.cache()`), RSC prop serialization | Server-only APIs. |
| SSR hydration rules (`rendering-hydration-*`) | SPA — no SSR/hydration step. |
| SWR (`client-swr-dedup`) | Refine wraps TanStack Query, which already dedupes/caches. Don't add SWR. |
| `rendering-activity` (`<Activity>`) | React 19.2 API — not available on React 18. See §8 for the React 18 alternative. |
| `rendering-resource-hints` (`preload`/`preconnect` from `react-dom`) | React 19 APIs, and upstream frames them as server-component guidance. Use plain `<link rel="preconnect">`/`<link rel="preload">` in `index.html`. |
| `advanced-effect-event-deps` (`useEffectEvent`) | React 19.2 API. Use `advanced-use-latest`/`advanced-event-handler-refs` instead (§9). |

**React 18 pins the behaviour here; react.dev now documents 19.2**, so a page you land on may
describe an API this app does not have. React-19-only features that look applicable but are not:
async functions in `startTransition` (Actions), `useActionState`, `useOptimistic`,
`useDeferredValue(value, initialValue)`, `use`, `ref` as a prop, ref cleanup functions, and — new
in 19.2 — `<Activity>` and `useEffectEvent`. For React 18 behaviour read `https://18.react.dev`.

## 1. Philosophy

- **Readability over cleverness**; the next reader is the maintainer.
- **Correctness and clarity before optimization.** Only optimize with a measurement.
- **Colocate, then extract.** Keep code near its use; extract when a second caller appears.
- **One responsibility per component.** Data-shaping, side effects and markup want separating.
- **Make invalid states unrepresentable** with types, rather than defending against them at runtime.
- **Never leave the user staring at a blank screen** — every async path has loading and error states.

## 2. Component Architecture & Naming

**Size limits (enforced in review).** Extract past these:

| Unit | Limit |
|---|---|
| Component file | **≤ 250 lines** |
| Component function body | ≤ 120 lines / ≤ 5 hooks doing unrelated work |
| JSX nesting depth | ≤ 4 |
| Props on one component | ≤ 8 (past that, group into an object or split) |

> Most codebases have files that already exceed these limits. Find this project's before you
> start: `find src -name '*.ts*' -exec wc -l {} + | awk '$1 > 250 && $2 != "total"' | sort -rn`.
> **Never grow a file that is already over the limit** — when editing one, extract the part you
> touch into `pages/<feature>/components/`. Don't refactor wholesale unless asked.

- **Split by responsibility:** a page composes; child components render sections; **custom hooks
  own data + logic**. If a component both fetches/derives and renders 200 lines of JSX, the
  fetch/derive half becomes `use<Feature>()` in the feature folder.
- **New feature** → `pages/<feature>/` with a `<Feature>Page.tsx` + `components/`.
  Reusable across features → `components/common/`. Shared types → `interfaces/`.
- **Composition over prop-drilling and over configuration flags.** Prefer `children`/slots to a
  `variant`-plus-ten-booleans API. Past 2 levels of drilling, use context or restructure.
- **No inline component definitions** — see `rerender-no-inline-components` (§8).

**Naming**

| Kind | Convention | Good | Bad |
|---|---|---|---|
| Component file + fn | `PascalCase`, matching | `CreditProfileCard.tsx` | `card2.tsx`, `index.tsx` everywhere |
| Hook | `use` + noun/verb | `useTicketFilters()` | `ticketStuff()` |
| Event handler (internal) | `handle*` | `handleSubmit` | `onSubmitClick2`, `doIt` |
| Event prop (external) | `on*` | `onApprove` | `approveCb` |
| Boolean prop/state | `is/has/can/should*` | `isCreditBlocked` | `flag`, `status2` |
| Constant | `UPPER_SNAKE` module scope | `MAX_LINE_ITEMS` | inline `50` |
| Type / interface | `PascalCase`, no `I` prefix | `Ticket`, `CreditProfile` | `ITicket`, `TicketType2` |
| Units in the name | always | `timeoutMs`, `amountInr` | `timeout`, `amount` |

- Name for the **domain**, not the mechanism: `unpaidInvoices`, not `data2`/`filteredList`.
- Never `data`, `item`, `tmp`, `res`, `x` as a meaningful identifier.

## 3. State Management — Pick the Right Location

Choosing wrong here causes most React bugs. In priority order:

1. **Server state → Refine hooks** (`useList`, `useOne`, `useCustom`, `useUpdate`).
   Never mirror fetched data into `useState`; that's a stale-copy bug. Never hand-roll
   `useEffect` + `axios` + `setState` — you lose dedup, caching, and cancellation.
2. **URL state → `useSearchParams`** (react-router v6). **Filters, pagination, sort, active tab,
   and selected-row id belong in the URL**, not `useState`. Makes views shareable and
   refresh-survivable. This is the most-missed rule in table-heavy screens
   (tickets, receivables, payables).
3. **Local UI state → `useState`/`useReducer`** in the *nearest* owner: open/closed, hover, draft
   input. `useReducer` once state updates get complex enough to cause bugs — as a local bright
   line, 3+ fields changing together or transitions with rules. That threshold is this document's
   convention, not React's: react.dev treats `useState`-vs-`useReducer` as partly preference, and
   the reducer's real payoff is a pure function you can unit-test in isolation.
4. **Cross-cutting → context**, sparingly (auth/user, theme, notifications). Split providers by
   concern and keep values memoized — one god-context re-renders the whole app on any change.

- **Derive, don't duplicate.** Compute during render from the source of truth; no `useEffect` to
  sync two pieces of state (see `rerender-derived-state-no-effect`).
- **Single source of truth.** If two states can disagree, one must be derived.
- Reset child state on identity change with a `key`, not an effect.

## 4. TypeScript

- `strict: true` is on — keep it. **`tsc` gates `npm run build`.**
- **No `any`.** Use `unknown` + narrowing, a real interface, or a generic. If unavoidable, a
  comment must justify it. *(If the project carries pre-existing `any`s, measure that count first,
  then add none and remove the ones in files you touch.)*
- **Type API responses at the boundary** (`interfaces/`) and use those types inward. Don't let
  `any` from `axios`/`dataProvider` leak into components.
- **Discriminated unions over optional-flag soup** — model states as
  `{status:"loading"} | {status:"error"; error:E} | {status:"ok"; data:D}`, so impossible
  combinations don't typecheck.
- Prefer `type` for unions/aliases, `interface` for object shapes that may be extended.
  No `I` prefix. `satisfies` to keep literal inference while checking a shape.
- `import type { … }` for type-only imports (lint enforces).
- Type props explicitly; avoid `React.FC` — it can't express a generic component signature, forces
  the return type, and has known `defaultProps` problems. (Don't cite children as the reason:
  `@types/react` 18 — the version this stack pins — removed the implicit `children` prop, so
  declare `children: React.ReactNode` when you accept it.) Use `ComponentProps<typeof X>` to extend
  MUI component props rather than restating them; reach for `ComponentPropsWithoutRef` /
  `ComponentPropsWithRef` when `ref` forwarding matters.
- Never `@ts-ignore`; `@ts-expect-error` with a reason comment if truly needed.

## 5. Error Handling & Resilience

- **Error boundaries are mandatory.** Without one, a single render throw blanks the entire SPA.
  Wrap (a) the app shell and (b) each independently-failing panel — a dashboard card must not
  take down the page. Boundaries catch errors thrown **while rendering**, and in lifecycle methods
  and constructors. They do **not** catch event-handler errors, throws inside
  `setTimeout`/`requestAnimationFrame`/a bare promise rejection, or an error thrown by the boundary
  component itself rather than its children — `try`/`catch` those yourself.
  Two documented exceptions *do* reach a boundary: a throw inside `startTransition` from
  `useTransition`, and a rejected `React.lazy()` import. The second matters here, because §8 makes
  `React.lazy` the route-splitting mechanism and a failed chunk load is exactly that case — so
  every `<Suspense>` boundary needs an error boundary beside it.
- **Every mutation handles failure.** Never fire-and-forget a write: on failure, surface a
  message, keep the user's input, and re-enable the control. Never swallow — no empty `catch`.
- **Map status codes to behaviour**, centrally in the provider/interceptor:
  `401` → re-auth; `403` → forbidden view (a dedicated `forbidden/` route is the clean pattern);
  `422` → field-level form errors (§6); `5xx`/network → retryable "something went wrong".
- **Retries** only for idempotent reads (GET), bounded with backoff. **Never auto-retry a
  non-idempotent write** — retrying a credit approval or invoice post can double-apply it.
- Timeouts on every request; treat "no response" as a failure state, not a permanent spinner.
- Show three distinct states — **loading / empty / error** — and never conflate empty with error.
- Log with `console.error` and real context; **never log tokens, credentials, or customer PII**.

## 6. Forms & Validation (react-hook-form)

These screens move money — credit requests, invoices, dispatch. Treat forms as critical paths.

- **Schema-validate** (zod/yup + resolver) as the single source of truth for rules; infer the TS
  type from the schema so types and validation can't drift.
- **Validate on the server too, always.** Client validation is UX, never a trust boundary.
- **Prevent double submit:** disable the submit control while `isSubmitting`. A double-click that
  posts a payment twice is a data-integrity incident.
- **Map server field errors back onto fields** via `setError`, with a form-level message for
  non-field errors. Don't drop a 422 into a toast and lose which field was wrong.
- Use **`Controller`** for MUI inputs that don't expose the native input's ref, or whose value
  isn't a plain DOM value — `Select`, `Autocomplete`, `DatePicker`, `Checkbox`/`Switch` groups. The
  documented trigger is **ref exposure, not controlled-ness**: a plain `TextField` takes
  `{...register("field")}` directly (MUI forwards it to the input) and is cheaper, because
  react-hook-form is ref-based by design. Where a field must stay controlled,
  `Controller`/`useController` isolates re-renders to that one field instead of the whole form.
- Subscribe narrowly: **`useWatch` on the specific field**, never `watch()` on the whole form
  (re-renders everything per keystroke).
- Warn on navigate-away when `isDirty`. Reset via `reset()` after a successful submit.
- Money/quantity inputs: parse and validate as fixed-precision; enforce min/max and step; reject
  negatives explicitly rather than relying on the input type.
- Dates: the backend stores **UTC**. Convert at the boundary with `dayjs` and be explicit about
  timezone — naive local parsing produces off-by-one-day delivery dates.

## 7. Testing

If no test framework is configured (**recommended: Vitest + React Testing Library + MSW**), that
is a gap — say so, and don't claim tests were run until one exists. Once present:

- **Vitest + RTL + `@testing-library/user-event`**; **MSW** to mock the API at the network layer.
- **Test behaviour, not implementation.** Query by role/label/text as a user would
  (`getByRole("button", {name:/approve/i})`); never assert on state internals or snapshot whole trees.
- **Cover per feature:** happy path; **empty, loading, and error states**; validation failures;
  permission-denied (RBAC) rendering; and the money/rounding edges.
- Test **custom hooks** directly (`renderHook`) — that's where logic should live and it's the
  cheapest place to assert it.
- Deterministic: fake timers, fixed clock (no `new Date()` in assertions), seeded data, no
  network, no `sleep`. Use builders/factories over giant literal fixtures.
- **Every bug fix ships a regression test** that fails before the fix.
- Priority when adding coverage to an untested codebase: money/credit logic → form validation →
  status transitions → table filtering. Don't chase a coverage % on presentational markup.

## 8. Performance

### Waterfalls (CRITICAL)

- **`async-parallel`** — independent requests in `Promise.all`, never sequential `await`s.
- **`async-cheap-condition-before-await`** — cheap sync checks (permission, empty input) first.
- **`async-defer-await`** — start the promise early, `await` only in the branch that needs it.
- **`async-dependencies`** — don't make C wait on A when only B depends on A.
- **`async-suspense-boundaries`** — one boundary per independently-loading region, so one slow
  panel doesn't block the screen. Upstream's mechanism for this rule is **RSC streaming**, which
  does not exist here: on React 18 + Vite, `<Suspense>` covers `React.lazy` chunks and a data layer
  explicitly opted into suspense (TanStack Query's `useSuspenseQuery`) — you cannot suspend on a
  bare promise. Otherwise each panel owns its own loading state rather than sharing one. Pair every
  boundary with an error boundary (§5).

```ts
// Bad — 3 sequential round trips
const ticket   = await api.getTicket(id);
const credit   = await api.getCredit(ticket.customerId);
const products = await api.listProducts();

// Good — products is independent; credit genuinely depends on ticket
const productsPromise = api.listProducts();
const ticket = await api.getTicket(id);
const [credit, products] = await Promise.all([
  api.getCredit(ticket.customerId),
  productsPromise,
]);
```

Never `await` inside a loop over rows — collect promises, then `Promise.all`.

### Bundle size (CRITICAL)

- **`bundle-dynamic-imports`** — `React.lazy` + `<Suspense>` for heavy/deferred UI: DataGrid
  screens, date pickers, charts, export/print views, large dialogs. Route-level splitting per
  `pages/<feature>` is the cheapest win, and the largest genuine shipped-bytes win in this list.
  (Upstream states this rule as "use `next/dynamic`" — `React.lazy` + `<Suspense>` is the
  adaptation for this stack, which is why §0 bans `next/dynamic` while the rule ID stays.)
- **`bundle-analyzable-paths`** — static literal import paths only; no template-string `import()`.
- **`bundle-conditional`** — load admin/export-only modules when activated, not at module scope.
- **`bundle-defer-third-party`** / **`bundle-preload`** — analytics after first paint; `import()`
  on nav hover/focus.
- **`bundle-barrel-imports`** — import concrete MUI modules:

```ts
// Bad
import { Button, Dialog } from "@mui/material";
// Good
import Button from "@mui/material/Button";
import DeleteIcon from "@mui/icons-material/Delete";
```

  Be honest about why. MUI's own guide is explicit that Vite/Rollup **already tree-shake barrel
  imports out of the production bundle**; the real cost is **dev-server startup and rebuild time**
  (worst with `@mui/icons-material`). Path imports remain MUI's documented preference and the lint
  rule here, so count the project's existing barrel imports before you start and add none — but
  treat this as a DX and lint gate, not shipped bytes, and don't call it a bundle win without a
  `vite build` measurement (§1: only optimize with a measurement). Type-only barrels
  (`interfaces/`) are exempt either way: `import type` is erased at compile time.
- Register `dayjs` plugins once at app setup, not per component.

### Data fetching

- **Query keys.** With Refine hooks the key is *generated* from the hook's own properties
  (`resource`, `filters`, `sorters`, `pagination`, `id`), so pass parameters **as hook properties**
  rather than closing over them in a fetch — anything smuggled in outside those props is invisible
  to the cache. Where you write a key by hand (`useCustom`, a raw `useQuery`), include **every**
  result-affecting parameter (filters, pagination, customer id) or you serve stale/cross-contaminated
  data. Verify with the TanStack Query devtools.
- **Server-side** pagination/filtering for large tables; never fetch-all-and-filter-client-side.
- Invalidate precisely (affected resource/id) after mutations, not the whole cache.
- **`client-event-listeners`** one shared global listener, not one per row.
  **`client-passive-event-listeners`** `{passive:true}` for scroll/wheel/touch.
- **`client-localstorage-schema`** version and minimize persisted data; read once into memory
  (`js-cache-storage`), never in a render path.
- Ignore/abort stale in-flight responses so a slow earlier one can't overwrite a newer one.

### Re-renders

- **`rerender-derived-state-no-effect`** derive during render; no `useEffect`+`setState` to compute.
- **`rerender-no-inline-components`** never define a component inside a component — it remounts and
  loses state every parent render. **Includes DataGrid cell and slot renderers** — `renderCell`,
  plus `slots`/`slotProps` on `@mui/x-data-grid` v6+ or `components`/`componentsProps` on v5 (check
  the installed major; the rename landed in Data Grid v6). Hoist or `useCallback`.
- **`rerender-functional-setstate`** `setX(prev=>…)` keeps callbacks stable.
- **`rerender-defer-reads`** don't subscribe to state used only inside a callback.
- **`rerender-derived-state`** subscribe to the derived boolean, not the churning raw value.
- **`rerender-dependencies`** primitive deps, not freshly-built objects/arrays.
- **`rerender-lazy-state-init`** `useState(() => expensive())`.
- **`rerender-memo`** memoize genuinely expensive subtrees;
  **`rerender-simple-expression-in-memo`** don't memo a primitive comparison.
- **`rerender-memo-with-default-value`** hoist non-primitive defaults (`const EMPTY: readonly T[] = []`).
- **`rerender-split-combined-hooks`**, **`rerender-move-effect-to-event`**,
  **`rerender-transitions`** / **`rerender-use-deferred-value`** (responsive input over a big list),
  **`rerender-use-ref-transient-values`** (scroll/drag values).

> If React Compiler is adopted (it supports React 17/18/19) it handles most memoization, and
> `rerender-memo` / `rerender-simple-expression-in-memo` become escape-hatch guidance rather than
> defaults. Keep existing memoization in place when enabling it.

### Rendering

- **`rendering-conditional-render`** ternary, not `&&` — `{count && <X/>}` renders a literal `0`.
- **Stable, data-derived `key`s** (`ticket.id`); never array index on reorderable/filterable rows.
- **`rendering-hoist-jsx`** static JSX to module scope. **`rendering-content-visibility`** +
  virtualization for long lists. **`rendering-usetransition-loading`**,
  **`rendering-animate-svg-wrapper`**, **`rendering-svg-precision`**,
  **`rendering-script-defer-async`** (plain `defer`/`async` on scripts in `index.html`).
- Two upstream rendering rules are **React 19 APIs and do not apply on React 18** (§0).
  `rendering-activity` needs `<Activity>` (React 19.2): to stop an expensive tab panel remounting,
  keep it mounted and hide it with CSS, or hoist its state above the tab switch — don't import a
  component the installed React doesn't have. `rendering-resource-hints` needs `preload` /
  `preconnect` / `prefetchDNS` from `react-dom` (React 19): use `<link rel="preconnect">` and
  `<link rel="preload">` in `index.html` instead.

### JavaScript (lowest priority — never trade readability for these)

- **`js-set-map-lookups`/`js-index-maps`** build a `Map` once instead of `.find()` in a loop
  (the classic O(n²) in a table render).
- **`js-combine-iterations`**, **`js-flatmap-filter`**, **`js-early-exit`**,
  **`js-length-check-first`**, **`js-hoist-regexp`**, **`js-cache-property-access`**,
  **`js-cache-function-results`**, **`js-min-max-loop`**,
  **`js-tosorted-immutable`** (never mutate props/state in place), **`js-batch-dom-css`**,
  **`js-request-idle-callback`**.

## 9. Hooks Correctness

- Rules of Hooks: top level of a component or custom hook only — never in a condition, loop, or
  after an early return, and never inside `try`/`catch`/`finally`, an event handler, a class
  component, or a function passed to `useMemo`/`useReducer`/`useEffect`.
- **Complete dependency arrays.** Never silence the lint by deleting a dep — fix the design
  (hoist, ref, functional update, stable callback).
- **Effects synchronize with external systems** (subscriptions, listeners, imperative APIs) —
  not for deriving data or reacting to your own `setState`.
- **Always clean up**: listeners, timers, subscriptions, aborts. A missing cleanup leaks the
  subscription or timer — connections pile up as the user navigates — and lets a stale response
  overwrite fresh state. **Silence is not evidence of correctness:** React removed the
  set-state-on-an-unmounted-component warning in **18.0**, the version this skill targets, so you
  will never be warned about it.
- **`advanced-use-latest`/`advanced-event-handler-refs`** stable callback identity without stale
  closures — these are the React 18 answer to the stale-closure problem. **`advanced-init-once`**
  app init once per load, not in `useEffect([])`. Upstream's **`advanced-effect-event-deps`** is
  about `useEffectEvent`, a React 19.2 API, and does not apply here (§0).

## 10. Security

- **Never `dangerouslySetInnerHTML`** with server/user content. If unavoidable, sanitize
  (DOMPurify) and justify in a comment. React escapes by default — don't defeat it.
- **Client-side authorization is display logic, not enforcement.** Hiding a button is UX; the
  backend must authorize every action. Never treat an RBAC check in the SPA as a control.
- **No secrets in the frontend.** Anything in `import.meta.env` shipped to the browser is public —
  no API keys or signing secrets. Only `VITE_`-prefixed public config.
- Tokens: prefer httpOnly cookies; if `localStorage` is used, accept the XSS exposure, keep TTLs
  short, and clear on logout. Never log or put a token in a URL/query param.
- Validate and allow-list any URL used in `href`/`src`/redirect (block `javascript:`, open redirects);
  `rel="noopener noreferrer"` on `target="_blank"`.
- Never render raw backend errors/stack traces to users; no PII or tokens in `console`.

## 11. Accessibility

Target **WCAG 2.2 Level AA**. Criterion numbers are given so a review finding can be escalated to a
real conformance failure rather than argued as taste; Level A items are the floor, not a
nice-to-have.

- Semantic elements first (`button`, `nav`, `table`); ARIA only to fill genuine gaps — the First
  Rule of ARIA Use.
- Every input has a **programmatically associated label** (SC 1.3.1, A), and a label must exist at
  all wherever content requires input (SC 3.3.2, A).
- **Errors: identify the field *and* describe the error in text** (SC 3.3.1, A) — a red border with
  no message fails, which is stronger than "not colour alone". Link the message with
  `aria-describedby` and set `aria-invalid` on the control. (W3C's forms tutorial endorses
  `aria-describedby`; MDN recommends `aria-errormessage`, which is semantically tighter. Pick one
  and stay consistent. Don't set `aria-invalid` on an untouched required field before a submit
  attempt.) Encoding the error by colour alone is a separate failure — SC 1.4.1, A.
- **Icon-only buttons need an accessible name** (`aria-label`) — SC 4.1.2, A.
- Keyboard reachable and operable (SC 2.1.1, A). **Visible focus** — never remove an outline
  without a replacement (SC 2.4.7, AA; doing so is documented failure F78). A focused row or field
  must also not end up **entirely hidden** behind a sticky AppBar, a sticky DataGrid header, or an
  open Snackbar (SC 2.4.11, AA — new in WCAG 2.2). The quantified indicator spec (≥ 2 CSS px
  perimeter, 3:1 focused-vs-unfocused) is SC 2.4.13, **AAA** — aim for it, but it is not required
  at AA.
- Dialogs move focus inside on open, wrap Tab within, and return focus to the invoking element on
  close (WAI-ARIA APG Modal Dialog pattern). MUI `Dialog`/`Modal` does all three by default — don't
  fight it, and only set `disableAutoFocus`/`disableEnforceFocus`/`disableRestoreFocus` with a
  documented reason. The focus trap is permitted **only because the user can escape it**, so keep
  the dialog keyboard-dismissible — Escape plus a visible Cancel/Close (SC 2.1.2, A). MUI does
  **not** label the dialog for you: add `aria-labelledby` pointing at the `DialogTitle` id, and
  `aria-describedby` where there is descriptive body text.
- **Contrast:** body text ≥ 4.5:1 (SC 1.4.3, AA); large text — ≥ 18pt, or ≥ 14pt bold — may drop
  to 3:1. Non-text parts need ≥ 3:1 against adjacent colours (SC 1.4.11, AA): chip fills and
  borders, icon glyphs, input outlines, focus rings. And don't encode status by colour alone — add
  text or an icon (SC 1.4.1, A). Both ratios matter for status chips and badges.
- Announce async results (toast / `role="status"`, a sufficient technique for SC 4.1.3, AA) so a
  screen-reader user learns the save succeeded without focus moving.
- Avoid `autoFocus` unless there's a strong, deliberate UX reason. This one is a **usability
  judgement, not a WCAG requirement** — no success criterion forbids it — but MDN documents real
  harms: screen readers "teleport" the user to the control with no warning, the page can scroll on
  load, and touch keyboards pop up.

## 12. Tooling Gates

Run before calling work complete, from the app root:

```bash
npm run typecheck     # tsc --noEmit — must be clean
npm run lint          # eslint src (--max-warnings 0)
npm run build         # tsc && vite build — must succeed
# npm test            # once Vitest is set up
```

**Measure the baseline before you trust a gate.** Run each command on an unmodified checkout and
record what it reports — total lint problems and their breakdown by rule, and whether typecheck and
build pass. Without that number you cannot tell your regressions from inherited debt.

If a gate is already red on an unmodified checkout, that pre-existing debt is not yours — but it
means **"the build passes" is not a signal**. In that case verify your change against the files you
touched (`npm run lint <paths>`, `tsc --noEmit` output filtered to them) and by running the app,
and fix the baseline failure separately if it is blocking.

- **Never introduce a new warning.** Leave files you touch at or below their previous count.
- Don't "fix" the baseline wholesale in an unrelated change — that buries the real diff.
- Never add `eslint-disable` without a reason comment; never disable a rule repo-wide to go green.
- `--max-warnings 0` means a non-zero baseline fails the whole command; while that is true, treat
  *your* files as the gate until the debt is burned down.

## 13. AI Agent Rules

1. **Read neighbouring code first** and match existing patterns. Repo convention beats this doc.
2. **Follow the structure**: `pages/<feature>/` + `components/`, hooks for logic, `interfaces/` for
   shared types. Don't invent a parallel tree.
3. **Don't grow a file that already exceeds the size limits** (§2) — extract the part you touch.
4. **No new `any`**, no `@ts-ignore`, no new lint warnings.
5. **Server state via Refine hooks**; URL state via `useSearchParams`. Never mirror server data
   into `useState`.
6. **Every async path gets loading, empty, and error states.** Every mutation handles failure.
7. **Never invent business rules** — credit limits, tax, rounding, status transitions, SLAs. Ask.
8. **Never guess at money or date semantics.** INR formatting via the shared helper; UTC↔local
   explicitly at the boundary.
9. **State assumptions** in your response when proceeding under ambiguity.
10. **Keep the diff focused** — no drive-by refactors or reformatting untouched files.
11. **Run the gates and report real output.** Never claim a typecheck/lint/test you didn't run.
    Say so plainly if one fails.
12. **Flag security-relevant changes** (auth, RBAC display, tokens, `dangerouslySetInnerHTML`,
    URL handling) in your summary.
13. **No commits unless asked.**

## 14. Review Checklist

Flag real defects only; cite `file:line` and the user-visible consequence.

**Architecture** — file over 250 lines or component over ~120? logic that belongs in a hook sitting
in JSX? component defined inside a component? prop-drilling past 2 levels? duplication that should
be extracted, or premature abstraction that shouldn't?

**Naming** — domain-accurate, not `data`/`tmp`/`item`? `handle*`/`on*` split right? booleans
`is/has/can`? units in the name? magic numbers/strings replaced by named constants?

**State** — server data mirrored into `useState`? filters/pagination/tab in component state instead
of the URL? two states that can disagree? `useEffect`+`setState` deriving what render could compute?
context value unmemoized or over-broad?

**Types** — new `any`/`@ts-ignore`? API response typed at the boundary? optional-flag soup where a
discriminated union belongs? `tsc` clean?

**Errors** — error boundary covering this subtree? mutation failure surfaced and input preserved?
empty `catch`? 401/403/422/5xx distinguished? non-idempotent write auto-retried? loading/empty/error
all present? PII or tokens logged?

**Forms** — schema validation? submit disabled while submitting (double-post risk)? server field
errors mapped back? `watch()` on the whole form? dirty-navigation guard? money precision and
timezone handled explicitly? `autoFocus` added without a reason (UX opinion, not a conformance
failure)?

**Testing** — new logic covered incl. error/empty/permission paths? behaviour not implementation?
deterministic (no real clock/network)? regression test for a bug fix?

**Performance** — sequential awaits that could be parallel? `await` in a loop? heavy component not
lazy? hand-written query key missing a parameter, or a filter closed over instead of passed as a
Refine hook prop? unbounded list fetch? `.find()` in a render loop? array index as `key`? `&&` with
a numeric left side? MUI barrel import (dev-time and lint cost, not shipped bytes)?

**Hooks** — conditional hook? dep array incomplete or suppressed? missing cleanup?

**Security** — `dangerouslySetInnerHTML`? client-side RBAC treated as enforcement? secret in
`import.meta.env`? unvalidated URL/redirect? missing `noopener`? raw backend error shown to user?

**A11y** — inputs labelled (SC 1.3.1) and errors described in text, not just a red border
(SC 3.3.1)? icon-only button named (SC 4.1.2)? keyboard reachable (SC 2.1.1), focus visible
(SC 2.4.7) and not hidden behind a sticky header (SC 2.4.11)? non-text contrast ≥ 3:1 on chips,
outlines and focus rings (SC 1.4.11)? status conveyed by colour alone (SC 1.4.1)? dialog labelled
and Escape-dismissible (SC 2.1.2)?

**Gates** — typecheck, lint, build green; no new warnings in touched files; no unexplained
`eslint-disable`.

## 15. References

This document was written on **2026-07-31** as an adaptation of Vercel's MIT-licensed
react-best-practices skill plus established React/TypeScript practice, and **no URLs were captured
at the time**. Every source below was fetched and read afterwards, on **2026-08-20**, and the rules
above were corrected wherever a source disagreed with them; the closing note records what those
corrections were and what still rests on nothing but practice. Nothing is listed here because a
search result mentioned it, and an HTTP 200 was not accepted as evidence — each page was read.

### Upstream attribution — the base of this document and its licence obligation

- [Vercel Engineering — Introducing: React Best Practices](https://vercel.com/blog/introducing-react-best-practices) — the announcement post (published 14 January 2026; Shu Ding and Andrew Qu). Confirms the rule set is Vercel's and supplies its framing: "It includes 40+ rules across 8 categories, ordered by impact, from CRITICAL (eliminating waterfalls, reducing bundle size) to incremental (advanced patterns)", the eight category names, and that the practices ship as Agent Skills. States no licence and no version number, and its "40+" disagrees with the 70 rules the repository now contains — an upstream inconsistency, not a defect here (checked 2026-08-20).
- [vercel-labs/agent-skills — skills/react-best-practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) — confirms the upstream skill exists at exactly the path cited at the top of this document, with `AGENTS.md`, `README.md`, `SKILL.md`, `metadata.json` and `rules/`. Repo default branch `main`; last commit touching this directory `dc8367e6f91c` (2026-04-14) (checked 2026-08-20).
- [vercel-labs/agent-skills — skills/react-best-practices/rules](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices/rules) — the authoritative rule-ID list, and the source of this document's traceability claim. Enumerated via the GitHub contents API: 72 files = 70 rule files plus `_sections.md` and `_template.md`. **All 59 rule identifiers cited in this document exist upstream as `rules/<id>.md`; none is invented.** The 11 upstream rules omitted here are all server/SSR-scoped and consistent with an SPA target (`async-api-routes`, `rendering-hydration-no-flicker`, `rendering-hydration-suppress-warning`, `server-after-nonblocking`, `server-cache-lru`, `server-dedup-props`, `server-hoist-static-io`, `server-no-shared-module-state`, `server-parallel-fetching`, `server-parallel-nested-fetching`, `server-serialization`) (checked 2026-08-20).
- [vercel-labs/agent-skills — skills/react-best-practices/SKILL.md](https://github.com/vercel-labs/agent-skills/blob/main/skills/react-best-practices/SKILL.md) — both halves of the "(MIT, v1.0.0)" attribution in this document's frontmatter: `license: MIT` and `metadata: author: vercel, version: "1.0.0"`. Body: "Comprehensive performance optimization guide for React and Next.js applications, maintained by Vercel. Contains 70 rules across 8 categories, prioritized by impact". Also supplies upstream's one-line gloss for each cited rule, against which the paraphrases above were checked (checked 2026-08-20).
- [vercel-labs/agent-skills — skills/react-best-practices/metadata.json](https://github.com/vercel-labs/agent-skills/blob/main/skills/react-best-practices/metadata.json) — `"version": "1.0.0"`, `"organization": "Vercel Engineering"`, `"date": "January 2026"`, which is what makes the phrase "Vercel Engineering's react-best-practices" accurate (checked 2026-08-20).
- [vercel-labs/agent-skills — README.md](https://github.com/vercel-labs/agent-skills/blob/main/README.md) — the only place the MIT licence is stated in prose ("## License" / "MIT"). **Caveat that matters for redistribution:** the repository has no `LICENSE`, `LICENSE.md` or `LICENSE.txt` (all 404), the GitHub license endpoint returns `null`, and there is no copyright line — so there is no upstream MIT text or copyright holder to reproduce. `/releases` and `/tags` are both empty, so "v1.0.0" is a string in a JSON file, not a git-resolvable pin; hence the commit-pinned link at the top of this document (checked 2026-08-20).
- [vercel-labs/agent-skills — skills/react-best-practices/README.md](https://github.com/vercel-labs/agent-skills/blob/main/skills/react-best-practices/README.md) — the identifier scheme this document borrows: "Rule files: `area-description.md` (e.g., `async-parallel.md`)" with the prefixes `async-`, `bundle-`, `server-`, `client-`, `rerender-`, `rendering-`, `js-`, `advanced-`. Provenance: "Originally created by @shuding at Vercel" (checked 2026-08-20).
- [vercel-labs/agent-skills — rules/_sections.md](https://github.com/vercel-labs/agent-skills/blob/main/skills/react-best-practices/rules/_sections.md) — the eight categories and their impact levels, which §8 mirrors: waterfalls CRITICAL, bundle size CRITICAL, server HIGH, client data fetching MEDIUM-HIGH, re-renders MEDIUM, rendering MEDIUM, JavaScript LOW-MEDIUM, advanced LOW (checked 2026-08-20).
- Individual upstream rule files, read from `raw.githubusercontent.com` to check that §0's exclusions and §8's inclusions are each justified: `server-auth-actions`, `server-after-nonblocking`, `server-cache-react`, `server-serialization`, `server-dedup-props`, `rendering-hydration-no-flicker`, `rendering-hydration-suppress-warning`, `client-swr-dedup` (every §0 exclusion is genuinely Next/RSC/SSR-scoped), and `async-suspense-boundaries`, `bundle-dynamic-imports`, `rendering-script-defer-async`, `rendering-resource-hints`, `rendering-activity`, `bundle-defer-third-party`, `advanced-init-once`, `rerender-derived-state` (three of which turned out to be Next- or React-19-scoped and are now flagged as such above) (checked 2026-08-20).

### React

- [React 19.2 release post](https://react.dev/blog/2025/10/01/react-19-2) — dates two corrections above: `<Activity>` and `useEffectEvent` are both **new in 19.2** and do not exist on React 18, which is why `rendering-activity` and `advanced-effect-event-deps` are excluded in §0 (checked 2026-08-20).
- [React 19 release post](https://react.dev/blog/2024/12/05/react-19) — "Support for preloading resources": `prefetchDNS`, `preconnect`, `preload`, `preinit` are **React 19** `react-dom` APIs, which is why `rendering-resource-hints` is excluded. Also the React-19-only list in §0: Actions in `startTransition`, `useActionState`, `useOptimistic`, `useDeferredValue` initial value, `ref` as a prop, ref cleanup functions, `use` (checked 2026-08-20).
- [React v18.0 release post](https://react.dev/blog/2022/03/29/react-v18) — the baseline for §0's stated target, and the source for §8's Suspense caveat, quoted rather than paraphrased: "In React 18, you can start using Suspense for data fetching in opinionated frameworks like Relay, Next.js, Hydrogen, or Remix. Ad hoc data fetching with Suspense is technically possible, but still not recommended as a general strategy." That is the opposite of an endorsement for a plain Vite SPA, which is exactly why §8 scopes `<Suspense>` to `React.lazy` chunks and an explicitly opted-in data layer (checked 2026-08-20).
- [How to Upgrade to React 18](https://react.dev/blog/2022/03/08/react-18-upgrade-guide) — the direct refutation of §9's former warning claim: "No warning about `setState` on unmounted components ... We've removed this warning." (checked 2026-08-20).
- [facebook/react — CHANGELOG.md](https://raw.githubusercontent.com/facebook/react/main/CHANGELOG.md) — independent confirmation of the same removal, filed under React 18.0.0 (checked 2026-08-20).
- [React — Versions](https://react.dev/versions) — "Latest version: 19.2", with React 18 archived at `18.react.dev`. This is why §0 carries an explicit version-boundary note: every current react.dev page describes an API set wider than this stack has (checked 2026-08-20).
- [React — Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks) — §9's rule, including the restrictions the earlier wording omitted: not in conditions or loops, not after a conditional return, not in event handlers, not in class components, not inside functions passed to `useMemo`/`useReducer`/`useEffect`, and not inside `try`/`catch`/`finally` (checked 2026-08-20).
- [React — Synchronizing with Effects](https://react.dev/learn/synchronizing-with-effects) — §9's "effects synchronize with external systems" and the cleanup rule, including the documented consequence of a missing cleanup (connections piling up; aborting or ignoring a stale fetch result) (checked 2026-08-20).
- [React — You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect) — §3's "derive, don't duplicate" and `rerender-derived-state-no-effect`: "When something can be calculated from the existing props or state, don't put it in state. Instead, calculate it during rendering." Also the `key`-to-reset-state pattern (checked 2026-08-20).
- [React — Preserving and Resetting State](https://react.dev/learn/preserving-and-resetting-state) — the mechanism behind §3's "reset child state on identity change with a `key`": "Specifying a key tells React to use the key itself as part of the position" (checked 2026-08-20).
- [React — Rendering Lists](https://react.dev/learn/rendering-lists) — §8's key rule verbatim: keys unique among siblings, keys must not change, "Index as a key often leads to subtle and confusing bugs", "use a stable ID based on the data" (checked 2026-08-20).
- [React — `useState`](https://react.dev/reference/react/useState) — `rerender-lazy-state-init` ("If you pass a function to useState, React will only call it during initialization") and `rerender-functional-setstate`, though the page justifies updater functions on queued-update correctness and not on callback stability (checked 2026-08-20).
- [React — `useReducer`](https://react.dev/reference/react/useReducer) — §3's reducer guidance: it "lets you move the state update logic from event handlers into a single function outside of your component" (checked 2026-08-20).
- [React — Extracting State Logic into a Reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer) — the reason §3's "3+ fields" line is now labelled a house convention: React gives no numeric threshold and says outright "Personal preference: Some people like reducers, others don't. That's okay." (checked 2026-08-20).
- [React — `useTransition`](https://react.dev/reference/react/useTransition) — `rerender-transitions` and `rendering-usetransition-loading`. Read carefully: the current page documents React 19 Actions (async functions in `startTransition`, `isPending` spanning Actions, `useActionState`), none of which exist on React 18 (checked 2026-08-20).
- [React — `useDeferredValue`](https://react.dev/reference/react/useDeferredValue) — `rerender-use-deferred-value`, including "Unlike debouncing or throttling, it doesn't require choosing any fixed delay". The second `initialValue` parameter is React 19+ (checked 2026-08-20).
- [React — `Component`](https://react.dev/reference/react/Component) — the not-caught half of the corrected §5 sentence, verbatim: boundaries do not catch errors for "Event handlers ... Server side rendering ... Errors thrown in the error boundary itself (rather than its children) ... Asynchronous code (e.g. `setTimeout` or `requestAnimationFrame` callbacks); an exception is the usage of the `startTransition` function returned by the `useTransition` Hook. Errors thrown inside the transition function are caught by error boundaries". Note what this page does **not** say: it frames what *is* caught as errors "during rendering", and nowhere states the lifecycle-method/constructor half of §5 — that comes from the archived page below, not from here (checked 2026-08-20).
- [React (legacy docs) — Error Boundaries](https://legacy.reactjs.org/docs/error-boundaries.html) — the only React-maintained page that states §5's wider scope in so many words: "Error boundaries catch errors during rendering, in lifecycle methods, and in constructors of the whole tree below them." Its not-caught list (event handlers, asynchronous code, server-side rendering, errors thrown in the boundary itself) agrees with the current page. This is archived React 17-era documentation for the class API §5 depends on, and is no longer maintained — it is cited for that one sentence and nothing else (checked 2026-08-20).
- [React — `lazy`](https://react.dev/reference/react/lazy) — §0 and §8's `React.lazy` + `<Suspense>` requirement, "Always declare lazy components at the top level of your module" (which reinforces `rerender-no-inline-components`), and the second §5 exception: "If the Promise rejects, React will throw the rejection reason to the nearest Error Boundary" (checked 2026-08-20).
- [React — Conditional Rendering](https://react.dev/learn/conditional-rendering) — `rendering-conditional-render`, verbatim: "Don't put numbers on the left side of `&&`. ... React will happily render 0 rather than nothing." (checked 2026-08-20).
- [React — `use`](https://react.dev/reference/react/use) — the version-sensitivity check on §9's Rules-of-Hooks line: "Despite its name, use is not a Hook. Unlike Hooks, it can be called inside loops and conditional statements like if." React 19+ only (checked 2026-08-20).
- [React — `<Activity>`](https://react.dev/reference/react/Activity) — the behaviour `rendering-activity` wants. The reference page carries no "available since" note, so the React 19.2 version gate comes from the release post above, not from here (checked 2026-08-20).
- [React — `react-dom` `preload`](https://react.dev/reference/react-dom/preload) — the resource-hint API `rendering-resource-hints` depends on; likewise carries no version badge, so the React 19 gate comes from the release post (checked 2026-08-20).
- [React — Using TypeScript](https://react.dev/learn/typescript) — §4's "type props explicitly", typing `children` as `React.ReactNode`. Notably it says **nothing** about `React.FC` and nothing about `ComponentProps`, so neither half of that §4 bullet is supported by react.dev (checked 2026-08-20).
- [React — React Compiler introduction](https://react.dev/learn/react-compiler/introduction) — the §8 memoization footnote: "By default, React Compiler will memoize your code based on its analysis and heuristics. In most cases, this memoization will be as precise, or moreso, than what you may have written", with `useMemo`/`useCallback` left as "an escape hatch". Supports React 17, 18 and 19 (checked 2026-08-20).
- [React 18 archived docs — `Component`](https://18.react.dev/reference/react/Component) — fetched to try to confirm the error-boundary exclusion list against React 18 specifically. The page loaded, but the retrieved content did not contain that list, so §5's `startTransition` exception is confirmed only against the current 19.2 page (checked 2026-08-20).

### TypeScript

- [TypeScript 4.9 release notes — the `satisfies` operator](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html) — §4's `satisfies` rule, quoted as the page states it: the operator "lets us validate that the type of an expression matches some type, without changing the resulting type of that expression". Available since 4.9, so safe on TypeScript 5.4 (checked 2026-08-20).
- [TypeScript Handbook — Narrowing (discriminated unions)](https://www.typescriptlang.org/docs/handbook/2/narrowing.html) — §4's "discriminated unions over optional-flag soup", including the exact antipattern: the optional-property shape forces non-null assertions and is "error-prone if we start to move code around" (checked 2026-08-20).
- [TypeScript 3.8 release notes — type-only imports and export](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html) — §4's `import type` rule and the reason §8's type-only-barrel carve-out is sound: `import type` "only imports declarations to be used for type annotations and declarations. It always gets fully erased, so there's no remnant of it at runtime." (checked 2026-08-20).
- [`@types/react` 18.3.31 — `index.d.ts`](https://unpkg.com/@types/react@18.3.31/index.d.ts) — the factual basis of the corrected §4 `React.FC` bullet: `interface FunctionComponent<P = {}> { (props: P, ...): ReactNode; ... }` has **no implicit `children`** in the React 18 typings, and `VFC`/`VoidFunctionComponent` are deprecated as "Equivalent to React.FunctionComponent". Also the only canonical confirmation of `ComponentProps`, carrying the exact example `type MyComponentProps = React.ComponentProps<typeof MyComponent>;` (checked 2026-08-20).
- [React TypeScript Cheatsheet — Function Components](https://react-typescript-cheatsheet.netlify.app/docs/basic/getting-started/function_components) — a community document, not a canonical home, but the page `@types/react`'s own JSDoc links to for this question: "The general consensus today is that React.FunctionComponent (or the shorthand React.FC) is not needed", on `defaultProps` and return-typing grounds (checked 2026-08-20).

### Forms — react-hook-form, resolvers, Zod

- [react-hook-form — `Controller`](https://react-hook-form.com/docs/usecontroller/controller) — §6's MUI wiring: "it's hard to avoid working with external controlled components such as React-Select, AntD and MUI. This wrapper component makes it easier for you to work with them", and the `field.ref` note that it "only works if the target component forwards refs (React.forwardRef) or exposes an equivalent, like MUI's `inputRef`" — which is why §6 now names ref exposure as the criterion (checked 2026-08-20; the site returns 403 to `WebFetch`, so it was read with `curl` and a browser user-agent).
- [react-hook-form — Get Started, integrating with UI libraries](https://react-hook-form.com/get-started) — the documented trigger, stated plainly: "If the component doesn't expose the input's ref, then you should use the Controller component, which will take care of the registration process." (checked 2026-08-20).
- [react-hook-form — FAQs, performance](https://react-hook-form.com/faqs) — §6's re-render claim: react-hook-form "relies on an uncontrolled form, which is why the register function captures a ref directly instead of value/onChange", and for components that must stay controlled, `Controller`/`useController` "isolate re-renders to just that field instead of the whole form" (checked 2026-08-20).
- [react-hook-form — `useWatch`](https://react-hook-form.com/docs/usewatch) — §6's "subscribe narrowly": `useWatch` "isolates re-rendering at the custom hook level, which can result in better performance for your application" (checked 2026-08-20).
- [react-hook-form — `watch`](https://react-hook-form.com/docs/useform/watch) — the warning §6 relies on: "This API will trigger a re-render at the root of your application or form. Consider using a callback or the useWatch API if you experience performance issues." (checked 2026-08-20).
- [react-hook-form — `setError`](https://react-hook-form.com/docs/useform/seterror) — §6's server-error mapping, including the form-level channel: since v7.43.0 "You can set a server or global error with `root` as the key". Also the caveat that `setError` on a registered input is not persisted if the field's own rules pass (checked 2026-08-20).
- [react-hook-form — `formState`](https://react-hook-form.com/docs/useform/formstate) — §6's `isSubmitting` (double-submit guard) and `isDirty` (navigate-away guard), including the requirement to supply all `defaultValues` for `isDirty` to be meaningful (checked 2026-08-20).
- [react-hook-form — `reset`](https://react-hook-form.com/docs/useform/reset) — §6's post-submit reset: "Reset the entire form state, fields reference, and subscriptions." (checked 2026-08-20).
- [react-hook-form — `useFieldArray`](https://react-hook-form.com/docs/usefieldarray) — a current, first-class, non-deprecated API: "Custom hook for working with Field Arrays (dynamic forms)". This is why an earlier claim that `useFieldArray` was "not exported from the installed react-hook-form" has been removed from this document: that was a local install or resolution defect, never a library limitation (checked 2026-08-20).
- [react-hook-form — package type entrypoint `dist/index.d.ts`](https://unpkg.com/react-hook-form/dist/index.d.ts) — hard evidence for the same point: every version inspected (7.85.0, 7.51.0, 7.45.0, 7.0.0 and 6.15.8) contains `export * from './useFieldArray';` at the package root. There is no published release in which it is missing (checked 2026-08-20).
- [`@hookform/resolvers` — README](https://github.com/react-hook-form/resolvers) — §6's "schema-validate ... infer the TS type from the schema": Yup and Zod are both supported and both marked as inferring values from the schema, with `useForm({ resolver: zodResolver(schema) })` inferring automatically. Also documents the `.default()` input-versus-output gotcha when pinning a single generic on `useForm<T>` (checked 2026-08-20).
- [Zod — Basic usage](https://zod.dev/basics) — the inference half of the same rule: "Zod infers a static type from your schema definitions. You can extract this type with the `z.infer<>` utility." (checked 2026-08-20).

### Routing, data layer, MUI

- [React Router v6 — `useSearchParams`](https://reactrouter.com/6.30.0/hooks/use-search-params) — §3 and §13's URL-state rule: the hook "is used to read and modify the query string in the URL for the current location" and returns the current params plus an updater, with functional updates and `{replace, preventScrollReset}` options. The page carries an "older release" banner (current line: 6.30.6; latest major: 8.x), but the hook is not deprecated and survives into v7/v8 (checked 2026-08-20).
- [Refine — `useList`](https://refine.dev/docs/data/hooks/use-list/) — §0's justification for banning SWR, stated literally: `useList` "is an extended version of TanStack Query's useQuery that supports all of its features", and "It uses a query key to cache the data. The query key is generated from the provided properties." That generated key is why §8's query-key rule is now scoped to Refine's hook properties (checked 2026-08-20).
- [Refine — `useUpdate`](https://refine.dev/docs/data/hooks/use-update/) — with `use-one/` and `use-custom/` read alongside it: every Refine hook §3 names exists, is current, and is documented as an extension of TanStack Query's `useQuery`/`useMutation`. None carries a deprecation notice (checked 2026-08-20).
- [`@refinedev/core` — package metadata](https://registry.npmjs.org/@refinedev/core/latest) — dependency-level proof that "Refine wraps TanStack Query" is not a figure of speech: version 5.0.12 lists `"@tanstack/react-query": "^5.81.5"` as both a dependency and a peer dependency (checked 2026-08-20).
- [TanStack Query — Query Keys](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys) — §8's query-key rule: "query keys act as dependencies for your query functions. Adding dependent variables to your query key will ensure that queries are cached independently, and that any time a variable changes, queries will be refetched automatically." Keys are arrays and are hashed deterministically (checked 2026-08-20).
- [TanStack Query — Query Invalidation](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation) — §8's "invalidate precisely": prefix matching on `['todos']`, narrowing with a more specific key, and `exact: true` (checked 2026-08-20).
- [TanStack Query — Overview](https://tanstack.com/query/latest/docs/framework/react/overview.md) — the "already dedupes and caches" half of §0's SWR ban and §3's warning about hand-rolling fetches: the library handles caching and "Deduping multiple requests for the same data into a single request" (checked 2026-08-20).
- [MUI — Minimizing bundle size](https://mui.com/material-ui/guides/minimizing-bundle-size/) — the source that forced the correction in §8: "Modern bundlers already tree-shake unused code in production builds, so you don't need to worry about it when using top-level imports. The real performance concern is during development, where barrel imports ... can cause significantly slower startup and rebuild times." Path imports are still marked "Preferred", with `no-restricted-imports` on `^@mui/[^/]+$` as the lint gate (checked 2026-08-20).
- [MUI v5.x — `minimizing-bundle-size.md` source](https://raw.githubusercontent.com/mui/material-ui/v5.x/docs/data/material/guides/minimizing-bundle-size/minimizing-bundle-size.md) — the same correction in the docs for the major this stack pins: "you can safely use named imports and still get an optimized bundle size automatically", and the instructions are "only needed if you want to optimize your development startup times or if you are using an older bundler that doesn't support tree-shaking" (checked 2026-08-20).
- [MUI — Modal component](https://mui.com/material-ui/react-modal/) — §11's dialog claim: "It properly manages focus; moving to the modal content, and keeping it there until the modal is closed", "Adds the appropriate ARIA roles automatically", and the limitation that you must supply `aria-labelledby`/`aria-describedby` yourself. MUI v5's `dialogs.md` routes Dialog accessibility to this page (checked 2026-08-20).
- [MUI — Modal API](https://mui.com/material-ui/api/modal/) — the "restores focus" half, which no guide page states: `disableRestoreFocus` defaults to `false`, so restoration is on by default; likewise `disableEnforceFocus` and `disableAutoFocus`. Cross-checked against `packages/mui-material/src/Modal/Modal.js` on the v5.x branch (checked 2026-08-20).
- [MUI X — Migration from Data Grid v5 to v6](https://raw.githubusercontent.com/mui/mui-x/v6.x/docs/data/migration/migration-data-grid-v5/migration-data-grid-v5.md) — dates the prop names in §8: "The `components` and `componentsProps` props are being renamed to `slots` and `slotProps`", so `slots` is a Data Grid **v6+** API and v5 uses `components`/`componentsProps` (read from the `v6.x` branch; checked 2026-08-20).

### Accessibility — W3C and MDN

§11 originally carried no citations at all. Each of its claims was verified independently against
these primary sources, which is why the section now names criterion numbers and conformance levels.

- [WCAG 2.2 — SC 1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) — the 4.5:1 body-text figure, Level AA, plus the large-text exception (3:1 at ≥ 18pt or ≥ 14pt bold) that §11 previously omitted (checked 2026-08-20).
- [WCAG 2.2 — SC 1.4.11 Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html) — the 3:1 requirement for UI components and graphical objects, Level AA: chip fills and borders, icon glyphs, input outlines, focus indicators. Added to §11, which formerly gave only 4.5:1 (checked 2026-08-20).
- [WCAG 2.2 — SC 1.4.1 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html) — §11's "don't encode status by colour alone", Level A, and the note that a supplementary indicator is still needed where perceiving a specific colour is required — exactly the red/green status-chip case (checked 2026-08-20).
- [WCAG 2.2 — SC 1.3.1 Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html) — §11's programmatically associated label, Level A; sufficient technique H44 (checked 2026-08-20).
- [WCAG 2.2 — SC 3.3.2 Labels or Instructions](https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions.html) — the companion requirement that a label exist at all where input is required, Level A (checked 2026-08-20).
- [WCAG 2.2 — SC 4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html) — §11's icon-only-button rule, Level A; the page lists "Button has non-empty accessible name" as an approved ACT test rule (checked 2026-08-20).
- [WCAG 2.2 — SC 3.3.1 Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html) — the requirement that replaced §11's weaker "not colour alone" wording: the item in error is identified **and** the error is described to the user in text, Level A (checked 2026-08-20).
- [WCAG 2.2 — SC 2.1.1 Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html) — §11's keyboard operability, Level A (checked 2026-08-20).
- [WCAG 2.2 — SC 2.1.2 No Keyboard Trap](https://www.w3.org/WAI/WCAG22/Understanding/no-keyboard-trap.html) — the condition that makes a dialog focus trap legal: restricting focus "does not fail the requirements of this criterion, as long as the user knows how to 'untrap' the focus and leave that component". Level A. This is why §11 now requires the dialog to be keyboard-dismissible (checked 2026-08-20).
- [WCAG 2.2 — SC 2.4.7 Focus Visible](https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html) — §11's visible-focus rule, Level AA (checked 2026-08-20).
- [WCAG 2.2 — Failure F78](https://www.w3.org/WAI/WCAG22/Techniques/failures/F78) — verbatim backing for "never remove an outline without a replacement": a documented failure of SC 1.4.11, 2.4.7 and 2.4.13 when the default focus indication is "turned off or rendered non-visible by other styling on the page without providing an author-supplied visual focus indicator" (checked 2026-08-20).
- [WCAG 2.2 — SC 2.4.11 Focus Not Obscured (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html) — new in WCAG 2.2, Level AA, and the requirement this stack is most likely to trip: a focused component must not be entirely hidden by author content — sticky AppBar, sticky DataGrid header, open Snackbar. Added to §11 (checked 2026-08-20).
- [WCAG 2.2 — SC 2.4.13 Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html) — establishes that the quantified indicator spec (≥ 2 CSS px perimeter, 3:1 focused-versus-unfocused) is Level **AAA**, not AA, which is how §11 now frames it (checked 2026-08-20).
- [WCAG 2.2 — SC 4.1.3 Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html) — §11's async-result announcement, Level AA: status messages must be programmatically determinable "without receiving focus" (checked 2026-08-20).
- [WCAG 2.2 — Technique ARIA22](https://www.w3.org/WAI/WCAG22/Techniques/aria/ARIA22) — confirms `role="status"` is a *sufficient technique* for SC 4.1.3 (implicit `aria-live="polite"`, implicit `aria-atomic="true"`), so §11's toast advice is supported — the role is the technique, not the criterion (checked 2026-08-20).
- [WCAG 2.2 — SC 3.2.1 On Focus](https://www.w3.org/WAI/WCAG22/Understanding/on-focus.html) — the negative result behind §11's `autoFocus` demotion: the nearest focus-related criterion forbids only a *change of context* on receiving focus. No success criterion prohibits automatic focus placement (checked 2026-08-20).
- [WAI-ARIA Authoring Practices Guide — Modal Dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/) — the actual source of the trap-and-restore behaviour §11 describes: focus moves inside on open, Tab wraps from last to first tabbable element, focus returns to the invoking element on close. An APG pattern, not a WCAG success criterion (checked 2026-08-20).
- [W3C — Using ARIA, First Rule of ARIA Use](https://www.w3.org/TR/using-aria/) — §11's "semantic elements first, ARIA only to fill genuine gaps" (checked 2026-08-20).
- [W3C WAI Forms Tutorial — User Notifications](https://www.w3.org/WAI/tutorials/forms/notifications/) — W3C's own endorsement of §11's mechanism: "form fields can be associated with the corresponding error message using aria-describedby." (checked 2026-08-20).
- [MDN — `autofocus`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/autofocus) — the only real support for §11's `autoFocus` caution: screen-readers "'teleport' their user to the form control without warning them beforehand", the page can scroll on load, and touch keyboards can appear. MDN asks for "careful consideration"; it states no conformance requirement (checked 2026-08-20).
- [MDN — `aria-invalid`](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Reference/Attributes/aria-invalid) — §11's `aria-invalid` half: the four values, the rule that it should be set by validation rather than on an empty required field before submit (now reflected in §11), and MDN's preference for `aria-errormessage` (checked 2026-08-20).
- [MDN — `aria-describedby`](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Reference/Attributes/aria-describedby) — its role for form-control supplementary text, and the label-versus-description distinction (checked 2026-08-20).
- [MDN — `aria-errormessage`](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Reference/Attributes/aria-errormessage) — the alternative mechanism MDN prefers, read so §11 can name the disagreement rather than pretend there isn't one (checked 2026-08-20).

### What is not sourced

Read this before treating anything above as settled.

**Corrections made on 2026-08-20, listed so the record shows them.** Verification found five false
or contradicted claims in the 2026-07-31 text, all now fixed in place: three upstream rules cited as
applicable are React 19 APIs unavailable on the React 18 target (`rendering-activity`,
`rendering-resource-hints`, `advanced-effect-event-deps`); §9 claimed a missing effect cleanup
produces a set-state-after-unmount warning, which React **removed in 18.0**; §5 claimed error
boundaries catch render errors only, which omits lifecycle methods and the two documented
exceptions; §8 framed MUI barrel imports as the biggest *bundle-size* win and asserted that
component barrels are not erased, both of which MUI's own guide contradicts (the cost is dev-server
time; production tree-shaking already handles it); and a §12 line blamed react-hook-form for not
exporting `useFieldArray`, which every published version does export. The rule identifiers
themselves survived verification intact — all 59 exist upstream.

**Repo conventions with no external source.** The §2 size limits (250 lines, 120-line bodies, depth
4, 8 props), the naming table, §3's "3+ fields" reducer threshold, §7's coverage priorities, §12's
tooling gates and §13's agent rules are this repository's opinions. They are defensible, but do not
cite react.dev for them. The INR-formatting and UTC-boundary rules in §6 and §13 are domain
conventions for this stack, not library guidance.

**Claims resting on general practice.** §5's retry, timeout and status-code-mapping policy; §10's
security rules beyond React's documented escaping; §8's "server-side pagination for large tables"
and "abort stale in-flight responses". Each is mechanically justified by the sources above but is
not quoted from any of them.

**Sourced, but not from a canonical home.** §4's "avoid `React.FC`" — neither react.dev nor the
TypeScript handbook takes a position; the support is `@types/react`'s own typings plus the community
React TypeScript Cheatsheet. `ComponentProps<typeof X>` is confirmed only from the `@types/react`
JSDoc, not from react.dev. §8's `rerender-functional-setstate` "keeps callbacks stable" is sound in
practice but no canonical page states it in those terms. §5's lifecycle-method-and-constructor half
rests on React's **archived** `legacy.reactjs.org` error-boundaries page: the current react.dev
`Component` page scopes what boundaries catch to errors "during rendering" and never mentions
lifecycle methods or constructors, and the React 18 archive did not return that list at all.

**Still unverified.** Whether the upstream rule set on 2026-07-31 matched what was read on
2026-08-20 — the skill directory's last commit predates authoring, so it probably did, but with no
upstream tags or releases it cannot be proven. Whether the MIT grant is formally attached upstream
(no `LICENSE` file, no copyright line). The installed majors of `@mui/x-data-grid` and
`react-hook-form` in any given app, which is why §8 names both Data Grid prop spellings. Whether
`js-tosorted-immutable`'s `Array.prototype.toSorted` (ES2023) clears a given project's browserslist
target. Assistive-technology support for `aria-errormessage` versus `aria-describedby`, which no
primary source quantifies. And whether MUI's dev-time-only framing of barrel imports holds for a
specific Vite config — a `vite build` with and without barrel imports would settle it, and §1 says
to measure before optimizing.
