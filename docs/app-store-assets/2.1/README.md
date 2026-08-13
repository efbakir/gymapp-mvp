# Unit 2.1 App Store screenshots

Canonical English order:

1. `Know what to lift next`
2. `Log a set in 3 seconds`
3. `Hit 10 reps. Add 5 lb.`
4. `Paste your plan or choose one`
5. `See your strength go up`
6. `Rest timer on your Lock Screen`

`source/` contains clean production-screen captures. `exports/6.9-inch/` contains the final flattened PNGs with no alpha channel.

Regenerate the upload set with `npm run build:app-store-screenshots`. The six
exports were visually verified on 2026-08-12. Screens 1 and 3 use real
post-workout progression states, screen 2 uses the accepted next-workout target,
screen 4 uses the production program-source flow, screen 5 uses four completed
Bench Press sessions, and the Lock Screen source is a real ActivityKit surface
captured while its timer was counting down, not a mock. The US set uses pounds.

Export contract:

- Portrait 6.9-inch accepted size: 1290 × 2796 px.
- One message per screenshot.
- Milk background, near-black type, one Unit accent only.
- Use real exercise and routine names; never ship QA-harness labels.
- Check every final PNG at full size and at App Store thumbnail size.
- English only for 2.1; do not reuse the stale localized metadata.

The current Apple size reference is `https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/`.

After 2.1 is live, `ppo-plan.md` defines one future Product Page Optimization
test that swaps only screenshots 1 and 2. It does not change this submission.
