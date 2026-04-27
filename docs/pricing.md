# Unit — pricing

> Authoritative reference for Unit's subscription tiers. Any change to price, trial length, or product IDs lives here first, code second.

## Tiers

| Tier       | Price        | Billing        | Product ID             | Notes                                                    |
| ---------- | ------------ | -------------- | ---------------------- | -------------------------------------------------------- |
| Monthly    | **$4.99**    | auto-renewing  | `com.unit.monthly`     | Entry tier. Cancelable anytime.                          |
| Annually   | **$29.99**   | auto-renewing  | `com.unit.annual`      | Default selection. ~$2.50/mo effective. 50% off monthly. |
| Lifetime   | **$44.99**   | one-time       | `com.unit.lifetime`    | 1.5× yearly. Pay once, own forever.                      |

All subscription tiers include a **7-day free trial**. Lifetime has no trial — it is a one-time purchase.

## Math

- Monthly × 12 = $59.88/yr
- Annual vs monthly-equivalent = $29.99 / $59.88 → **50% saved** (display as `SAVE 50%` on the Annual card)
- Lifetime = Annual × 1.5 = $29.99 × 1.5 = $44.985 → rounded to **$44.99**
- Lifetime payback ≈ 1.5 years of Annual, ≈ 9 months of Monthly

## Rationale

- **Matches Liftosaur** ($4.99/mo, $29.99/yr, 7-day trial — `docs/launch-plan.md` §3 market table). Liftosaur is the closest positioning neighbor ("solo indie; programmable routines; lifter-respected"), so matching pricing signals the same audience and avoids a premium-price discovery risk on day one.
- **Annual is default, highlighted.** Best LTV for Unit, biggest perceived savings for the user.
- **Monthly is the low-commitment entry.** Sits in the lifter-tool band alongside Strong ($4.99) and Liftosaur ($4.99), below Hevy ($6.99) and Fitbod ($12.99).
- **Lifetime at 1.5× yearly** is a deliberate premium: it rewards conviction without cannibalizing annual. At 1.5× (vs. typical 3–5× on other apps) it is intentionally generous — Unit's positioning is "trusted notebook," and a lifetime tier signals permanence, not extraction.
- **Core logging remains free forever** (launch-plan.md). Paywall gates Pro features only — never basic set logging. CLAUDE.md §4 scope fence.

## What is behind the paywall

Per `docs/launch-plan.md` §2:
- Unlimited template slots (free tier caps at 3)
- Full history beyond the last 30 days
- PR detection + notifications
- Widgets / Lock Screen Live Activity for rest timer
- Future Pro features (Watch companion, ProgressionEngine opt-in, cloud backup) — no second paywall

## Trial + win-back

- **Trial**: 7 days, applies to Monthly and Annual tiers at first purchase.
- **Win-back**: $19.99/yr Apple promotional offer (⅔ of Annual), triggered after trial expiry without conversion or post-cancel. Wire via StoreKit 2 or RevenueCat (launch-plan.md §2).
- **Founding member lock-in**: anyone subscribing in launch month keeps their rate forever.

## Changing prices

Don't change prices without data (launch-plan.md §3). If the numbers above need to move:
1. Update this file first.
2. Update the App Store Connect product config.
3. Update `StoreManager.swift` product IDs only if the IDs themselves changed (prices are pulled from StoreKit, not hardcoded).
4. Note the change in `docs/product-compass.md` §Decision log with the date and the evidence that justified it.
