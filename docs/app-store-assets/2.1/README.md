# Unit 2.1 App Store screenshots

Canonical English order:

1. `One clear target for next time`
2. `Log a set in 3 seconds`
3. `Increase reps, then weight`
4. `Choose a program or paste yours`
5. `See every step forward`
6. `Rest timer on your Lock Screen`

`source/` contains clean production-screen captures. `exports/6.9-inch/` contains the final flattened PNGs with no alpha channel.

Regenerate the upload set with `npm run build:app-store-screenshots`. The six
exports were visually verified on 2026-08-05; the Lock Screen source is a real
ActivityKit surface captured while its timer was counting down, not a mock.

Export contract:

- Portrait 6.9-inch accepted size: 1290 × 2796 px.
- One message per screenshot.
- Milk background, near-black type, one Unit accent only.
- Use real exercise and routine names; never ship QA-harness labels.
- Check every final PNG at full size and at App Store thumbnail size.
- English only for 2.1; do not reuse the stale localized metadata.

The current Apple size reference is `https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/`.
