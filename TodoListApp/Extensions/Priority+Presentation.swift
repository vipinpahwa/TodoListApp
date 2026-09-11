//
//  Priority+Presentation.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI

/// UI-facing presentation details for `Priority`, kept separate from the
/// core model so `Models/Priority.swift` has no SwiftUI dependency.
extension Priority {
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }

    var symbolName: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .medium: return "equal.circle.fill"
        case .high: return "arrow.up.circle.fill"
        }
    }
}
