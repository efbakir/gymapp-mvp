# autoresearch-audits

An adaptation of [karpathy/autoresearch](https://github.com/karpathy/autoresearch) to the Unit iOS app — but instead of an agent iterating on `train.py` to lower `val_bpb`, three agents iterate on their own audit prompts to catch more real issues per run.

## Why this exists

The existing `audit-prompt.md` at the repo root is one fat monolithic audit (compass + design system + edge cases + App Store readiness). Running this nightly via `run-audit-auto.sh` keeps producing reports, but:

- The context per run is too wide, so each run catches ~the same surface-level stuff and misses the same deep stuff.
- There's no dedup across runs — the same bug gets re-reported forever.
- There's no verdict signal — nothing distinguishes "real bug Claude found" from "false positive Claude hallucinated."
- The prompt doesn't iterate. The human edits it by hand, rarely.

autoresearch's insight: **the agent iterates the implementation file; the human iterates the skill file; a scalar metric scores every iteration.** Apply that here.

## Mapping

| autoresearch             | autoresearch-audits                                                       |
| ------------------------ | ------------------------------------------------------------------------- |
| `prepare.py` (harness)   | `../run-audit.sh` + `xcodebuild` + `xcrun simctl` (unchanged)             |
| `train.py` (iterated)    | `<skill>/skill.md` — the audit prompt the agent edits each loop           |
| `program.md` (loop spec) | `./program.md` — shared loop + scoring rule (human-iterated, rare edits)  |
| `val_bpb` (metric)       | `novel_real / total_findings` per run — precision × novel-find count      |
| `results.tsv` (output)   | `<skill>/findings.tsv` — append-only ledger with verdict column           |

## The three skills

Each is a narrow-scope audit with its own context budget:

| Skill                 | Catches                                                                 | Source rules                                          |
| --------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------- |
| `bug-hunter`          | Runtime crashes, broken state, logic errors, force-unwraps, data bugs   | `CLAUDE.md §7`, Swift 6 concurrency, SwiftData models |
| `visual-consistency`  | Design-system drift (banned tokens, parallel impls, light-mode, etc.)   | `CLAUDE.md §5`, `docs/atomic-design-system.md`        |
| `missing-flows`       | Dead ends, empty states, broken back-stack, edge-case data              | `audit-prompt.md` Step 1 "Edge cases"                 |

Splitting the fat prompt into three narrow ones is the whole point — each run has a tighter lens and produces higher-signal findings.

## The loop (per skill)

See `program.md` for the full spec. Short version:

1. Agent reads `skill.md` (current audit prompt for this skill).
2. Agent runs the audit (static scan + simulator screenshots where relevant).
3. Agent writes new findings to `<skill>/findings.tsv` — each with an auto-generated `id`, no verdict yet.
4. Agent dedups against prior findings (same `id` hash → skip).
5. **You**, in the morning, mark each new row's `verdict` column: `real`, `false_positive`, `duplicate`, or `wontfix`. Fill `fix_commit` if you patch it.
6. Next run, the agent reads the ledger before starting, identifies which of its prior findings were marked `false_positive`, and **edits its own `skill.md`** to stop making that class of mistake. Commits the skill.md change. Runs again.
7. Metric: `novel_real_this_run / total_findings_this_run`. If the tweak drove precision up and novel-find count stayed above 1, keep the skill.md change. If precision dropped or the skill went silent, `git reset` the skill.md.

The skill.md evolves overnight. You wake up to a sharper auditor than you went to bed with.

## How to run (tonight)

**Manual, one skill:**
```bash
claude -p --dangerously-skip-permissions \
  "$(cat autoresearch-audits/program.md autoresearch-audits/bug-hunter/skill.md)"
```

**All three in sequence via existing launchd:** edit `run-audit-auto.sh` to swap the monolithic `audit-prompt.md` for the three narrow skills, running them one after the other. Do this once you've watched the narrow skills run cleanly by hand — don't flip the cron before validating.

## What this does NOT change

- `audit-prompt.md` is left in place. `run-audit-auto.sh`, `run-audit.sh`, and `com.unit.audit.plist` are untouched. The existing overnight audit keeps running.
- `audit-screenshots/` is shared — each skill reuses simulator screenshots taken during its run.
- No new dependencies. Everything is `.md` + `.tsv` + the existing shell harness.

## Conventions

- **`findings.tsv` is tab-separated**, not CSV. Commas appear in descriptions; tabs do not. Same rule as autoresearch's `results.tsv`.
- **`id` is `sha1(skill + file + line + rule)[:7]`** — deterministic across runs so dedup works without fuzzy match.
- **Never commit `findings.tsv`** during a run. The human is the source of truth for verdicts; the file accumulates across sessions and should be committed by hand after morning triage.
- **`skill.md` evolution is committed** on its own branch (`autoresearch-audits/<skill>/<date>`) — same pattern as autoresearch's `autoresearch/<tag>` branches.
