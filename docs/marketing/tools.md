# Tools

> The minimum stack to run Unit's marketing. Resolved 2026-04-29 at $50/mo comfortable tier.
> Total: ~$51/mo tooling + ~$67/mo UGC amortized = **~$120/mo all-in cap**.

## The stack

| # | Tool | Tier | $/mo | Set up by | Why |
|---|---|---|---|---|---|
| 1 | [Buffer](https://buffer.com) | Essentials | $6 | W1 | Multi-platform scheduler. Essentials covers IG + TikTok + X + Threads simultaneously. |
| 2 | [Submagic](https://submagic.co) | Pro | $16 | W2 | Auto-captions + B-roll on YOUR clips. Single biggest quality lift per dollar. |
| 3 | [Opus Clip](https://www.opus.pro) | Pro | $19 | W2 | Long video → 30 shorts. Pro removes the 60min/mo source cap. |
| 4 | [AppFigures](https://appfigures.com) | Insights starter | ~$10 | W3 | ASO + competitor monitoring + ranking alerts. |
| 5 | [CapCut](https://www.capcut.com) | Free | $0 | W1 | Assembly + transitions. Free is sufficient. |
| 6 | [RevenueCat](https://www.revenuecat.com) | Free | $0 | already wired | Subs analytics + the Charts dashboard you screenshot for Reddit. |
| 7 | [TelemetryDeck](https://telemetrydeck.com) | Free | $0 | W2 | Privacy-first Swift-native event analytics. Free <10k signals/mo. |
| 8 | Apple App Analytics | Free | $0 | already on | Built-in install/retention/source data. |
| 9 | [Apple Search Ads keywords](https://searchads.apple.com) | Free | $0 | W3 | Free ASO keyword research baseline. |
| 10 | [ElevenLabs](https://elevenlabs.io) | Starter | $5 | W2+ (when needed) | Clone your own voice for voiceover over screen recordings. Defer until needed. |

**Total**: ~$51/mo at full comfortable tier. Skip ElevenLabs to defer to ~$46/mo until you need it.

## UGC creator budget (separate, quarterly)

| Tier | Vendor | $/quarter | Notes |
|---|---|---|---|
| 1st choice | [Billo](https://billo.app) | $200 (4 videos) | Largest pool, casting filters by activity. |
| 2nd choice | [Insense](https://insense.pro) | $300 (4-5 videos) | Higher avg quality, tighter pool. |
| 3rd choice | [JoinBrands](https://joinbrands.com) | $200 | Tradesman aesthetic, fewer creators. |

Plan **~$200/quarter = $67/mo amortized**. Casting brief lives in `ugc-brief.md`.

## Account checklist

> ⚠️ Don't commit credentials to this file. List of *which accounts to create*, not where to store secrets.

- [ ] Buffer account
- [ ] Submagic account
- [ ] Opus Clip account
- [ ] AppFigures account
- [ ] CapCut account (use existing iCloud/Apple)
- [ ] TelemetryDeck account + token wired into Unit/
- [ ] ElevenLabs account (defer until needed)
- [ ] Billo account (when first UGC drop is briefed)

Credentials → 1Password. App tokens (TelemetryDeck) → `Unit/Configuration/` private build settings, never committed.

## Skip permanently at this stage

| Tool | Why skip |
|---|---|
| HeyGen, Synthesia, AutoShorts.ai, Pictory, InVideo | Full AI talking heads — research-confirmed shadowban risk in fitness 2025-2026 |
| Hypefury | X-heavy, overkill at $0 MRR |
| Later | Pricier than Buffer for the same job |
| Mixpanel, Amplitude | Heavier than indie scale needs |
| Sensor Tower, MobileAction, AppTweak | $400+/mo ASO platforms — wait for $5k+ MRR |
| Apollo, Hunter, Smartlead | B2B cold outreach — wrong category for B2C iOS |
| 3rd-party Reddit schedulers | Ban risk on new accounts |

## Total cost ceiling

The all-in cap for marketing tooling + UGC at this stage: **~$120/mo**. If a tool would push past this, justify the new spend against the 5 metrics in `cadence.md` first. No exceptions for "growth hacks."

## See also

- `cadence.md` — when to use which tool in the weekly rhythm
- `content-engine.md` — Submagic + Opus Clip + CapCut workflow
- `automation-map.md` — what each tool gets used for vs what stays manual
- `anti-patterns.md` — tools deliberately not in this stack and why
