# Unit 2.1 localization status

> PRO-32 is a hard pre-submission gate. **Do not paste any locale into App Store Connect until every row is approved and this file says READY TO PASTE.**

## Current state

| Locale | Regenerated from frozen 2.1 English | Machine validation | Review | ASC |
|---|---:|---:|---|---|
| de-DE | Yes | Passed | AI linguistic QA 2026-07-27 — corrections applied | Founder paste approval pending — do not paste |
| es-MX | Yes | Passed | AI linguistic QA 2026-07-27 — corrections applied | Founder paste approval pending — do not paste |
| pt-BR | Yes | Passed | AI linguistic QA 2026-07-27 — corrections applied; name approved (AI QA, not native) | Founder paste approval pending — do not paste |
| fr-FR | Yes | Passed | AI linguistic QA 2026-07-27 — corrections applied; register locked to vous | Founder paste approval pending — do not paste |
| tr | Yes | Passed | AI linguistic QA 2026-07-27 — corrections applied; founder native read optional | Founder paste approval pending — do not paste |

Native human reviewers were unavailable for 2.1. The rows above record **AI linguistic QA — not native-human approval.**

Machine command:

```
npm run test:localizations
```

It validates:

- Name, subtitle, promotional text, description, keywords, and subscription limits
- Exactly five description bullets and three What’s New bullets
- No spaces in keywords
- No exact keyword duplication with the localized name or subtitle
- English-only UI disclosure
- EULA and privacy URLs
- Removal of the retired “you already know your program” positioning
- Keywords within 100 UTF-8 bytes (characters and bytes both reported)

## Review evidence

| Locale | Reviewer | Date | Result / edits |
|---|---|---|---|
| de-DE | AI linguistic QA (Claude reviewer + adjudication) | 2026-07-27 | 4 edits: What’s New agreement fix (required); promo vorausgefüllt; drop “optionale …Option” tautology; keywords +anfänger |
| es-MX | AI linguistic QA (Claude reviewer + adjudication) | 2026-07-27 | 5 edits: promo names the rest timer (required, 170/170); Lifetime line maps to “de por vida” (required); drop “compra de pago”; What’s New word order; keywords −musculación −sentadilla +principiante +series +historial |
| pt-BR | AI linguistic QA (Claude reviewer + adjudication) | 2026-07-27 | 3 edits: Lifetime→vitalícia (required); Tela Bloqueada capitalization; keywords halteres→planilha. Name “Unit: Diário de Treino” approved (AI QA) |
| fr-FR | AI linguistic QA (Claude reviewer + adjudication) | 2026-07-27 | 5 edits: Lifetime→Unit à Vie (required); promo tout prêt / pré-remplies / minuteur de repos (169/170); description ×2 and What’s New tout prêt; keywords −squat (byte limit, 99B). Register locked: vous |
| tr | AI linguistic QA (Claude reviewer + adjudication) | 2026-07-27 | 3 edits: Lifetime→Ömür Boyu (required); promo tek dokunuşla kaydedilir; keywords demir→ağırlık. Founder native read optional |

Method: five parallel Claude linguistic-review agents (one per locale, meaning/naturalness/market-research/ASO passes with cited Apple and competitor sources) plus one adjudication pass. OPTIONAL suggestions were not applied. **This is AI linguistic QA — not native-human approval.**

Final validation 2026-07-27: all five locales pass, including the new keyword byte check (de-DE 100B, es-MX 99B, pt-BR 91B, fr-FR 99B, tr 91B).

Remaining risks: native cadence unverified by human readers; keyword choices rest on competitor-listing evidence, not real search-volume data.

## Release rule

Steps 1–2 were completed by the 2026-07-27 AI linguistic QA pass. Remaining:

1. ~~Apply reviewer edits to the locale files.~~ Done 2026-07-27 (AI QA correction set).
2. ~~Run `npm run test:localizations` again.~~ Done 2026-07-27 — all five pass.
3. Founder reviews this file and grants paste approval, then change every ASC cell above to `Ready to paste`.
4. Mark PRO-32 Done.
5. Only then follow `asc-paste-checklist.md`.
