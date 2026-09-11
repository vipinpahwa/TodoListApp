//
//  TodoItem.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation
import SwiftData

/// A single to-do entry, persisted locally via SwiftData so the list
/// survives across app launches.
@Model
final class TodoItem {
    var title: String
    var notes: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var dueDate: Date?
    var priority: Priority

    init(
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium
    ) {
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.dueDate = dueDate
        self.priority = priority
    }

    /// `true` when the item has an unmet due date in the past.
    /// Completed items are never considered overdue.
    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < .now
    }
}
