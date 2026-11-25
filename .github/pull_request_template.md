<!-- PR title = squash commit on main: Conventional Commits, e.g. "feat(sources): add EVM wallet source" -->

## Summary

-

## OpenSpec

Change: `openspec/changes/<name>/` <!-- or "None" for non-spec work -->
Tasks: <done>/<total>

## Testing

- [ ] `pnpm test`
- [ ] `pnpm lint`
- [ ] `pnpm typecheck`
- [ ] `pnpm build`
- Manual:

## Owner steps

- None

## Checklist

- [ ] Money and perp math is covered by tests (exact decimals, USD in cents, no floats)
- [ ] No secrets, API keys, wallet addresses, balances, `.env*` files or personal data
- [ ] DB migrations included and reviewed (or none)
- [ ] UI checked at 375 / 768 / 1280px in both the light and the dark theme (or no UI changes)
- [ ] Deviations from specs/design are recorded in the OpenSpec artifacts
