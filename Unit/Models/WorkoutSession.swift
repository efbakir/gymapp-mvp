//
//  WorkoutSession.swift
//  Unit
//
//  SwiftData model: one instance of a template performed on a date.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var templateId: UUID
    var isCompleted: Bool = false

    @Relationship(deleteRule: .cascade)
    var setEntries: [SetEntry] = []

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        templateId: UUID,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.date = date
        self.templateId = templateId
        self.isCompleted = isCompleted
    }
}
