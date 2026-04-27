//
//  WarmupGenerator.swift
//  Unit
//
//  Computes a short warmup ramp from a working weight. Used by the active
//  workout view to render an optional warmup row above working sets.
//

import Foundation

enum WarmupGenerator {
    struct WarmupSet: Hashable, Identifiable {
        var id: Int { index }
        let index: Int
        let weightKg: Double
        let reps: Int
    }

    /// Three-step ramp: 50% × 5, 70% × 3, 85% × 2. Rounded to the nearest
    /// 2.5 kg. Returns nil for bodyweight exercises or very light working sets
    /// (where a warmup adds no value).
    static func warmups(
        forWorkingKg working: Double,
        isBodyweight: Bool
    ) -> [WarmupSet]? {
        if isBodyweight { return nil }
        guard working > 0 else { return nil }

        let scheme: [(percent: Double, reps: Int)] = [
            (0.50, 5),
            (0.70, 3),
            (0.85, 2)
        ]

        let sets = scheme.enumerated().compactMap { index, step -> WarmupSet? in
            let raw = working * step.percent
            let rounded = (raw / 2.5).rounded() * 2.5
            // Skip any warmup that's essentially the empty bar or less.
            guard rounded >= 20 else { return nil }
            // Skip warmups within 5 kg of the working weight (pointless).
            guard working - rounded >= 5 else { return nil }
            return WarmupSet(index: index, weightKg: rounded, reps: step.reps)
        }

        return sets.isEmpty ? nil : sets
    }
}
