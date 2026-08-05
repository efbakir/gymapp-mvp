# Unit — Cognitive Principles

Principles from [abtest.design](https://abtest.design/) and [growth.design/psychology](https://growth.design/psychology) applied to Unit for persuasiveness, behavior change, and retention.

---

## 1. Reduced friction

- **Principle**: Every step and field increases drop-off. Remove or defer non-essential input.
- **Unit**: Gym Test = log a set in under 3 seconds. Default to last weight/reps or an explicitly accepted target for this routine and exercise. One-tap “Done.” Rest timer in-flow and on Lock Screen so no app switching.
- **Source**: Friction reduction is a recurring theme in abtest.design (e.g. streamlined checkout, simpler onboarding).

---

## 2. Clarity of value

- **Principle**: User should immediately understand why they’re here and what they get.
- **Unit**: Home/Today = “Start workout” or “Continue session.” No discovery or feed. Value = “your program, logged fast, with history.” Templates and history reinforce “this is your log.”
- **Source**: Clear value props improve conversion (e.g. “How your free trial works,” clearer pricing).

---

## 3. Commitment and consistency

- **Principle**: Small commitments (e.g. logging one set) increase the likelihood of continuing; repeated completion reinforces identity.
- **Unit**: Completing one set is a micro-commitment. Session completion reinforces “I finished,” and history provides proof without streaks or achievement mechanics. Identity: “I’m someone who logs” (see [mental-models.md](mental-models.md)).
- **Source**: Consistent, low-friction completion can reinforce habit without adding gamification to the workout flow.

---

## 4. Social proof (light touch)

- **Principle**: Others’ behavior can motivate; too much shifts focus from personal progress.
- **Unit**: No social feed. Optional future: “X workouts logged” or “You’re in the top 10% of consistent loggers” (personal, not feed). We avoid comparison-heavy social proof that distracts from the Gym Test.
- **Source**: Social validation can help (e.g. Headspace trial survival); we use it sparingly and for personal progress only.

---

## 5. Loss aversion

- **Principle**: People are more motivated to avoid losing progress than to gain something new.
- **Unit**: “Don’t lose this set” — make it easy to log so the user doesn’t “lose” the data. Rest timer visible so they don’t “lose” rest time. Session in progress = “finish so you don’t lose the workout.”
- **Apply**: Save state; don’t require long forms that risk abandonment. Clear “you’re logged” feedback.

---

## 6. Clear CTAs

- **Principle**: One primary action per context; label should state the outcome.
- **Unit**: Primary CTA = “Complete set” (not “Save” or “Submit”). “Start workout,” “Start rest,” “End workout.” Buttons are large and use accent color (see [visual-language.md](visual-language.md)).
- **Source**: Optimal CTA design and placement (e.g. Unacademy, Instasize) improve clicks and conversions.

---

## 7. Ability and motivation (Behavior Change)

- **Principle**: Behavior happens when user has both ability (easy to do) and motivation (want to do). Reduce barriers and reinforce identity.
- **Unit**: Ability = Gym Test (easy), defaults, one-tap. Motivation = clear progress (history, session done) and identity (“I log my workouts”). See [behavior-change.md](behavior-change.md).
- **Source**: Designing for Behavior Change (Fogg, etc.); growth.design/psychology.

---

## 8. Predictability

- **Principle**: A familiar prefill removes the cognitive load of remembering what to lift while preserving user control.
- **Unit**: The active workout shows last time’s values, or an explicitly accepted target for the same routine and exercise. Double progression is evaluated only after the workout and presented as an understandable suggestion.
- **Apply**: Prefill must be visible immediately after session start. Never interrupt active logging with progression UI, and never change the routine until the user accepts or edits the post-workout suggestion.

---

## Summary

| Principle | Unit application |
|-----------|------------------------|
| Reduced friction | Last-time/accepted-target defaults, one-tap set, Live Activity rest. |
| Clarity of value | “Log fast. Know exactly what to do next.”; no feed. |
| Commitment/consistency | Completing sets and sessions reinforces the logging habit. |
| Social proof | Minimal; personal progress only, no feed. |
| Loss aversion | Easy logging so data isn’t lost; clear saved state. |
| Clear CTAs | “Done,” “Start Session,” “End Workout.” |
| Ability + motivation | Gym Test + transparent post-workout next step. |
| Predictability | Familiar prefill during the workout; explicit suggestion afterward. |

These principles guide feature and copy choices so Unit supports **behavior change** (logging consistently, following the progressive overload plan) without dark patterns.
