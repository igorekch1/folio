---
name: git-workflow
description: Commit, push and open a PR for Folio work after the owner has approved it. Use when the owner approves an implemented change (in any language, e.g. "approved", "ok", "commit", "open the PR") or asks to commit/push/open a PR. Also defines what to do before approval (leave changes uncommitted, present them for review).
---

# Folio git workflow

Nothing is committed, pushed or opened as a PR until the owner explicitly approves the
work. `.claude/settings.json` also forces a confirmation prompt for `git commit`,
`git push` and `gh pr create`.

## Before approval (end of implementation / OpenSpec apply)

1. Work on the change branch (named after the OpenSpec change, e.g. `add-evm-source`),
   created from an up-to-date `main` before any work starts:
   `git switch main && git pull --ff-only && git switch -c <change-name>`.
   Never work on `main` directly and never branch off a previous change's branch
   (it was squash-merged, so its old commits would show up again in the new PR).
2. Run `pnpm test`, `pnpm lint`, `pnpm typecheck`, `pnpm build`. Report results honestly.
3. Leave everything **uncommitted**. Present for review:
   - `git status --short` and `git diff --stat`;
   - what changed and why, grouped the way you plan to commit it;
   - anything not verified and any owner actions needed.
4. Stop and wait for approval.

## After approval

Approval must be explicit and refer to this work. If the owner asked for changes, make
them and go back to "Before approval".

1. **Re-check** `git status`: no `.env*` (except `.env.example`), no credentials, no real
   wallet addresses or balances, no stray files (screenshots, scratch). Re-run checks if
   anything changed since the review.
2. **Local review before every commit.** Run the `code-review` skill on the changes about
   to be committed and show the owner a table of findings:

   | # | Severity (high / medium / low) | Problem (short) | How to fix |
   |---|---|---|---|

   - No findings → commit.
   - Any finding, even a single `low` → do not commit; wait for the owner to decide what
     to fix or to approve committing as is. After fixes, review again.
3. **Commit in small logical units**, in dependency order (e.g. scaffold → domain logic →
   UI → server → docs). Each commit builds and passes tests on its own where practical.
   Follow the commit convention below. OpenSpec artifacts (`openspec/changes/<name>/`,
   checked tasks) go in their own `docs(openspec): …` commit or with the code they describe.
4. **Push** the branch: `git push -u origin <branch>`.
5. **Open the PR** against `main` with `gh pr create --base main --title "<title>" --body-file <file>`:
   - **Title** becomes the single squash commit on `main`, so it MUST follow the commit
     convention (e.g. `feat(sources): add EVM wallet source`).
   - **Body**: fill every section of `.github/pull_request_template.md` (Summary, OpenSpec,
     Testing with real results, Owner steps, Checklist — tick only what is true). Remove
     the HTML comments.
   - Never put secrets, API keys, wallet addresses, balances or personal data in the PR.
6. Report the PR URL. Do not merge — the owner merges with **Squash and merge**.
7. After the owner merges, archiving is automatic: the `OpenSpec archive` GitHub workflow
   (`.github/workflows/openspec-archive.yml`) runs `openspec archive <branch> --yes` on
   `main`, pushes `archive-<change>` and opens a `docs(openspec): archive <change>` PR with
   CI started. Do not archive locally. Locally just `git switch main && git pull`.
   Use `openspec-archive-change` by hand only if the workflow failed or the branch name
   did not match the change name.

## Commit convention

[Conventional Commits](https://www.conventionalcommits.org/), English, imperative mood,
no trailing period, summary ≤ 72 characters:

```
type(scope): summary

Optional body: why, not what.
```

- **Types:** `feat` (user-visible behavior), `fix`, `refactor`, `perf`, `test`, `docs`,
  `chore` (tooling, config, deps), `build`, `ci`.
- **Scopes** (pick the closest; omit only for repo-wide changes):
  `money`, `calendar`, `shell`, `ui`, `server`, `db`, `auth`, `sources`, `assets`, `prices`,
  `positions`, `trades`, `snapshots`, `dashboard`, `analytics`, `perps`, `mcp`, `i18n`,
  `openspec`, `deps`.
  Add a new scope when a new area appears; keep this list updated.
- Breaking changes: `type(scope)!: summary` plus a `BREAKING CHANGE:` footer.
- Branch commits stay small for review; `main` receives one squash commit per PR whose
  message is the PR title.
