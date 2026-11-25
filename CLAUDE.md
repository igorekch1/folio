# Folio

@AGENTS.md

Personal crypto portfolio tracker: wallets by address, exchanges by read-only keys,
Hyperliquid and manual entries in one dashboard.
Full product context, principles, design tokens and roadmap live in
[`openspec/config.yaml`](openspec/config.yaml); requirements in [`openspec/specs/`](openspec/specs/).
Do not duplicate them here.

## Language

- Code, comments, commits and OpenSpec artifacts in English.

## Stack

Next.js (App Router) · TypeScript strict · pnpm · Postgres (Neon) · Drizzle ORM + drizzle-kit ·
drizzle-zod · Better Auth (Google) · oRPC + TanStack Query · TanStack Form + Zod ·
TanStack Table · shadcn/ui + Charts (Recharts) · NumberFlow · date-fns (Europe/Kyiv) ·
Vitest · Biome · Vercel (+ Vercel Cron).

## Commands

Keep this list in sync with `package.json` (created by the phase 1 change; until then only
the `openspec` CLI applies).

```bash
pnpm dev          # local dev server
pnpm build        # production build
pnpm vercel-build # Vercel only: apply migrations, then build
pnpm test         # Vitest (test:watch for watch mode)
pnpm lint         # Biome check (lint + format + imports)
pnpm format       # Biome check --write
pnpm typecheck    # next typegen + tsc --noEmit
pnpm db:generate  # drizzle-kit: generate SQL migration from schema
pnpm db:migrate   # apply migrations to DATABASE_URL
pnpm db:studio    # Drizzle Studio
```

Local setup: copy `.env.example` to `.env.local` and set `DATABASE_URL` (Neon dev branch).
The server refuses to start without valid env.

## Layout

- `src/app/` — Next.js routes and UI only; pages under `src/app/[lang]/`.
- `src/i18n/` — languages, dictionaries, language routing (`src/proxy.ts`).
- `src/server/` — oRPC routers, domain logic, DB access, source adapters, price providers,
  cron handlers. UI never imports provider clients or secrets; the API must stay exportable
  to OpenAPI.
- `src/server/sources/<type>/` — one adapter per source type (EVM, Solana, Hyperliquid,
  WhiteBIT, Binance, Bybit, manual), all implementing the same interface. Domain code and UI
  depend on the interface, never on a provider.
- `src/lib/` — client-safe helpers: money and decimal math, calendar, oRPC client.
- `src/components/ui/` — shadcn components.
- `src/api/<domain>/` — client hooks for the API, one `useQuery` / `useMutation` per file
  (`use-refresh-source.ts`), owning their cache invalidation. Components and pages never
  call `orpc`, `authClient` or TanStack Query directly (enforced by Biome).
- Shared Zod schemas validate both forms and oRPC input.

## Non-negotiables

- Money is never a JS float. Token amounts and prices are exact decimals (Postgres
  `numeric`, decimal strings over the API); USD values are integer cents. Follow the money
  spec for rounding and conversion.
- Read-only product: no code path trades, withdraws, signs or connects a wallet.
- API keys are encrypted (AES-256-GCM, `ENCRYPTION_KEY`), server-only, shown masked. Only
  read-only keys: when the exchange can report key permissions, refuse keys that can trade
  or withdraw.
- Syncs are idempotent (unique per source + `external_id`) and respect provider rate limits.
  A provider failure changes no stored data.
- Every row that holds portfolio data belongs to a user, and every query is scoped to the
  caller. Never assume a single user.
- PnL is never faked: no cost basis means "n/a".
- Perps stay separate from spot: a perp account counts as its equity in Total value; perp
  notional never enters spot allocation or spot PnL. Hyperliquid equity comes from the
  `portfolio` info request, never from spot USDC + uPnL.
- Public repo: no secrets, wallet addresses, balances or personal data in code, tests,
  fixtures, docs or commits; `.env*` ignored, `.env.example` committed. Fixtures use
  obviously fake addresses and amounts.
- All money and perp math has Vitest tests.
- Light and dark themes (user choice, default System); colors only via the CSS variables in
  `globals.css`, each defined for both themes with WCAG AA contrast (normal text 4.5:1, large
  text and marks 3:1). The token set comes before screens.
- No hardcoded user-facing strings in components or pages. All UI copy (titles, labels,
  buttons, placeholders, empty states, toasts, aria-labels, validation messages) lives in
  `src/constants/copy/` (one file per area, re-exported from `index.ts`) as
  `defineCopy(uk, en)` dictionaries, so all copy can be changed in one place.
- The UI is localized: Ukrainian (`uk`, default) and English (`en`). Every string exists in both
  (a missing translation fails `tsc`). Pages live under `src/app/[lang]/` (`/uk/...`, `/en/...`);
  server components use `getDictionary(lang)`, client components `useDictionary()` /
  `useLang()`; in-app links go through `localizedHref`. Dates and money take `lang`.
- No Russian anywhere in the repository: code, copy, tests, specs, docs and file names.
- API errors are codes, never text: the server sends a stable `code` (`UPPER_SNAKE_CASE`) and
  HTTP status; `message` is English for developers only. The client turns codes into copy via
  `src/lib/errors.ts` (`errorMessage`, `validationMessage`) and `src/constants/copy/errors.ts`.
  Shared Zod schemas carry no user-facing messages.
- Log through `getLogger(scope)` from `src/server/log.ts`; no `console.*` in `src/` (Biome
  `noConsole`). Never log keys, wallet addresses, balances or personal data; pass values as
  fields, not inside the message.
- Responsive: phone (< 768px), tablet (768–1023px) and desktop (≥ 1024px) are all supported;
  mobile-first, check every screen at 375 / 768 / 1280px, each in both the light and the dark
  theme.
- Loading states use skeletons shaped like the content, not spinners (spinners only inside
  a button or menu item for a short action).
- CI (`.github/workflows/ci.yml`, added by the phase 1 change) runs lint, typecheck, tests and
  build on every PR; `main` only accepts PRs with a green `checks` job.

## Workflow (OpenSpec)

One change at a time: `openspec-propose` → owner approves → `openspec-apply-change` →
tests + Biome + typecheck → owner reviews uncommitted changes and approves → commit, push,
open PR → owner merges → the `OpenSpec archive` GitHub workflow archives the change and
opens an archive PR automatically (fallback: `openspec-archive-change`).

- Each change gets its own branch named after the change, always cut from a fresh `main`:
  `git switch main && git pull --ff-only && git switch -c <change-name>`. Never branch off
  a previous change's branch (it has been squash-merged, so its commits would reappear).
- Never commit, push or open a PR without the owner's explicit approval. Apply leaves changes
  uncommitted; after approval, split them into small, meaningful commits, push and open the PR.
  Follow the `git-workflow` skill. The one exception was the initial scaffold commit, pushed
  straight to `main` with the owner's approval.
- No new dependencies outside the stack without explaining why.
- If a spec turns out wrong mid-implementation, stop and propose a spec amendment.
- Useful: `openspec list`, `openspec status --change <name>`, `openspec validate <name>`.
