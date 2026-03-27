# **Optimized Log-First Engineering: A Product Strategy and Market Analysis for the Minimalist Gym Interface**

## **The Complexity Paradox in Modern Strength Training Software**

The contemporary fitness application market has reached a state of feature saturation that paradoxically diminishes the utility of the software for the most dedicated users. While first-generation applications competed on the breadth of their exercise libraries and the complexity of their periodization algorithms, a significant segment of the market—characterized by intermediate to advanced lifters—now experiences what is termed complexity fatigue.1 This fatigue stems from a misalignment between the developer's desire for "smart" coaching and the user's primary requirement: a frictionless digital surrogate for the traditional paper notebook.3

The original approach of a log tracker tightly coupled with a multi-week cycles plan, as seen in the current screenshots, mirrors the industry trend toward prescriptive AI and rigid scheduling. However, user research suggests that high-friction planning tools often become barriers to the core activity of logging.5 By reducing the complexity of cycles and prioritizing the immediate workout log, the product pivots toward a "utility-first" philosophy that values speed over planning. This transition is not merely a reduction of features but a strategic realignment to fill the "open space" in the industry: a high-speed, one-handed logging tool that respects the user's expertise without imposing a rigid structure.7

| Feature Dimension | Prescriptive Apps (Fitbod/RP) | Social Trackers (Hevy/Strong) | The Proposed MVP Strategy |
| :---- | :---- | :---- | :---- |
| **User Intent** | Guidance and "What to do" | Community and Comparison | Speed and Personal Utility |
| **Cognitive Load** | High (Algorithmic choices) | Moderate (Social noise) | Low (Focus on the log) |
| **Navigation** | Deep (Multi-layered menus) | Moderate (Tab-based) | Shallow (2-tap entry) |
| **Success Metric** | Adherence to Plan | Engagement/Likes | Seconds per Set Logged |

The evidence from community discussions indicates that users often abandon feature-rich apps like Fitbod or RP Hypertrophy because the effort required to "manage the app" during a workout exceeds the perceived benefit of the data collected.9 The move to put cycles in second place allows the software to capture the user's intent at the moment of peak physiological stress, where decision-making capacity is at its lowest.12

## **Market Landscape: Identifying the Minimalist Utility Gap**

The current market is bifurcated into automated "coaching" apps and manual "tracking" apps. Automated apps, such as JuggernautAI and RP Hypertrophy, utilize self-reported data to adjust training volume and intensity.5 While highly effective for a niche audience, these apps are often criticized for their steep learning curves, high subscription costs, and the "black box" nature of their recommendations.6 Conversely, tracking apps like Strong and Hevy have become the industry standard but are increasingly encumbered by social features and "pro" paywalls that lock away basic historical data.7

The "open space" identified in this research lies in the "Zero-Friction Notebook" category. Applications like Setgraph and Gym Note Plus have recently gained traction by focusing almost exclusively on the speed of data entry.7 Gym Note Plus, for example, allows users to paste raw text notes from their iPhone and uses LLMs to structure that data, effectively removing the need for a UI during the workout itself.18 For Efe’s Gym App, the competitive advantage will be found in a native UI that mimics the speed of text-taking while retaining the structural benefits of a database—such as PR tracking and volume charts—without the technical overhead of parsing messy shorthand.3

### **User Pain Points and Friction Analysis**

The friction in existing gym apps is often a result of "tapping through screens" to perform simple actions. Lifters report a preference for interfaces that prioritize the "log-first" philosophy, intentionally avoiding complex AI-generated routines in favor of a clean interface that mimics a digital notebook.11 This is particularly relevant for users with ADHD or those who find high-intensity gym environments distracting; the cognitive load of navigating dropdowns and menus during a rest period is a primary driver of app abandonment.20

