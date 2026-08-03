# Unit — App Store copy (canonical)

> **2.1 PIVOT CANDIDATE — founder-approved 2026-08-03.** Paste only after the progression flow, seven-day trial, patch notes, feature-request action, and reliability fixes are merged, tested, and present in the selected archive. The five previous locale files are stale and must not be published from their old copy.
> Process: `docs/app-store-submission/final-submit-checklist.md`.

---

## App name (30)

```
Unit: Progressive Overload
```

26 characters. The home-screen name stays `Unit`. This title is honest only when the submitted build calculates and presents a clear next-workout target from completed sets.

## Subtitle (30)

```
Gym Workout Log & Tracker
```

25 characters. It keeps the category immediately understandable while the title carries the outcome.

## Promotional text (170)

```
Know what to do next. Unit turns your completed sets into a clear next-workout target you can accept or change. New subscribers get 7 days free.
```

## Description (4000)

```
Know what to do next—and log every set in seconds.

Unit uses your completed working sets to suggest one clear target for next time. Reach the top of your rep range and Unit suggests the next weight. Not there yet? Keep the weight and add a rep. Every suggestion explains why, and you can accept or change it.

• Clear next-workout targets
• Rep ranges and weight increments per exercise
• One-tap set logging with last time’s values ready
• Ready-made programs or paste your own routine
• Automatic rest timer on the Lock Screen
• Progress history for weight, reps, and volume

No account. No ads. No social feed. Your training stays on your iPhone.

Eligible new subscribers can start a 7-day free trial on a weekly, monthly, or yearly plan. After the trial, the selected subscription renews automatically at the price shown in the app unless cancelled. Optional Lifetime appears only if available and has no trial.

Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://unitlift.app/privacy
```

## Keywords (100 bytes, comma-separated, no spaces)

```
rest,timer,rep,counter,set,barbell,notebook,diary,strength,lifting,weights,routine,personal,record
```

98 UTF-8 bytes. No repetition of indexed title/subtitle terms. RespectASO evidence available on 2026-08-03 supported `rest timer` (opportunity 61), `rep counter` (64), `reps tracker` (48), `barbell tracker` (37), and `progressive overload` (39); the title/subtitle carry the last term and `tracker` already.

## What’s New — v2.1

```
Unit now helps you decide what to do next.

• Clear next-workout targets based on completed sets
• Accept or change every progression suggestion
• Progress history for weight, reps, and volume
• Patch notes and feature requests in Settings
• Improved logging, purchases, and reliability
```

## Screenshots

The rename and progression feature ship together. Replace the first screenshot with the real progression result state:

```
Know what to do next
62.5 kg · 8 reps
All sets reached the top of your range.
```

Keep the strongest existing speed, program import, privacy/history, and Lock Screen rest-timer screenshots after it. Do not submit the new name with a screenshot set that shows only generic logging.

## Reviewer notes (App Review Information → Notes)

```
Unit 2.1 is a local-first progressive-overload workout logger for iPhone. It uses completed working sets and each exercise’s rep range and weight increment to show one transparent next-workout target. The user can accept or change every suggestion; Unit does not rewrite the user’s program or provide recovery, medical, or AI coaching advice.

To evaluate:
1. Complete onboarding and save a ready-made or pasted program. No personal information is requested. The full-screen paywall appears after setup and cannot be dismissed.
2. Weekly (com.unit.weekly), Monthly (com.unit.monthly), and Yearly (com.unit.annual) each have a 7-day free introductory offer for eligible new subscribers in the unit-pro subscription group. StoreKit determines eligibility. Ineligible accounts see the normal price and renewal disclosure. Optional Lifetime (com.unit.lifetime) is a one-time purchase with no trial and appears only if StoreKit returns it.
3. Start any eligible trial or complete a sandbox purchase. After StoreKit verifies the transaction, the paywall dismisses and Today unlocks.
4. Complete the working sets for an exercise. If every set reaches the top of its rep range, Unit suggests the next available weight and resets the target to the bottom of the range. Otherwise Unit keeps the weight and suggests one more rep. Accept or edit the target, then open the next workout and confirm it is prefilled.
5. Log a set to verify that the rest timer starts automatically on the Lock Screen / Dynamic Island. Settings → What’s new opens https://unitlift.app/updates. Settings → Request a feature opens a prefilled email to support@unitlift.app.
6. To manage or cancel a subscription: Settings → Manage Subscription. Lifetime has no Manage Subscription row because it is a non-consumable.

Engagement prompts count only workouts completed after installing this version. After workout one, Unit makes one standard StoreKit review-request attempt two seconds after the summary closes and Today is active; iOS may suppress it. On workout three’s summary, a one-time non-blocking feedback card opens https://calendar.notion.so/meet/efbakir/unit-feedback or a prefilled email to support@unitlift.app. Neither prompt appears during an active workout.

The app does not collect, transmit, or store personal data. Workout data stays on-device via SwiftData. If you have questions during review, email support@unitlift.app.
```

## Subscription group + products

Group: reference name `unit-pro` (immutable) · display name `Unit Pro`.

| Product ID | Display name | Description | USD base | Introductory offer |
|---|---|---|---|---|
| `com.unit.weekly` | `Unit Weekly` | `Weekly access to Unit.` | **$2.99** | 7 days free |
| `com.unit.monthly` | `Unit Monthly` | `Monthly access to Unit.` | $4.99 | 7 days free |
| `com.unit.annual` | `Unit Yearly` | `Yearly access to Unit.` | $29.99 | 7 days free |
| `com.unit.lifetime` | `Unit Lifetime` | `One-time purchase. Lifetime access.` | $44.99 optional | None |

StoreKit and App Store Connect are the eligibility and price authorities. A customer can use only one introductory offer in the subscription group.

## URLs / fixed fields

| Field | Value |
|---|---|
| Support URL | `https://unitlift.app/support` |
| Marketing URL | `https://unitlift.app` |
| Privacy Policy URL | `https://unitlift.app/privacy` |
| Category | Health & Fitness |
| Age rating | 4+ |
| Copyright | 2026 Efe Bakir |

## Voice and claim rules

- Sell the second-order benefit: knowing what to do next and making progress.
- Prove it with the transparent first-order mechanism: completed sets → one explained target → accept or change.
- Never claim AI coaching, automatic program rewriting, recovery guidance, guaranteed muscle gain, or guaranteed strength gain.
- Never show trial copy unless StoreKit reports both a free-trial offer and eligibility.
