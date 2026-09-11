//
//  TodoListViewModel.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation
import Observation
import SwiftData

/// Holds the list's transient UI state (filter/sort/search) and the pure
/// business logic for deriving what to display and for mutating items.
///
/// Kept independent of any specific `View`, so every rule here can be
/// exercised directly from unit tests without standing up SwiftUI.
@Observable
final class TodoListViewModel {
    var filter: TodoFilter = .all
    var sortOption: TodoSortOption = .dateCreated
    var searchText: String = ""

    /// Applies the current filter, search text, and sort option to a list
    /// of items. Pure function of its inputs (plus the receiver's
    /// currently-selected options) so it is trivial to unit test.
    func filteredAndSorted(_ todos: [TodoItem]) -> [TodoItem] {
        var result = todos

        switch filter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            let query = trimmedQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) || $0.notes.lowercased().contains(query)
            }
        }

        switch sortOption {
        case .dateCreated:
            result.sort { $0.createdAt > $1.createdAt }
        case .priority:
            result.sort {
                $0.priority == $1.priority ? $0.createdAt > $1.createdAt : $0.priority > $1.priority
            }
        case .dueDate:
            result.sort { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (left?, right?):
                    return left < right
                case (nil, nil):
                    return lhs.createdAt > rhs.createdAt
                case (nil, _):
                    return false
                case (_, nil):
                    return true
                }
            }
        case .alphabetical:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return result
    }

    /// Fraction of `todos` that are completed, in `0...1`. `0` for an empty list.
    func completionProgress(for todos: [TodoItem]) -> Double {
        guard !todos.isEmpty else { return 0 }
        let completedCount = todos.filter(\.isCompleted).count
        return Double(completedCount) / Double(todos.count)
    }

    func toggleCompletion(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? .now : nil
    }

    /// Validates and inserts a new item. Returns `false` (without mutating
    /// anything) when the title is empty or only whitespace.
    @discardableResult
    func addTodo(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: Priority = .medium,
        to context: ModelContext
    ) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = TodoItem(title: trimmedTitle, notes: trimmedNotes, dueDate: dueDate, priority: priority)
        context.insert(item)
        return true
    }

    /// Validates and applies edits to an existing item in place. Returns
    /// `false` (without mutating anything) when the title is empty.
    @discardableResult
    func updateTodo(
        _ todo: TodoItem,
        title: String,
        notes: String,
        dueDate: Date?,
        priority: Priority
    ) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        todo.title = trimmedTitle
        todo.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        todo.dueDate = dueDate
        todo.priority = priority
        return true
    }

    func delete(_ todos: [TodoItem], at offsets: IndexSet, from context: ModelContext) {
        for index in offsets {
            context.delete(todos[index])
        }
    }

    func delete(_ todo: TodoItem, from context: ModelContext) {
        context.delete(todo)
    }
}
