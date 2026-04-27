---
purpose: Visual reference library — taste anchors for Unit's UI work
audience: Claude (during any UI task) + the user (when building screens)
---

# Visual references

This folder is the **taste anchor** for Unit. Rules and tokens live in `CLAUDE.md` and `Unit/UI/DesignSystem.swift`. Aesthetic intent lives here.

Claude tends to drift toward generic-looking UI when given only rules ("use AppSpacing.md", "no hex literals"). Rules don't encode taste. References do.

## How Claude must use this folder

Before any non-trivial UI edit (a new screen, a layout change, a card design, a list pattern, an empty state):

1. List `docs/references/ios-screens/` and `docs/references/details/`.
2. Open the references most relevant to the screen being built.
3. State out loud (one sentence) which references the change is anchored to and what specifically is being borrowed (rhythm, hierarchy, weight, density — not pixels).
4. Then proceed.

If no reference fits the task — say so before editing, do not invent visual decisions. Either ask the user for a reference, or pick one already in the folder and justify why it's the closest match.

This is part of the §5 gatekeeper checklist in `CLAUDE.md`.

## Folder convention

```
docs/references/
├── README.md              ← this file
├── ios-screens/           ← full-screen iOS app screenshots (whole-screen reference)
│   └── <app>__<screen>.png
├── details/               ← cropped details (a specific list row, button, header, empty state)
│   └── <app>__<element>.png
└── notes/                 ← optional: short text notes on what to borrow from a given reference
    └── <reference-filename>.md
```

**File naming**: `app-name__what-it-is.png`. Lowercase, hyphens within names, double-underscore between segments. Example: `apple-sports__live-game.png`, `streaks__empty-state.png`, `things-3__list-row.png`.

## Suggested reference targets (anchors of Unit's taste)

These are the apps Unit's design language is closest to. Capture screens from these first.

| App | Why it's a reference | What to capture |
|---|---|---|
| **Apple Sports** | Editorial typography, generous whitespace, native chrome | Live game screen, stats screen, list view |
| **Streaks** | Tile/card density, restraint with color, friendly minimalism | Today screen, history, detail |
| **Things 3** | List rhythm, soft separators, Areas/Projects hierarchy | Today, project view, quick entry |
| **Apple Notes** | iOS-native list rhythm + sheets | Note list, single note, share sheet |
| **Strava (logging path only)** | Activity record screen — relevant to active workout layout | Record screen, save flow |
| **Whoop** | Data-dense screens that still feel calm | Strain/recovery summary, history list |
| **Hevy** | Closest direct competitor — log a study of what we DO NOT want as well as what we do | Active workout, exercise picker |
| **Apple Fitness** | Native HIG-compliant tracking UI | Summary rings, workout detail |

Capture in **light mode**, **portrait** only (Unit is light + portrait only — see CLAUDE.md §5).

## Detail captures worth having

Cropped to one element. Faster to scan than full screens.

- Empty states (hero copy + illustration treatment)
- List rows (height, dividers, secondary text rhythm)
- Section headers (weight, casing, spacing)
- Sheets (presentation detents, drag handle, content padding)
- Toolbars (button weight, item spacing, native vs custom)
- Buttons (primary, ghost, destructive — radii and weights)
- Number-heavy displays (tabular numerals, alignment)

## Notes folder (optional)

If a reference is non-obvious — borrowing only one specific thing — write a short note alongside it.

Example `notes/streaks__today-screen.md`:

> Borrowing: the section-header rhythm and the tile padding. NOT the color tinting or the icon style. Unit's tiles should be black-on-cream with no per-streak tint.

## What NOT to put here

- Marketing screenshots from product pages (cropped/edited — not real UI)
- Dark mode screenshots (Unit is light only)
- Landscape screenshots (Unit is portrait only)
- Web app screenshots (different platform conventions)
- Anything from competitor apps you want to copy 1:1 — pick the spirit, not the layout

## Maintenance

Prune anything that no longer matches Unit's direction. Stale references mislead more than empty folders.