| Friction Source | Impact on User Experience | MVP Solution |
| :---- | :---- | :---- |
| **Dropdown Menus** | Slows down input; requires precision | Table-based inline editing |
| **Mandatory Onboarding** | High barrier to entry; annoying for pros | Direct entry to "Start Workout" |
| **Rigid Scheduling** | Frustration when skipping a day | Flexible "Today" view with Templates |
| **Social Media Feed** | Distracting; increases app bundle size | Zero social features; local storage first |

The "Notebook Gap" is where the current product direction resides. By providing a tool that is faster than a paper notebook but smarter than a basic notes app, the project satisfies the user's need for efficiency while providing the longitudinal insights necessary for progressive overload.4

## **Ergonomics and Environmental Constraints: The Gym Context**

Designing for the gym environment requires an understanding of the physiological and physical constraints under which the user operates. The "Gym Context" implies one-handed use, sweaty fingers, fragmented attention, and physical fatigue.12 Research into mobile UX design for utility applications emphasizes the "Thumb Zone"—the area of the screen reachable without shifting grip.12 In a gym setting, this zone becomes even more critical as the user may be holding equipment or leaning against a rack with their free hand.

### **The Thumb Zone and Interaction Density**

Statistically, 61% of users operate their phones one-handed most of the time.13 For a workout tracker, this means the most frequent actions—logging a set, adding an exercise, and starting a timer—must reside in the bottom third of the screen.12 The "Impossible Zone" at the top corners should be reserved for infrequent actions like settings or account management.12 The proposed layout for the workout session screen focuses the "logging table" in the easy-to-reach central and bottom areas, ensuring that the primary interaction of checking off a set is a natural thumb movement.13

### **Tactile Feedback and Visual Hierarchy**

Sweaty hands and blurred vision due to physical exertion necessitate large touch targets (at least 44x44 points) and a high-contrast visual hierarchy.22 The use of haptic feedback upon tapping the "Done" checkbox provides an essential non-visual confirmation, reducing the need for the user to stare at the screen between sets.22 Furthermore, "Invisible UX"—where the app anticipates the user's intent—is a core principle for this MVP. This is achieved by pre-filling the weight and reps of a new set based on the previous set's performance, allowing for a "tap-only" logging experience for the majority of a session.4

## **Product Strategy: Pivot to a Minimalist MVP**

The pivot from a cycle-heavy plan to a log-first tracker is supported by the need to establish a "must-win" core: the logging of exercises, sets, and reps with minimal friction. The "Cycles" feature, while valuable for long-term planning, is a secondary goal that should only be implemented once the core logging engine is verified as faster than competing tools.7

### **The Core Milestone: Speed as a Feature**

The single most important outcome for this stage is the reduction of taps required to start and finish a workout session. In the current "Cycles" approach, a user might have to navigate through several layers of a program to find "Day 4" before logging. The revised IA flattens this structure, allowing the user to either start an empty workout or pick from a list of "Templates" directly from the home screen.7

| User Action | Cycles-First Taps | Log-First MVP Taps | Improvement |
| :---- | :---- | :---- | :---- |
| **Start Workout** | 4-5 taps (Navigate Program) | 1-2 taps (Today View) | \>50% |
| **Add Set** | 2-3 taps (Open modal) | 1 tap (Inline add) | \>60% |
| **Log PR** | Manual calculation | Automatic detection | Instant |
| **Finish Workout** | Complex summary navigation | Single "Finish" button | High |

By prioritizing "Speed \> Features," the MVP focuses on the "Active Session" as the center of the user's universe. The history and progress charts are treated as rewards for the logging effort, rather than hurdles to be cleared before the workout can begin.4

## **UX Architecture: Screen Specifications and Interactions**

The Information Architecture (IA) is designed to keep the user in the "Active Zone" with minimal context switching. The flow is centered around three primary screens: the Today Home, the Workout Session, and the History/Progress view.

### **Screen 1: Home / Today (The Gateway)**

