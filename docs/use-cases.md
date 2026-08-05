# Unit — Use Cases

> Updated 2026-04-13 to reflect the templates-not-plans direction (see `product-compass.md`).
> These use cases describe version 2.1 behaviour: template-based logging with Last time pre-fill and optional transparent double progression.

## Use Case 1: The Architect Runs Their Program

**Persona:** Architect — numeric, data-driven, plans everything.

**Scenario:** Marcus has been lifting for 3 years. He programs his own PPL split and tracks everything in the Notes app. It works, but scrolling through weeks of messy text to find last Tuesday's bench numbers takes longer than the set itself.

**How Unit Serves Him:**
Marcus opens Unit, taps "Import from text," and pastes his program from Notes. The parser extracts exercises and creates a template for each day. He later enables a rep range and increment for bench press. Last time or his accepted target prefills the next Push Day A, and he logs each set with one tap. After the workout, Unit shows the exact next target and why; Marcus accepts or edits it.

---

## Use Case 2: The Grinder Tracks Consistency

**Persona:** Grinder — consistent, hardworking, trusts feel over spreadsheets.

**Scenario:** Priya trains 5 days a week. She doesn't use periodisation — she adds weight when it feels right and holds when it doesn't. Her current tracker (Strong) buries her logging screen under a social feed and paywall prompts. She wants to log and get out.

**How Unit Serves Her:**
Priya builds her split in under 2 minutes during onboarding. She leaves progression unconfigured, so each session behaves exactly as before: Last time shows what she did, she adjusts when needed, and Done starts the rest timer. After 6 weeks, her progress history shows weight, reps, volume, and PRs without Unit prescribing a change.

---

## Use Case 3: The Recoverer Restarts After a Break

**Persona:** Recoverer — returning after a 3-month break, cautious, uncertain where to start.

**Scenario:** Tomas had shoulder surgery. He's cleared to lift but doesn't know where his numbers are now. His old app still shows weights from 3 months ago that he can't safely touch.

**How Unit Serves Him:**
Tomas creates a fresh split in onboarding. On his first session, the Last time fields are empty — "No history yet." He types conservative numbers for each exercise. From session two onward, Last time shows his new baseline. Each week he bumps the weight manually when he's ready. The app never pushes him — it shows what he did last time and lets him decide. His PR library resets naturally from the new starting point.
