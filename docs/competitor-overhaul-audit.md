# Competitor evidence → Unit decisions

Reviewed 2026-08-04 against all 924 benchmark screenshots, the lifting-app
index, and 178 ordered frames from the Alpha Progression video. Coverage proof
lives in `docs/qa/competitor-overhaul/coverage.md`.

## The interaction-cost finding

Alpha Progression is understandable because it exposes state, defaults, and
feedback clearly. It is slower because the user must also manage a generated
plan, equipment, RIR, periodization, recovery assumptions, extensive analytics,
exercise education, and subscription interruptions. Unit should borrow the
clarity mechanisms, not the breadth or coaching model.

The product boundary remains:

> Keep your program. Unit gives you the smallest clear next step.

Unit's critical path is therefore:

```text
Choose or paste program
→ confirm starting targets
→ see today's workout
→ open the first exercise with values ready
→ complete a set in one tap
→ rest
→ finish
→ understand one next target and why
→ accept, repeat, or edit
→ reopen with that target ready
```

## Alpha Progression flow evidence

| Flow | Job and primary action | Decisions, input, defaults, prevention | Feedback, navigation, interaction cost | Unit decision |
|---|---|---|---|---|
| Launch | Establish product and begin setup. Primary action is start. | One obvious entry point; little risk. | Linear push; low cost. | **2.1 — borrow:** immediate purpose and one CTA. Reject decorative branding work. |
| Onboarding | Build a profile for generated recommendations. | Gender, experience, body data, health access, goals; selection cards and pickers; many required decisions. | Visible selection and forward motion, but high setup cost before value. | **2.1 — borrow:** selectable cards, retained choices, sensible defaults, review before save. **Never:** body profile, Health, coaching questionnaire. |
| FAQ | Explain the system and reduce uncertainty. | Users choose topics; long-form answers compensate for system complexity. | Search/list-to-detail; high reading cost outside the workout. | **2.1 — borrow:** plain one-sentence explanations beside unfamiliar settings. **Never:** a coaching encyclopedia. |
| Support | Move unresolved problems to email. | User chooses issue and composes externally. | Clear handoff but leaves the app. | **Later:** concise support route. Not part of logging/progression. |
| Paywall | Explain access and convert. | Tier, trial, renewal, restore; price is prefilled by StoreKit. | Selection feedback and explicit purchase state; repeated interruptions add cost. | **2.1 — borrow:** clear trial/renewal context, selected tier, restore/error/pending feedback. Reject repeated or ambiguous gating. |
| App Store purchase | Confirm Apple-managed payment. | System sheet prevents spoofed payment and supports cancellation. | Native modal confirmation; medium unavoidable cost. | **2.1 — borrow:** defer transaction UI to StoreKit; entitlement must exit the hard gate. |
| Home | Surface today's plan and progress. | User chooses start/resume and sometimes plan context. | Cards, status, and prominent start action; analytics compete for attention. | **2.1 — borrow:** today's routine, readable exercise preview, dominant Start. Reject feed/achievement density. |
| Charts | Prove progress through multiple metrics. | Metric and time-range selection. | Dense tabs and charts; strong evidence but high interpretation cost. | **2.1 — borrow:** weight/reps/volume with explicit dates and units. **Never:** muscle/readiness dashboards. |
| Profile | Manage identity, goals, achievements, and account settings. | Many settings and account choices. | Hierarchical list; broad but far from the gym task. | **Never:** accounts, social identity, achievements. Keep only local preferences and support/legal needs. |
| Calendar | Review adherence over time. | Select date/session. | Familiar calendar navigation, but workout evidence becomes secondary to schedule management. | **Later:** only if it helps find real sessions faster than History. Do not add now. |
| Plan creation | Assemble a custom program. | Schedule, exercises, sets, reps, progression-related choices. | Stepwise confirmation prevents loss, but manual construction is costly. | **2.1 — borrow:** program review, editable targets, explicit save. Unit keeps lightweight templates rather than cycles. |
| Exercise picker | Search and filter a large exercise catalogue. | Exercise, equipment, muscle, variant. | Search and selected-state feedback; discovery adds choice load. | **2.1 — borrow:** fast search and clear selected exercises. **Never:** discovery feed, video library, muscle browsing. |
| Plan generator | Generate and revise a plan. | Goals, frequency, duration, muscles, equipment, preferences. Defaults help but still require many decisions. | Wizard with progress and confirmation; very high setup/ownership cost. | **Never:** AI/generated plans or automatic rewriting. Paste/import preserves user control. |
| Gym equipment | Describe one or more gyms in detail. | Extensive equipment checklist and location-specific availability. | Good checklist feedback; very high maintenance cost. | **Never:** multiple gyms or equipment inventory. A per-exercise increment is enough. |
| iOS settings | Manage notifications, permissions, subscription, and system behavior. | Native toggles and OS permission state. | Familiar grouped settings; low learning cost. | **2.1 — borrow:** native controls and explicit state. Keep settings small. |
| Active workout | Guide exercise order and record sets. | Weight, reps, RIR, exercise navigation, timer, substitutions. Prior values are visible and set completion is one tap. | Strong current-exercise feedback and persistent timer; table columns and carousel add scan/decision cost. | **2.1 — borrow:** obvious current exercise, usable prefill, one-tap completion, editable result, visible timer, set progress. Reject RIR, dense per-set table, coaching in the hot loop. |
| Workout summary | Explain what happened and reinforce completion. | User reviews performance, achievements, muscles, and sharing. | Strong completion feedback but excessive evidence and promotion create long scrolling. | **2.1 — borrow:** restrained completed evidence and one next target with reason/actions. Reject stars, streak theatre, muscle maps, social prompt. |

