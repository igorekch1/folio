# Folio

Personal crypto portfolio tracker.

Folio puts everything you hold in one dashboard: on-chain wallets (EVM and Solana, by
address), exchange accounts (read-only API keys), Hyperliquid and manual entries. The same
asset across sources merges into one position, with total value, allocation, PnL against an
average cost basis and trade history. It is read-only by design: Folio never moves funds,
never signs anything and never connects a wallet.

> **Status:** project setup. The repository holds the product context, conventions and
> workflow; application code starts with phase 1 of the roadmap in
> [`openspec/config.yaml`](openspec/config.yaml).

## Features (planned)

- Google sign-in; every source, trade and token belongs to a user.
- Sources: EVM wallets across chains with DeFi positions, Solana wallets, Hyperliquid by
  address, WhiteBIT, Binance and Bybit through read-only keys, and manual holdings and trades.
  All behind one adapter interface, so data providers can be swapped.
- Dashboard: total value, all-time PnL, changes for 24h / 7d / 30d / 1y, value chart from
  daily snapshots, allocation by asset and by category, filter by source.
- Positions table with sorting, search, dust filter and a per-source breakdown; optional
  grouping of derivatives (stETH, wstETH, weETH into ETH; LSTs into SOL).
- Trade history with filters, manual entry and CSV export.
- Analytics, perpetuals (open positions, history rebuilt from fills, stats) and a read-only
  MCP server to ask Claude about the portfolio.
- Phone, tablet and desktop layouts; dark, light and system themes; Ukrainian and English.

### Roadmap

1. Scaffold, auth, design tokens, data model, manual source, prices, positions table and
   summary cards.
2. EVM and Solana by address, Hyperliquid (equity and spot), WhiteBIT, daily snapshots,
   value chart, allocation charts, trade history.
3. Binance, Bybit, category overrides, analytics.
4. MCP server for Claude.
5. Perpetuals.

## Tech stack

Next.js (App Router) · TypeScript (strict) · pnpm · Postgres on Neon · Drizzle ORM ·
Better Auth · oRPC + TanStack Query · TanStack Table · TanStack Form + Zod · shadcn/ui +
Charts · date-fns (`Europe/Kyiv`) · Vitest · Biome · Vercel (+ Vercel Cron).

## Getting started

Application code lands with phase 1; these steps describe the setup it will use.

### Prerequisites

- **Node.js 24+**.
- **pnpm**: the exact version is pinned in `package.json` (`packageManager`). Enable it
  with `corepack enable`.
- **A Neon Postgres database.** The app talks to Postgres through Neon's serverless HTTP
  driver, so a plain local Postgres will not work. A free Neon project is enough; use a
  separate dev branch for local work.

### Setup

```bash
git clone https://github.com/igorekch1/folio.git
cd folio
pnpm install
cp .env.example .env.local   # then fill in the values
pnpm db:migrate              # apply migrations to DATABASE_URL
pnpm dev                     # http://localhost:3002
```

### Environment variables

All variables are listed in [`.env.example`](.env.example) and validated with Zod at server
start. The server refuses to start if any are missing or invalid; the error names the
variables, never their values.

| Variable               | Description                                                               |
| ---------------------- | ------------------------------------------------------------------------- |
| `DATABASE_URL`         | Neon Postgres connection string (use a dev branch locally).               |
| `BETTER_AUTH_SECRET`   | Session signing secret, ≥ 32 chars (`openssl rand -base64 32`).           |
| `BETTER_AUTH_URL`      | Canonical URL: `http://localhost:3002` locally, production URL on Vercel. |
| `GOOGLE_CLIENT_ID`     | Google OAuth client ID.                                                   |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret.                                               |
| `ALLOWED_EMAILS`       | Comma-separated emails allowed to sign in.                                |
| `ENCRYPTION_KEY`       | Encrypts exchange API keys: base64 of 32 bytes (`openssl rand -base64 32`). |
| `COINGECKO_API_KEY`    | CoinGecko API key for prices, logos and categories.                       |

Wallet addresses and exchange API keys are never environment variables: they are added in
the app and stored per user.

`ENCRYPTION_KEY` must be the same in every environment that shares a database, and should be
backed up in a password manager. If it is lost or changed, stored API keys can no longer be
read and have to be entered again.

## Conventions

- **Money** is never a float: token amounts and prices are exact decimals, USD values are
  integer cents. All money math is covered by tests.
- **Read-only**: only read-only exchange keys are accepted; keys that can trade or withdraw
  are refused where the exchange reports permissions.
- **Syncs** are idempotent and respect provider rate limits.
- **PnL** uses average cost from trades; without a known cost basis it shows "n/a".
- **Perpetuals** stay separate from spot: a perp account counts as its equity, never as
  position notional.
- **Dates** use the `Europe/Kyiv` time zone.
- **Languages**: Ukrainian (default) and English, under `/uk/...` and `/en/...`. All UI copy
  lives in dictionaries, never hardcoded in components.
- **Layouts**: phone (< 768px), tablet (768–1023px), desktop (≥ 1024px), mobile-first.
- **Loading states** use skeletons, not spinners.
- **Errors** leave the API as codes; the client maps them to copy.
- **Logging** is structured and never contains keys, addresses or balances.
- **Colors** only via the CSS variables in `globals.css`, defined for both themes with WCAG
  AA contrast.

## Workflow

Changes are planned with [OpenSpec](https://github.com/Fission-AI/OpenSpec): each change
gets a proposal, design, spec deltas and tasks under `openspec/changes/<name>/` and is
implemented on a branch named after the change. When its PR is merged, the change is
archived and its specs are synced into `openspec/specs/`.

- Commits follow [Conventional Commits](https://www.conventionalcommits.org/).
- PRs are squash-merged into `main`; the PR title becomes the commit message.
- CI runs lint, typecheck, tests and build on every PR (set up in phase 1).
- Hosting is Vercel: `main` deploys to production and each branch gets a preview deployment.

## Security

This repository is public. Secrets, wallet addresses and personal data never go into code,
tests, docs or commits: `.env*` files are gitignored and only `.env.example` is committed.
Exchange API keys are encrypted at rest (AES-256-GCM), used only on the server and shown
only masked.
