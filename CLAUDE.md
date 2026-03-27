# Unit — Claude Code context

This file provides persistent context for Claude Code sessions in this repository.

## Audit Mode

When running an audit task, Claude should:

1. Read `docs/product-compass.md` first — it is the source of truth
2. Read `AGENTS.md` for UX rules and scope fences (if missing, read `docs/AGENTS.md`)
3. Read `DESIGN_SYSTEM.md` for design system rules (it points to `docs/atomic-design-system.md` and `docs/visual-language.md`)
4. Read `docs/goals.md` for measurable targets and v1 scope boundaries
5. Scan every SwiftUI view file in the project
6. Build and run the app in the iOS Simulator
7. Take screenshots of every reachable screen
8. Compare each screenshot against the compass, design system, and goals
9. Write findings to `audit-report.md` in the repo root (and/or a timestamped report if invoked via script)

