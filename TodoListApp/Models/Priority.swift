//
//  Priority.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation

/// The urgency of a to-do item, persisted as part of `TodoItem`.
///
/// Kept free of any UI dependency (no `SwiftUI` import) so the core model
/// stays lightweight and trivially testable. Presentation details such as
/// color and symbol live in `Priority+Presentation.swift`.
enum Priority: Int, Codable, CaseIterable, Identifiable, Comparable {
    case low = 0
    case medium = 1
    case high = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
