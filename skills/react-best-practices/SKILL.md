---
name: react-best-practices
description: React/TypeScript engineering standard for Vite + React 18 SPAs built with Refine, MUI, react-hook-form, and react-router v6. Load BEFORE writing, modifying, or reviewing any React code in such an app — anything under src/ (pages/, components/, providers/, hooks) or any .tsx/.ts component, hook, data fetch, form, MUI DataGrid, or theme change. Covers component architecture, naming, state management, TypeScript, error handling, forms, testing, security, accessibility, performance (waterfalls, bundle size, re-renders), and tooling gates.
license: MIT
metadata:
  perf-rules-adapted-from: vercel-labs/agent-skills — skills/react-best-practices (MIT, v1.0.0)
  stack: vite + react 18 + typescript + refine + mui
---

# React Best Practices (Vite + Refine + MUI SPA)

Vite + React 18 SPA (not Next.js), TypeScript 5.4 `strict: true`, `@refinedev/core` + `@refinedev/mui`, MUI 5 (`@mui/material`, `@mui/x-data-grid`, `@mui/x-date-pickers`), `react-hook-form`, `react-router-dom` v6, `axios`, `dayjs`.
When this conflicts with an in-repo convention, follow the repo and say so.

## 1. Stack Boundaries & Layout

```
src/
  pages/<feature>/          # route screens: <Feature>Page.tsx
    components/             #   feature-local components
  components/common/, components/layout/
  providers/                # Refine data/auth providers (dataProvider.ts, authProvider)
  interfaces/               # shared domain types
  config/, theme/, utils/
```

- New feature → `pages/<feature>/<Feature>Page.tsx` + `components/`; reusable across features → `components/common/`; shared types → `interfaces/`. Never create a parallel tree.
- Import through the `@/*` → `src/*` alias, not `../../..` chains.
- Money is INR: format through one shared `Intl.NumberFormat("en-IN", {style:"currency", currency:"INR"})` formatter; never hand-concatenate a symbol or float-accumulate currency.
- Never suggest Next.js/RSC/SSR concepts (`"use client"`, server actions, hydration, `next/*`): lazy-load with `React.lazy`; put `defer`/`async` scripts and `<link rel="preconnect">`/`<link rel="preload">` in `index.html`. No SWR: Refine wraps TanStack Query, which already dedupes and caches.
- React 18 is pinned; its docs are `https://18.react.dev` (react.dev documents 19.x). React-19-only, unavailable here: Actions (async functions in `startTransition`), `useActionState`, `useOptimistic`, `useDeferredValue(value, initialValue)`, `use`, `ref` as a prop, ref cleanup functions, `react-dom` `preload`/`preconnect`, `useEffectEvent`, and `<Activity>` (instead keep an expensive tab panel mounted and hide it with CSS, or hoist its state above the tab switch).

## 2. Components & Naming

- Extract past these limits: component file ≤ 250 lines; component function ≤ 120 lines and ≤ 5 hooks doing unrelated work; JSX nesting ≤ 4; ≤ 8 props (group into an object or split). Never grow a file already over a limit: extract the part you touch into `pages/<feature>/components/`.
- A page composes, child components render sections, custom hooks own data and logic: when a component both fetches/derives and renders a large JSX tree, the fetch/derive half becomes `use<Feature>()` in the feature folder.
- Prefer `children`/slots to a variant-plus-boolean-flags API; past 2 levels of prop drilling, use context or restructure.
- Never define a component inside a component, including DataGrid cell and slot renderers: `renderCell`, plus `slots`/`slotProps` on `@mui/x-data-grid` v6+ or `components`/`componentsProps` on v5 (check the installed major). Hoist, or `useCallback`.
- Naming: internal handlers `handle*` (`handleSubmit`), callback props `on*` (`onApprove`); no `I` prefix on types or interfaces; units in the name (`timeoutMs`, `amountInr`); component file named after its component (`CreditProfileCard.tsx`), not `index.tsx`.
- Never `&&` with a numeric left side (`{count && <X/>}` renders `0`); use a ternary.

## 3. State Management

Pick the location in this order:

1. Server state → Refine hooks (`useList`, `useOne`, `useCustom`, `useUpdate`). Never copy fetched data into `useState`; never hand-roll `useEffect` + `axios` + `setState`.
2. URL state → `useSearchParams`: filters, pagination, sort, active tab and selected-row id live in the URL, not `useState`.
3. Local UI state (open/closed, hover, draft input) → `useState` in the nearest owner; `useReducer` once 3+ fields change together or transitions have rules.
4. Cross-cutting → context, sparingly (auth/user, theme, notifications): one provider per concern, memoized value.

- Derive during render; effects only synchronize with external systems, never `useEffect` + `setState` to compute or sync state. Reset child state on identity change with a `key`.
- Never mutate props, state or Refine query results (the shared TanStack Query cache) in place with `.sort()`/`.reverse()`/`splice`; copy first (`[...rows].sort(...)`).
- Persisted `localStorage` data is versioned and minimal, read once into memory, never in a render path.