## Cross-app patterns

The 36 individual references reinforced six patterns:

- **Hevy / Gymshark:** prior values and set rows make logging predictable, but
  wide tables, plate calculators, and warm-up tools are not required for Unit's
  three-second path.
- **Ladder / Peloton Strength+:** focused numeric sheets and keypad entry reduce
  edit ambiguity; Unit keeps this only as the secondary adjustment path.
- **Bevel / Whoop:** recovery and muscle context can be legible, but it changes
  the product into readiness coaching. Deliberately rejected.
- **Strava / Nike Run Club / Google Fit:** clear dates and native manual-entry
  patterns help evidence; activity-network breadth is irrelevant.
- **Centr / Equinox+:** content-led training and class structure improve guided
  workouts, but Unit preserves the user's routine rather than teaching one.
- **Cal AI:** fast capture is a useful principle; AI inference is not.

## Borrowed for Unit 2.1

- Explicit user activation and confirmation before a program/target changes.
- Program defaults that remain editable and survive save/relaunch.
- First-session starting values shown as targets, never fake history.
- One dominant current exercise and one primary `Complete set` action.
- A visible, controllable rest timer after completion.
- Clear prior evidence, complete next target, short reason, and explicit
  `Use`, `Repeat`, or `Edit` decisions after the workout.
- Dates, units, best set, and volume written directly enough to audit.
- Native StoreKit purchase/restore states with transparent trial renewal.

## Deliberately rejected

- RIR/RPE adaptation, deloads, cycles, recovery/readiness, and warm-up engines.
- Generated plans, automatic program rewriting, or exercise recommendations.
- Muscle maps, video/content libraries, social feeds, achievements, and sharing.
- Accounts, Apple Health, nutrition, multiple gyms, and equipment catalogues.
- Any progression decision or explanation that interrupts active logging.

## Component census

### Reused

- `AppScreen`, `AppSheetScreen`, and `OnboardingShell` for screen/sheet chrome.
- `AppCard`, `AppCardList`, `AppDividedList`, `SettingsSection`, and
  `PreviewListContainer` for grouped surfaces.
- `WorkoutCommandCard`, `SetProgressIndicator`, and `RestTimerControl` for the
  active-workout hot loop.
- `AppInlineWeightField`, `AppStepper`, `AppOptionTileCard`, and
  `AppSelectableTierCard` for existing input/selection patterns.
- `AppSessionHighlightRow` / `AppSessionHighlightCard` for History evidence.

### Extended

- `PreviewListRow` gained the `identityFirst` layout so long exercise names
  keep two lines and targets/evidence sit beneath them.
- `PreviewListContainer` gained two-line row sizing/scroll behavior for small
  phones and Dynamic Type.
- `AppSetRepEditorSheet` gained the shared progressive-overload toggle, rep
  bounds, increment field, validation, and save result.
- `AppInlineWeightField` gained caller-owned accessibility labels so weight and
  increment inputs are unambiguous.
- `AppSelectableTierCard` gained disabled/accessibility states for unavailable
  StoreKit products.
- `WorkoutCommandCard` reused its supporting slot for `Starting target` and
  accepted-target evidence; no parallel workout card was created.

### Added

- `AppFeatureAccessTable`: one shared, Dynamic-Type-safe paywall matrix was
  necessary to replace inline feature rows and keep purchase proof aligned.

### Removed or consolidated

- The paywall's feature/tier presentation no longer hand-rolls unrelated local
  card chrome.
- Today no longer forces exercise identity into a narrow one-line column.
- First-session planned weight is no longer hidden behind `Log first set`.
- Repeated target formatting is consolidated through `WorkoutTargetFormatter`.

### Screen-specific exceptions

- The active-workout command panel remains intentionally larger than normal
  cards because weight, reps, and `Complete set` must dominate under fatigue.
- The post-workout recommendation keeps more evidence than ordinary list rows
  because it must explain a persistent program change before acceptance.

## Release boundary

The evidence supports finishing the transparent double-progression contract,
not expanding the roadmap. After correctness, accessibility, StoreKit, full
tests, release build, and physical-device checks pass, stop and ship 2.1.

## Verification evidence

- **157 / 157 unit tests passed** on iPhone 17, iOS 26.3.1. The suite includes
  parser, import persistence, prefill precedence, first-session one-tap logging,
  all progression outcomes, accepted/edited target persistence, StoreKit states,
  history formatting, and copied-version-2.1 store migration.
- **14 / 14 UI tests passed** on iPhone SE (3rd generation), iOS 27.0,
  375 × 667. Twelve cover onboarding/paywall states and two cover the complete
  starting-target/progression contract, including a cold relaunch and History.
- The final **Release build succeeded** for Unit and `UnitWidgetExtension` and
  identifies itself as **2.1 (66)**.
- A clean launch of that Release binary on iPhone 17, iOS 26.3.1 produced no
  Unit-owned crash, migration/decoding failure, constraint warning, duplicate
  action, or repeated-Liquid-Glass-update log entry.
- `git diff --check`, project listing, plist validation, StoreKit JSON
  validation, and shared-scheme XML validation all pass.
- Physical-device StoreKit and real-gym checks remain external release gates.
  The repository also remains intentionally uncommitted and diverged, so this
  state must not be archived or uploaded.
