//
//  AppCopy.swift
//  Unit
//
//  Central workout + navigation strings. Prefer these over ad-hoc literals in views.
//

import Foundation

enum AppCopy {
    enum Workout {
        static let startWorkout = "Start workout"
        static let continueWorkout = "Continue workout"
        static let completeSet = "Complete set"
        static let finishWorkout = "Finish workout"
        /// Freestyle session without a day template — Programs tab only (not on Today v1).
        static let freestyleSession = "Freestyle session"
        static let nextExercise = "Next exercise"
        /// Shown under the metric when there is no prior set to display — tap opens manual entry.
        static let logMetricHint = "Log"
        /// Adjust-result sheet — label above the optional note field (same row as weight/reps captions).
        static let adjustSetNoteLabel = "Note"
        /// Grey placeholder hinting how the note is used (supersets, equipment, etc.).
        static let adjustSetNotePlaceholder = "Superset curl"
    }

    enum Nav {
        static let close = "Close"
        static let history = "History"
        static let exercises = "Exercises"
        static let logs = "Logs"
    }

    enum Session {
        static let markComplete = "Mark complete"
        static let discard = "Discard"
        static let useName = "Use name"
        static let skipNaming = "Skip"
    }

    /// When there is no prior metric to show (ghost, in-session).
    enum EmptyState {
        /// No completed workouts in the app yet (Today card, lists).
        static let noHistoryYet = "No history yet"
        /// Per-exercise ghost when you've logged other work but not this lift (max 3 words).
        static let noPriorSets = "No prior sets"
        /// Active workout — no sessions completed yet (hint typography, not giant numbers).
        static let loggingColdStart = "Log first set"
        /// Active workout — no prior data for this exercise only (shown in hint chip + Log).
        static let loggingNoPrior = "First time here"
    }

    enum History {
        /// Neutral label for routines scheduled earlier in the week that are still available to do.
        static let earlierThisWeek = "Earlier this week"
    }
}