The purpose of the Home screen is to provide an immediate path to action. It must address three user states: "I want to start my planned workout," "I want to do a quick freestyle session," and "I want to resume my interrupted session."

* **Primary Actions:** "Start Empty Workout" (Floating Action Button), "Resume Workout" (Contextual Banner), and a list of "Pinned Templates" (e.g., Push, Pull, Legs).13  
* **Layout:**  
  * **Top:** Minimalist greeting with "Weekly Volume" or "Consistency Heatmap" to provide instant gratification.27  
  * **Middle:** "Continue" card if a session is active; otherwise, a list of the 3 most recent workout templates.16  
  * **Bottom:** Large, thumb-accessible "Start Workout" button in the Easy Zone.12  
* **Acceptance Criteria:**  
  * Must load in \<500ms.  
  * One tap to start a recent template.  
  * "Resume" state must persist even after app force-close.23

### **Screen 2: Workout Session (The Active Workspace)**

This is the most utilized screen. It must facilitate data entry without distraction. The "Cycles" information is relegated to a simple header label, while the focus is entirely on the exercise list and the sets table.6

* **Layout:**  
  * **Header:** Session timer, current volume calculation, and a "Finish" button.27  
  * **Active Exercise Card:** Displays the current exercise, "Last Time" performance (Weight/Reps), and the logging table.8  
  * **The Sets Table:** A row-based structure (Set \# | Previous | Weight | Reps | Done Checkbox).6  
* **Interactions:**  
  * **Tap Checkbox:** Logs the set, triggers the rest timer, and creates a new row pre-filled with the same values.7  
  * **Inline Editing:** Tapping Weight or Reps opens the number pad immediately; no modals or popups.6  
  * **Swipe Actions:** Swipe left on a row to delete; swipe right to mark as a "Warmup" or "Fail".13  
* **Acceptance Criteria:**  
  * Visual "PR" celebration if the user beats their "Last Time" values.  
  * Rest timer must be visible in the Dynamic Island or Lock Screen for iOS users.27

### **Screen 3: Exercise Library and Search**

The library must be a searchable index of movements, categorized by muscle group. For the MVP, it focuses on canonical names to prevent database fragmentation.7

* **Interactions:**  
  * **Multi-Select:** Users should be able to tap 5 exercises and add them all to the workout in one step.16  
  * **Instant Search:** Filter results as the user types; prioritize "Recent" exercises at the top of the search results.27  
* **Acceptance Criteria:**  
  * Prevent duplicate exercise names via a merge suggestion UI.  
  * Support for "Custom Exercise" creation with a 1-step form.

## **Data Model: Decoupling and Scalability**

A simple but explicit data model is required to support the move from cycles to logs while ensuring future extensibility. The core entities must decouple the *intent* (Template) from the *reality* (Session).31

### **Entities and Relationships**

| Entity | Attributes | Purpose |
| :---- | :---- | :---- |
| **Exercise** | id, name, muscleGroup, type (Weight/Duration), isCustom | Reference data for all movements. |
| **WorkoutTemplate** | id, name, exerciseIds, lastPerformedAt | Pre-defined routines (e.g., Push Day A).21 |
| **WorkoutSession** | id, templateId (optional), date, startTime, endTime | The instance of a workout being performed.31 |
| **SetEntry** | sessionId, exerciseId, weight, reps, isDone, type (Working/Warmup) | The granular data point for every lift.32 |
| **PersonalRecord** | exerciseId, maxWeight, maxVolume, max1RM | Derived data for progress visualization.19 |

### **Theoretical Progression Metrics (LaTeX)**

The application will use the Epley formula to estimate the One-Rep Max (1RM) for any set. This allows the user to compare strength across different rep ranges, which is essential for progressive overload tracking in a "Cycles-Lite" environment.

![][image1]  
Total Training Volume (![][image2]) for a session is calculated as:

![][image3]  
These calculations should be performed locally and cached in the PersonalRecord table to ensure that charts and PR notifications are rendered instantly without expensive database queries.8

## **Technical Implementation Plan (Cursor/Codex)**

The development strategy utilizes an iterative "Vibecoding" approach, focusing on the most critical components first. The following plan assumes the use of React Native or a similar mobile framework with a local-first database (e.g., SQLite or WatermelonDB).3

### **Step 1: The Active Session State**

The foundation of the app is the ability to manage a session in progress. This requires a robust state management system that persists to local storage after every set logged.23

**Implementation Goal:** Create the currentSession store.

* **Files:** src/store/workoutStore.ts, src/db/schema.ts  
* **Logic:** Implement startSession, addExerciseToSession, logSet, and finishSession.  
* **Success Criteria:** A user can start a session, add "Bench Press," log a set of 100kg x 10, and see the session persist after a reload.

### **Step 2: The Logging UI (The Sets Table)**

The sets table is the primary interaction point. It must be optimized for speed and one-handed use.7

**Implementation Goal:** Build the SetsTable component.

* **Files:** src/components/Workout/SetsTable.tsx, src/components/UI/Checkmark.tsx  
* **Logic:** Render a table where each row is a SetEntry. Implement "incremental entry" (pre-fill next set with previous values).4  
* **Success Criteria:** Tapping "Add Set" creates a row with the same weight/reps as the one above; tapping the checkmark dims the row and triggers a haptic vibrate.

### **Step 3: History and Progress Visualization**

Once data is being collected, the user needs to see their progress. This satisfies the "Secondary Goal" of simple charts and PRs.19

**Implementation Goal:** Create the ExerciseHistory and ProgressChart components.

* **Files:** src/screens/History/HistoryScreen.tsx, src/components/Charts/VolumeChart.tsx  
* **Logic:** Query SetEntry history for a specific exerciseId. Calculate and plot the Estimated 1RM over time.21  
* **Success Criteria:** A line chart appears showing strength gains over the last 30 days for any selected exercise.

## **Quality Assurance and Edge Cases**

A utility app is only as good as its reliability. The following edge cases must be handled to ensure a professional-grade user experience.23

### **Critical Edge Cases**

| Scenario | UX Handling | Technical Strategy |
| :---- | :---- | :---- |
| **Phone Shutdown/Crash** | Auto-resume banner on restart | localStorage persistence after every set log.23 |
| **Mistaken Set Log** | "Undo" snackbar after set completion | Temporary state queue before final DB commit.35 |
| **Missing "Last Time" Data** | Show a "First time doing this\!" empty state | LEFT JOIN on session history; handle null values. |
| **Variable Rep Ranges** | Allow fractional reps (e.g., 2.5) for precise progress | Float data type for reps in SetEntry.27 |
| **Duplicate Exercises** | Offer to "Merge" exercises if names are similar | Levenshtein distance algorithm for name comparison.37 |

### **Manual QA Checklist for MVP**

1. **Template to Log:** Create a "Push Day" template → Start workout → Log 3 sets → Finish workout → Verify entry in History.  
2. **Freestyle Log:** Start empty workout → Search for "Squat" → Add to session → Log 1 set → Verify PR notification appears if it's a new high.19  
3. **Persistence Test:** Log a set → Force quit app → Reopen → Verify the session is still there and the "Done" checkbox is still checked.  
4. **Edit Flow:** Log 100kg x 10 → Tap the "100" → Change to "105" → Tap "Done" on keyboard → Verify the new value is saved without a modal.6

## **The Future Roadmap: Re-integrating Cycles**

Once the MVP is established as the fastest logger in the industry, "Cycles" can be reintroduced not as a constraint, but as a layer of automation. Instead of forcing the user into a rigid "Day 4" schedule, the v2 Cycles feature will simply suggest the next template in a sequence.26

* **v2 Goal:** Cycle sequencing (A, B, Deload).  
* **v2 Goal:** Automated weight increments (e.g., "Add 2.5kg if 3x10 was achieved last week").26  
* **v2 Goal:** Volume balancing (Heatmap showing muscle group frequency).11

By keeping the foundation simple, the application remains resilient to the changing needs of the lifter while maintaining the "log-first" philosophy that defines its market position.

## **Technical Handoff: Codex/Cursor Prompts**

The following prompts should be used to implement the core screens using a coding agent.

### **Prompt A: The Active Workout Screen**

**Context:** I am building a minimalist gym app. I have a WorkoutSession object and a list of SetEntry items.

**Task:** Create a React Native screen for the active workout session.

1. The header should show the session duration (running timer) and a "Finish" button.  
2. The main area should be a list of exercises. For each exercise, show a table of sets.  
3. The table columns are: Set \#, Prev (text), Weight (input), Reps (input), and a Checkbox.  
4. **Constraints:** Use the "Sets Table" logic where tapping the checkbox pre-fills the next row. Use a numeric keyboard for inputs. Keep it one-handed friendly with all buttons in the bottom 60% of the screen.  
5. **Files to modify/create:** src/screens/WorkoutSession.tsx, src/components/SetRow.tsx.

### **Prompt B: History and Progress Logic**

**Context:** I need to visualize progress over time for individual exercises.

**Task:** Implement the logic to calculate the estimated 1RM and volume for an exercise across its history.

1. Fetch all SetEntry items for a specific exerciseId.  
2. Group them by sessionId.  
3. For each session, calculate the maxWeight and the max1RM using the Epley formula: Weight \* (1 \+ Reps/30).  
4. Create a data array compatible with a line chart library (like react-native-chart-kit).  
5. **Constraints:** Ensure the calculation is efficient; don't re-calculate the entire history on every screen render—cache it.  
6. **Files to modify/create:** src/utils/progression.ts, src/components/ProgressChart.tsx.

### **Prompt C: Exercise Library Multi-Select**

**Context:** I want to add exercises to my workout quickly.

**Task:** Create an exercise library screen with multi-select capability.

1. Show a list of exercises grouped by muscle group.  
2. Add a search bar that filters the list in real-time.  
3. When an exercise is tapped, it should be "selected" (show a blue border or checkmark).  
4. A floating action button at the bottom should say "Add (X) Exercises".  
5. Tapping this button adds the selected exercises to the current workout session and navigates back.  
6. **Constraints:** The list should be virtualized for performance if it contains 500+ items.  
7. **Files to modify/create:** src/screens/LibraryScreen.tsx.

## **Conclusion: The Path Forward**

The shift from a complex cycle-based planner to a minimalist, log-first MVP is a direct response to the friction experienced by serious lifters in the current app market.1 By prioritizing the ergonomics of the gym environment and the cognitive needs of the user, this project occupies the "Utility Gap" between simple notes apps and bloated AI coaches.8

The technical roadmap provided focuses on building a robust, local-first logging engine that fulfills the primary goal of speed and minimal friction.3 Once this foundation is verified through real-world usage, the "Cycles" logic can be layered back into the product as a secondary, non-obtrusive feature, ensuring the app remains satisfying to use for both the "freestyle" lifter and the "structured" athlete. This approach ensures product-market fit by solving the most painful problem first: the data entry bottleneck.8

#### **Works cited**

1. Favorite workout apps that tell you exactly what to do? \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/workout/comments/1r07v00/favorite\_workout\_apps\_that\_tell\_you\_exactly\_what/](https://www.reddit.com/r/workout/comments/1r07v00/favorite_workout_apps_that_tell_you_exactly_what/)  
2. Are there better apps then Fitbod : r/workout \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/workout/comments/1qrxszz/are\_there\_better\_apps\_then\_fitbod/](https://www.reddit.com/r/workout/comments/1qrxszz/are_there_better_apps_then_fitbod/)  
3. Simple Workout Log \- The best minimalist workout tracker available, accessed March 26, 2026, [https://www.simpleworkoutlog.com/](https://www.simpleworkoutlog.com/)  
4. Workout Log: How to Track Your Training and Build Muscle Faster \- Setgraph: Workout Tracker App, accessed March 26, 2026, [https://setgraph.app/ai-blog/workout-log-track-training-build-muscle](https://setgraph.app/ai-blog/workout-log-track-training-build-muscle)  
5. RP Hypertrophy App \- Bodybuilding App, Muscle Growth Workouts \- RP Strength, accessed March 26, 2026, [https://rpstrength.com/pages/hypertrophy-app](https://rpstrength.com/pages/hypertrophy-app)  
6. Has anyone used the RP Hypertrophy App recently? Been looking for reviews, but the best I can find is still from 4 months ago and I know they are constantly updating. Any recent reviews? : r/naturalbodybuilding \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/naturalbodybuilding/comments/1asxy5v/has\_anyone\_used\_the\_rp\_hypertrophy\_app\_recently/](https://www.reddit.com/r/naturalbodybuilding/comments/1asxy5v/has_anyone_used_the_rp_hypertrophy_app_recently/)  
7. Best App for Tracking Workouts: 15 Apps Tested by Lifters (2025) \- Setgraph, accessed March 26, 2026, [https://setgraph.app/ai-blog/best-app-for-tracking-workouts](https://setgraph.app/ai-blog/best-app-for-tracking-workouts)  
8. Workout Tracking Guide 2024: Methods, Apps & How to Track Progress \- Setgraph, accessed March 26, 2026, [https://setgraph.app/ai-blog/workout-tracking-guide-methods-apps-progress](https://setgraph.app/ai-blog/workout-tracking-guide-methods-apps-progress)  
9. I used the RP Hypertrophy App for 6 Months | by Justin James Smith ..., accessed March 26, 2026, [https://medium.com/@justinsmith31491/i-used-the-rp-hypertrophy-app-for-6-months-f20e67378b20](https://medium.com/@justinsmith31491/i-used-the-rp-hypertrophy-app-for-6-months-f20e67378b20)  
10. Thoughts on RP Hypertrophy App? : r/StrongerByScience \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/StrongerByScience/comments/12mja6x/thoughts\_on\_rp\_hypertrophy\_app/](https://www.reddit.com/r/StrongerByScience/comments/12mja6x/thoughts_on_rp_hypertrophy_app/)  
11. Differences between apps? : r/Hevy \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/Hevy/comments/1q0okbc/differences\_between\_apps/](https://www.reddit.com/r/Hevy/comments/1q0okbc/differences_between_apps/)  
12. How Should I Design My App for One-Handed Use?, accessed March 26, 2026, [https://thisisglance.com/learning-centre/how-should-i-design-my-app-for-one-handed-use](https://thisisglance.com/learning-centre/how-should-i-design-my-app-for-one-handed-use)  
13. Designing for One-Hand Use: Mobile UX in the Age of Multitasking | ThinkDebug, accessed March 26, 2026, [https://thinkdebug.com/designing-for-one-hand-use-mobile-ux-in-the-age-of-multitasking/](https://thinkdebug.com/designing-for-one-hand-use-mobile-ux-in-the-age-of-multitasking/)  
14. Top 5 Muscle Building Apps Fitness Fans Love in 2026 \- Emergent, accessed March 26, 2026, [https://emergent.sh/learn/best-muscle-building-app-builder](https://emergent.sh/learn/best-muscle-building-app-builder)  
15. Is the RP Hypertrophy App worth it? : r/naturalbodybuilding \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/naturalbodybuilding/comments/158fn4i/is\_the\_rp\_hypertrophy\_app\_worth\_it/](https://www.reddit.com/r/naturalbodybuilding/comments/158fn4i/is_the_rp_hypertrophy_app_worth_it/)  
16. Strong Workout Tracker Gym Log \- ScreensDesign, accessed March 26, 2026, [https://screensdesign.com/showcase/strong-workout-tracker-gym-log](https://screensdesign.com/showcase/strong-workout-tracker-gym-log)  
17. Hevy \- Workout Tracker Gym Log \- App Store \- Apple, accessed March 26, 2026, [https://apps.apple.com/us/app/hevy-workout-tracker-gym-log/id1458862350](https://apps.apple.com/us/app/hevy-workout-tracker-gym-log/id1458862350)  
18. I got tired of clicking though 15 different menus just to log a workout, so I built an app that takes shorthand workout notes and transforms them into actual data. It's free and has 0 ads. : r/iosapps \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/iosapps/comments/1plwh5w/i\_got\_tired\_of\_clicking\_though\_15\_different\_menus/](https://www.reddit.com/r/iosapps/comments/1plwh5w/i_got_tired_of_clicking_though_15_different_menus/)  
19. Setgraph: Workout Log \- Apps on Google Play, accessed March 26, 2026, [https://play.google.com/store/apps/details?id=app.setgraph](https://play.google.com/store/apps/details?id=app.setgraph)  
20. I made this note to workout log app to remove friction when tracking ..., accessed March 26, 2026, [https://www.reddit.com/r/ADHD\_Programmers/comments/1q3vqn1/i\_made\_this\_note\_to\_workout\_log\_app\_to\_remove/](https://www.reddit.com/r/ADHD_Programmers/comments/1q3vqn1/i_made_this_note_to_workout_log_app_to_remove/)  
21. How to Track Your Workout: A Complete, Practical Guide \- Setgraph: Workout Tracker App, accessed March 26, 2026, [https://setgraph.app/ai-blog/how-to-track-your-workout](https://setgraph.app/ai-blog/how-to-track-your-workout)  
22. Mobile app UX design: practical guide \- Midrocket, accessed March 26, 2026, [https://midrocket.com/en/guides/mobile-app-ux-design/](https://midrocket.com/en/guides/mobile-app-ux-design/)  
23. UX/UI Best Practices for Modern Mobile App Design | by Carlos Smith \- Medium, accessed March 26, 2026, [https://medium.com/@CarlosSmith24/ux-ui-best-practices-for-modern-mobile-app-design-4d927ba7424a](https://medium.com/@CarlosSmith24/ux-ui-best-practices-for-modern-mobile-app-design-4d927ba7424a)  
24. The Ultimate Guide to UI UX Design for Mobile Apps in 2026, accessed March 26, 2026, [https://www.onething.design/post/ui-ux-design-for-mobile-apps](https://www.onething.design/post/ui-ux-design-for-mobile-apps)  
25. Mobile UX design examples from apps that convert (2025) \- Eleken, accessed March 26, 2026, [https://www.eleken.co/blog-posts/mobile-ux-design-examples](https://www.eleken.co/blog-posts/mobile-ux-design-examples)  
26. Liftin' \- Gym Workout Tracker, accessed March 26, 2026, [https://www.liftinapp.co/](https://www.liftinapp.co/)  
27. Setgraph: Workout Log \- App Store \- Apple, accessed March 26, 2026, [https://apps.apple.com/ng/app/setgraph-workout-log/id1209781676](https://apps.apple.com/ng/app/setgraph-workout-log/id1209781676)  
28. UX Design Patterns for Mobile Apps: Which and Why \- Kodeco, accessed March 26, 2026, [https://www.kodeco.com/404-ux-design-patterns-for-mobile-apps-which-and-why/page/3](https://www.kodeco.com/404-ux-design-patterns-for-mobile-apps-which-and-why/page/3)  
29. Liftin Workout UI Template \- Aura Build, accessed March 26, 2026, [https://www.aura.build/s/fitness-app-workout-82](https://www.aura.build/s/fitness-app-workout-82)  
30. I'm working on this minimalistic workout tracker : r/iosapps \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/iosapps/comments/1rany0v/im\_working\_on\_this\_minimalistic\_workout\_tracker/](https://www.reddit.com/r/iosapps/comments/1rany0v/im_working_on_this_minimalistic_workout_tracker/)  
31. My Solution for Design a Fitness Tracking App with Score: 9/10 \- Codemia, accessed March 26, 2026, [https://codemia.io/system-design/design-a-fitness-tracking-app/solutions/sbhndj/My-Solution-for-Design-a-Fitness-Tracking-App-with-Score-910](https://codemia.io/system-design/design-a-fitness-tracking-app/solutions/sbhndj/My-Solution-for-Design-a-Fitness-Tracking-App-with-Score-910)  
32. How to Build a Database Schema for a Fitness Tracking Application? \- Tutorials \- Back4app, accessed March 26, 2026, [https://www.back4app.com/tutorials/how-to-build-a-database-schema-for-a-fitness-tracking-application](https://www.back4app.com/tutorials/how-to-build-a-database-schema-for-a-fitness-tracking-application)  
33. 20 Practical Training Log Examples (Filled Templates & How to Use Them) \- Setgraph: Workout Tracker App, accessed March 26, 2026, [https://setgraph.app/ai-blog/training-log-examples](https://setgraph.app/ai-blog/training-log-examples)  
34. Build a Gym Workout Tracker App | Mobile App Builder \- Natively, accessed March 26, 2026, [https://natively.dev/use-cases/workout-tracker](https://natively.dev/use-cases/workout-tracker)  
35. 40 Good UX Examples That Actually Work \[+Takeaways\] \- Eleken, accessed March 26, 2026, [https://www.eleken.co/blog-posts/good-ux-examples](https://www.eleken.co/blog-posts/good-ux-examples)  
36. UX Design Examples: The Best Real-World Apps, Patterns, and Lessons \- Riseup Labs, accessed March 26, 2026, [https://riseuplabs.com/ux-design-examples/](https://riseuplabs.com/ux-design-examples/)  
37. I built a minimalist fitness app because I hate wasting time deciding what workout to do : r/SideProject \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/SideProject/comments/1qldobo/i\_built\_a\_minimalist\_fitness\_app\_because\_i\_hate/](https://www.reddit.com/r/SideProject/comments/1qldobo/i_built_a_minimalist_fitness_app_because_i_hate/)  
38. Liftin' \- Gym Workout Tracker \- App Store \- Apple, accessed March 26, 2026, [https://apps.apple.com/us/app/liftin-gym-workout-tracker/id1445041669](https://apps.apple.com/us/app/liftin-gym-workout-tracker/id1445041669)  
39. Best minimalist fitness app? : r/productivity \- Reddit, accessed March 26, 2026, [https://www.reddit.com/r/productivity/comments/zee4om/best\_minimalist\_fitness\_app/](https://www.reddit.com/r/productivity/comments/zee4om/best_minimalist_fitness_app/)

[image1]: <data:image/png;base64,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>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAYCAYAAADzoH0MAAAAvUlEQVR4XmNgGDZAFoiFgZgDiDmBWBBVGgwkoBikDqYWDnKB+AwQ/4fiMmRJKChmQMgvAWIRVGkGhjAGhAJcACS3B10QBsQZ8BvgDsTx6ILoAJ8Bf9AFsAFcBqwFYj50QWwAmwHsQHwATQwngBkAiiYYqAVibSQ+XgAzwBfK3wTETxDShME1BogBHQyQBLUbVZowmM0AMeAIEP9EkyMKgPwLMuAxEN9HkyMKODJgjwmiASsDJMGUoEuMgmENAE8hKs3WMKpFAAAAAElFTkSuQmCC>

[image3]: <data:image/png;base64,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>