## 4. TypeScript

- Keep `strict: true`. No `any`; an unavoidable one carries a justifying comment.
- Type API responses at the boundary in `interfaces/`; don't let `any` from `axios`/`dataProvider` reach components.
- Model mutually exclusive states as discriminated unions (`{status:"loading"} | {status:"error"; error:E} | {status:"ok"; data:D}`), not optional flags.
- `type` for unions/aliases, `interface` for object shapes that may be extended; `import type` for type-only imports (lint enforces).
- Type props explicitly; no `React.FC`. `@types/react` 18 has no implicit `children`: declare `children: React.ReactNode` when accepted. Extend MUI props with `ComponentProps<typeof X>` (`ComponentPropsWithoutRef`/`ComponentPropsWithRef` when ref forwarding matters) rather than restating them.
- Never `@ts-ignore`; `@ts-expect-error` with a reason comment if truly needed.

## 5. Error Handling & Resilience

- Error boundaries around the app shell and each independently failing panel. A failed `React.lazy` chunk load throws to the nearest boundary, so pair every `<Suspense>` with one.
- Map statuses once, in the data provider or axios interceptor: `401` → re-auth; `403` → forbidden view (a `forbidden/` route); `422` → field errors on the form; `5xx`/network → retryable "something went wrong". Never render raw backend errors or stack traces.
- Every mutation handles failure: show a message, keep the user's input, re-enable the control.
- Auto-retry only idempotent reads (GET), bounded with backoff; never auto-retry a non-idempotent write (credit approval, invoice post).
- Creating `POST`s send an `Idempotency-Key` generated once per submitted set of values and reused when the user resends after a timeout or network error; never mint one per request in an interceptor.
- Every request has a timeout; no response is an error state, not a permanent spinner.
- Loading, empty and error are three distinct states; never show empty for an error.
- Log with `console.error` and context; never log PII or tokens.

## 6. Forms & Validation (react-hook-form)

- A schema (zod/yup + resolver) is the single source of validation rules; infer the TS type from it.
- Disable submit while `isSubmitting`, which holds only while the submit handler's promise is pending: `await mutateAsync(...)` (or return Refine's `onFinish`, which waits only under the default `pessimistic` `mutationMode`), never a fire-and-forget `mutate()`.
- Map a 422's field errors onto fields with `setError`, plus a form-level message for non-field errors; never collapse them into a toast.
- `Controller` for MUI inputs that don't expose the native input's ref (`Select`, `Autocomplete`, `DatePicker`, `Checkbox`/`Switch` groups): the trigger is ref exposure, not controlled-ness. Plain `TextField` takes `{...register("field")}` directly.
- `useWatch` on the specific field; never `watch()` the whole form.
- Warn on navigate-away when `isDirty`; `reset()` after a successful submit.
- Money/quantity inputs: parse and validate as fixed precision, enforce min/max/step, reject negatives explicitly rather than relying on the input type.
- Dates: the backend stores UTC. Convert at the boundary with `dayjs` (plugins registered once at app setup) and an explicit timezone; naive local parsing produces off-by-one-day dates.

## 7. Testing

- Vitest + React Testing Library + `@testing-library/user-event`, with MSW mocking the API at the network layer. If none is configured, say so.
- Query by role/label/text (`getByRole("button", {name:/approve/i})`); never assert on state internals or snapshot whole trees.
- Cover per feature: happy path; empty, loading and error states; validation failures; permission-denied (RBAC) rendering; money/rounding edges. Test custom hooks directly with `renderHook`.
- Deterministic (fake timers, fixed clock, no network, no `sleep`; factories over giant literal fixtures); every bug fix ships a regression test that fails before the fix.
- Adding coverage to an untested codebase: money/credit logic → form validation → status transitions → table filtering. Never chase a coverage % on presentational markup.

## 8. Performance

- Start independent requests together (`Promise.all`); never `await` inside a loop over rows.
- `React.lazy` per route (`pages/<feature>`) and for heavy or rarely used UI: DataGrid screens, date pickers, charts, export/print views, large dialogs, admin-only modules. `import()` paths are static literals, never template strings.
- On React 18, `<Suspense>` suspends only for `React.lazy` chunks and a data layer opted into suspense (TanStack Query v5 `useSuspenseQuery` under Refine 5; `suspense: true` on v4 under Refine 4), never a bare promise; otherwise each panel owns its own loading state. Give each independently loading region (lazy dialog, tab, chart panel) its own `<Suspense>`, or it falls back to the route boundary and blanks the page.
- Import concrete MUI modules (`@mui/material/Button`, `@mui/icons-material/Delete`), not the barrel. This is a lint and dev-server-speed win (worst with `@mui/icons-material`), not shipped bytes: Vite tree-shakes barrels in production, so never call it a bundle win without a `vite build` measurement. Type-only barrels (`interfaces/`) are exempt.
- Refine generates query keys from hook props (`resource`, `filters`, `sorters`, `pagination`, `id`): pass parameters as props, never close over them in a fetch. A hand-written key (`useCustom`, raw `useQuery`) includes every result-affecting parameter (filters, pagination, customer id).
- Paginate and filter large tables server-side; after a mutation, invalidate only the affected resource/id.
- Against a cursor API (`page_token`/`next`), the URL holds `page_size` and the current `page_token` (passed to the data provider via `meta`), never a page number the API cannot resolve; an expired-token `400` resets to the first page.
- `memo`/`useMemo`/`useCallback` only for measured-expensive work or an identity another rule needs (context value, grid renderer, effect dependency); never memo a primitive expression.
- React Compiler supports React 18 (`target: "18"` plus `react-compiler-runtime`); when enabling it, keep existing memoization.

