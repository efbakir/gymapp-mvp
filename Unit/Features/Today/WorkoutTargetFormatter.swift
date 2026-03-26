//
//  WorkoutTargetFormatter.swift
//  Unit
//
//  Shared target/result formatting for workout surfaces.
//

import Foundation

enum WorkoutTargetFormatter {

    /// Format a weight value with the user's preferred unit label.
    static func weightDisplay(_ kg: Double) -> String {
        let unit = UserDefaults.standard.string(forKey: "unitSystem") ?? "kg"
        if unit == "lb" {
            let lb = kg * 2.20462
            return "\(lb.weightString)lb"
        }
        return "\(kg.weightString)kg"
    }

    static func setMetricText(
        weightKg: Double,
        reps: Int,
        isBodyweight: Bool,
        bodyweightLabel: String = "Bodyweight"
    ) -> String? {
        guard reps > 0 else { return nil }

        if isBodyweight {
            return "\(bodyweightLabel) × \(reps)"
        }

        guard weightKg > 0 else { return nil }
        return "\(weightDisplay(weightKg)) × \(reps)"
    }

    static func performanceText(
        weightKg: Double,
        setCount: Int,
        reps: Int,
        isBodyweight: Bool,
        bodyweightLabel: String = "BW"
    ) -> String? {
        guard setCount > 0, reps > 0 else { return nil }

        if isBodyweight {
            return "\(setCount) × \(reps) × \(bodyweightLabel)"
        }

        guard weightKg > 0 else { return nil }
        return "\(setCount) × \(reps) × \(weightDisplay(weightKg))"
    }

    static func volumeText(setCount: Int, reps: Int) -> String? {
        guard setCount > 0, reps > 0 else { return nil }
        let setLabel = setCount == 1 ? "set" : "sets"
        let repLabel = reps == 1 ? "rep" : "reps"
        return "\(setCount) \(setLabel) × \(reps) \(repLabel)"
    }

    static func trustedTargetText(weightKg: Double, setCount: Int, reps: Int, isBodyweight: Bool) -> String? {
        performanceText(
            weightKg: weightKg,
            setCount: setCount,
            reps: reps,
            isBodyweight: isBodyweight,
            bodyweightLabel: "Bodyweight"
        )
    }

    static func actualText(weightKg: Double, setCount: Int, reps: Int, isBodyweight: Bool) -> String {
        performanceText(
            weightKg: weightKg,
            setCount: setCount,
            reps: reps,
            isBodyweight: isBodyweight
        ) ?? "\(reps)"
    }

    static func lastText(weightKg: Double, setCount: Int, reps: Int, isBodyweight: Bool) -> String {
        "Last \(actualText(weightKg: weightKg, setCount: setCount, reps: reps, isBodyweight: isBodyweight))"
    }
}
