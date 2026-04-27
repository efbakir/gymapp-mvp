//
//  TodayRoutineOverride.swift
//  Unit
//
//  Optional per-calendar-day pick for which program routine shows on Today.
//

import Foundation

enum TodayRoutineOverride {
    private static let templateKey = "unit.todayRoutineOverride.templateId"
    private static let dayKey = "unit.todayRoutineOverride.dayAnchor"

    /// Returns a stored override only when its day anchor matches today and the template is still in the program.
    static func effectiveTemplateId(orderedTemplateIds: [UUID]) -> UUID? {
        let ud = UserDefaults.standard
        let todayAnchor = dayAnchor(for: Date())
        guard ud.string(forKey: dayKey) == todayAnchor else {
            clearStaleStorage(matchingDay: todayAnchor, ud: ud)
            return nil
        }
        guard let raw = ud.string(forKey: templateKey),
              let id = UUID(uuidString: raw),
              orderedTemplateIds.contains(id) else {
            clear()
            return nil
        }
        return id
    }

    static func set(templateId: UUID) {
        let ud = UserDefaults.standard
        ud.set(templateId.uuidString, forKey: templateKey)
        ud.set(dayAnchor(for: Date()), forKey: dayKey)
    }

    static func clear() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: templateKey)
        ud.removeObject(forKey: dayKey)
    }

    private static func clearStaleStorage(matchingDay todayAnchor: String, ud: UserDefaults) {
        if ud.string(forKey: dayKey) != todayAnchor {
            ud.removeObject(forKey: templateKey)
            ud.removeObject(forKey: dayKey)
        }
    }

    private static func dayAnchor(for date: Date) -> String {
        let c = Calendar.current
        let y = c.component(.year, from: date)
        let m = c.component(.month, from: date)
        let d = c.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}