## 9. Hooks Correctness

- Never silence `react-hooks/exhaustive-deps` by dropping a dependency; fix the design (hoist, ref, functional update, stable callback).
- Hoist non-primitive fallbacks that feed a dependency array or a `memo` child to module scope (`const EMPTY: readonly Ticket[] = []`; `data?.data ?? EMPTY`), never an inline `[]`/`{}` default.
- Clean up every listener, timer and subscription, and abort or ignore stale in-flight responses so a slow earlier one can't overwrite newer state. React 18.0 removed the setState-on-unmounted-component warning, so a missing cleanup fails silently.
- Stable callbacks without stale closures (React 18's substitute for `useEffectEvent`): keep the latest handler in a ref, assigned in an effect rather than during render, and call `ref.current`, so a subscribing effect doesn't list the handler as a dependency.
- App-wide init runs once per page load: top level of the entry module or behind a module-level `didInit` guard, never an unguarded `useEffect([])`.

## 10. Security

- No `dangerouslySetInnerHTML` with server or user content; if unavoidable, sanitize with DOMPurify and justify in a comment.
- Client-side validation and RBAC checks are UX only, never enforcement; the backend authorizes every action.
- Every `VITE_` variable in `import.meta.env` ships to the browser: public config only, never API keys or signing secrets.
- Tokens: prefer httpOnly cookies; with `localStorage`, accept the XSS exposure, keep TTLs short, clear on logout. Never put a token in a URL or query param.
- Allow-list any URL used in `href`/`src`/redirects (block `javascript:` and open redirects); `rel="noopener noreferrer"` on `target="_blank"`.

## 11. Accessibility (WCAG 2.2 AA)

- Interactive elements are semantic (`button`, `a`, MUI `Button`/`IconButton`/`CardActionArea`), never an `onClick` on a `div`/`Box`/`Card`/`TableRow`; everything is keyboard operable.
- Every input has a programmatically associated label. Errors identify the field and describe the problem in text; link the message with `aria-describedby` (or `aria-errormessage`; pick one and stay consistent) and set `aria-invalid`, but not on an untouched required field before a submit attempt.
- Icon-only buttons need an accessible name (`aria-label`).
- Never remove a focus outline without a replacement, and never let a focused row or field end up entirely hidden behind a sticky AppBar, a sticky DataGrid header or an open Snackbar.
- MUI `Dialog` moves focus in, traps it and restores it on close: set `disableAutoFocus`/`disableEnforceFocus`/`disableRestoreFocus` only with a documented reason, and keep it dismissible with Escape plus a visible Cancel/Close. It wires `aria-labelledby` only to a `DialogTitle` child without its own `id`: a custom title id, or a dialog titled any other way, needs explicit `aria-labelledby`, and descriptive body text needs `aria-describedby`.
- Contrast: text ≥ 4.5:1 (large text, ≥ 18pt or ≥ 14pt bold, ≥ 3:1); non-text parts ≥ 3:1 against adjacent colours (chip fills and borders, icon glyphs, input outlines, focus rings). Never convey status or an error by colour alone; add text or an icon.
- Announce async results with a toast / `role="status"` so a screen-reader user learns a save succeeded without focus moving.
- Avoid `autoFocus` without a deliberate UX reason.

## 12. Tooling Gates

Run from the app root:

```bash
npm run typecheck     # tsc --noEmit
npm run lint          # eslint src --max-warnings 0
npm run build         # tsc && vite build
# npm test            # once Vitest is set up
```

- Inherited debt (pre-existing `any`s, MUI barrel imports, lint warnings): measure it on an unmodified checkout, add none, reduce it in files you touch. `--max-warnings 0` fails the whole command on a non-zero baseline, and a gate already red before your change is no signal: gate on your files (`npm run lint <paths>`, `tsc --noEmit` output filtered to them).
- Never add `eslint-disable` without a reason comment; never disable a rule repo-wide to go green.

## 13. Agent Rules

- Never invent business rules (credit limits, tax, rounding, status transitions, SLAs); ask.
- Flag security-relevant changes (auth, RBAC display, tokens, `dangerouslySetInnerHTML`, URL handling) in your summary.
