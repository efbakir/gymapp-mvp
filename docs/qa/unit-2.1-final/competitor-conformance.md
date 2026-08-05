# Unit 2.1 lifting-app convention conformance

Scope: surgical verification of the existing competitor overhaul. The prior audit decoded 924 screenshots; this pass did not repeat that inventory.

| Convention | Unit implementation | Evidence |
|---|---|---|
| Today exposes one dominant Start/Resume action | Today preview keeps the routine and complete targets subordinate to one primary CTA | `docs/qa/progression-polish/01-today-iphone-se.png` |
| Exercise → sets → completion hierarchy | Active workout leads with exercise identity, set progress, target, and Complete set | `docs/qa/competitor-overhaul/screenshots/first-session-starting-target.png` |
| Previous performance is evidence | “Last time” is secondary and is never synthesized from a planned starting value | `docs/decision-log.md` — 2026-08-04 starting-target decision |
| Next target is the action | Post-workout card presents the complete target before the evidence and reason | `docs/qa/competitor-overhaul/screenshots/progression-increase-weight.png` |
| Progression configuration belongs to an exercise | Rep range and smallest increment use the existing exercise editor/configuration surface | `docs/qa/progression-polish/05-progression-configuration-iphone-se.png` |
| Recommendations happen after training | Active logging contains no recommendation controls; the summary owns Accept/Repeat/Edit | `docs/qa/progression-polish/02-add-rep-recommendation-iphone-se.png` |
| Accepted target becomes the next default | Cold relaunch preserves the accepted absolute target and Today/active workout prefill it | `docs/qa/progression-polish/06-next-workout-target-iphone-se.png` |
| One-handed, low-error logging | 44pt minimum targets, one primary set action, prefilled first and later sets | `docs/competitor-overhaul-audit.md` |

Material fixes in this final pass:

- Onboarding now teaches outcome → method → speed.
- Program review exposes the rep range and smallest increment; fixed prescriptions are labelled “Tracking only.”
- Starting targets remain visually distinct from previous-session evidence.
- Analytics and privacy controls were added outside the active logging loop.

Intentionally rejected competitor patterns: RIR/RPE requirements, recovery scores, body-profile questions, generated plans, muscle maps, automatic program rewriting, cycles, deload systems, social features, and coaching dashboards. They add setup or logging decisions without improving Unit’s three-second set action.
