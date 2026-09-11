//
//  EmptyStateView.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI

struct EmptyStateView: View {
    let filter: TodoFilter
    let isSearching: Bool

    private var symbol: String {
        if isSearching { return "magnifyingglass" }
        switch filter {
        case .all: return "checklist"
        case .active: return "circle.dashed"
        case .completed: return "checkmark.circle"
        }
    }

    private var title: String {
        if isSearching { return "No Matches" }
        switch filter {
        case .all: return "No Tasks Yet"
        case .active: return "All Caught Up"
        case .completed: return "Nothing Completed Yet"
        }
    }

    private var message: String {
        if isSearching { return "Try a different search term." }
        switch filter {
        case .all: return "Tap the + button to add your first task."
        case .active: return "You've completed every task. Nice work!"
        case .completed: return "Finished tasks will show up here."
        }
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: symbol)
        } description: {
            Text(message)
        }
    }
}

#Preview {
    EmptyStateView(filter: .all, isSearching: false)
}
