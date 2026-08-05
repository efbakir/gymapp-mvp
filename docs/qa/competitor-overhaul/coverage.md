# Competitor overhaul coverage

Reviewed 2026-08-04. The source library remained read-only throughout.

## Inventory

- Files discovered: **930**
- Benchmark content files: **926**
  - Screenshots: **924**
  - Alpha Progression video: **1**
  - Lifting-app index: **1**
- Filesystem metadata excluded from product review: **4 `.DS_Store` files**
- Screenshot decode check: **924 discovered / 924 decoded / 0 failures**
- Screenshots inspected: **924 / 924**
- Screenshots skipped: **0**
- Unreadable or corrupt files: **0**

The content inventory matches the expected 924 screenshots, one video, and one
index. The only difference between that content count and the full filesystem
count is four macOS metadata files.

## Alpha Progression screenshots

| Flow | Count | Inspected |
|---|---:|---:|
| 01 Launch | 3 | 3 |
| 02 Onboarding | 30 | 30 |
| 03 FAQ | 140 | 140 |
| 04 Support email | 10 | 10 |
| 05 Paywall | 54 | 54 |
| 06 App Store purchase | 25 | 25 |
| 07 Home | 42 | 42 |
| 08 Charts | 19 | 19 |
| 09 Profile | 32 | 32 |
| 10 Calendar | 20 | 20 |
| 11 Plan creation | 55 | 55 |
| 12 Exercise picker | 36 | 36 |
| 13 Plan generator | 117 | 117 |
| 14 Gym equipment | 73 | 73 |
| 15 iOS settings | 25 | 25 |
| 16 Active workout | 177 | 177 |
| 17 Workout summary | 30 | 30 |
| **Total** | **888** | **888** |

## Other lifting-app screenshots

Every PNG was opened individually at full resolution in addition to the contact
sheet pass.

| App | Count | Inspected |
|---|---:|---:|
| Bevel | 6 | 6 |
| Cal AI | 1 | 1 |
| Centr | 2 | 2 |
| Equinox+ | 1 | 1 |
| Google Fit | 1 | 1 |
| Gymshark | 6 | 6 |
| Hevy | 7 | 7 |
| Ladder | 5 | 5 |
| Nike Run Club | 1 | 1 |
| Peloton Strength+ | 4 | 4 |
| Strava | 1 | 1 |
| Whoop | 1 | 1 |
| **Total** | **36** | **36** |

`liftingapps/screenshots/INDEX.md` was read in full and cross-checked against
the 36 PNGs.

## Review method

1. Generated a fresh, sorted manifest at
   `/tmp/unit-competitor-overhaul-20260804/manifest.txt`.
2. Generated **60** filename-labelled contact sheets outside the repository:
   51 screenshot sheets and 9 video sheets.
3. Read every contact sheet in filename order, treating near-duplicates as
   interaction sequences rather than redundant images.
4. Opened full-resolution sources whenever copy, controls, validation, or a
   state transition was not legible in the sheet.
5. Opened all 36 cross-app references individually at full resolution.
6. Decoded every source screenshot with ImageIO; all 924 succeeded.
7. Extracted **178 ordered frames** from the 14:48 Alpha Progression video at
   five-second intervals, reviewed all nine video contact sheets, and compared
   the sequence with the screenshot flows.

Derived artifacts remain in `/tmp/unit-competitor-overhaul-20260804`; nothing
inside `/Users/efbakir/Desktop/Projects/unit/benchmark` was changed.

## Unit regression evidence

- Baseline failure:
  `docs/qa/competitor-overhaul/screenshots/baseline-first-session-missing-target.png`
- Correct first-session target:
  `docs/qa/competitor-overhaul/screenshots/first-session-starting-target.png`
- One-tap completion with timer running and Set 2 prefilled:
  `docs/qa/competitor-overhaul/screenshots/first-session-set-completed.png`
- Increase-weight recommendation:
  `docs/qa/competitor-overhaul/screenshots/progression-increase-weight.png`
- Add-one-rep recommendation:
  `docs/qa/competitor-overhaul/screenshots/progression-add-rep.png`
- Repeat-target recommendation:
  `docs/qa/competitor-overhaul/screenshots/progression-repeat-target.png`
- Accepted targets after a cold relaunch:
  `docs/qa/competitor-overhaul/screenshots/accepted-targets-today.png`
- Progressive-overload configuration:
  `docs/qa/competitor-overhaul/screenshots/progression-configuration.png`
- Accepted target prefilled in the next workout:
  `docs/qa/competitor-overhaul/screenshots/accepted-target-next-workout.png`
- History evidence with an exact date and explicit volume units:
  `docs/qa/competitor-overhaul/screenshots/progression-history-evidence.png`
