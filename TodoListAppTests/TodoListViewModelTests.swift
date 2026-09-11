//
//  TodoListViewModelTests.swift
//  TodoListAppTests
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation
import SwiftData
import Testing
@testable import TodoListApp

@MainActor
struct TodoListViewModelTests {

    // MARK: - Filtering

    @Test func allFilterReturnsEveryItem() {
        let viewModel = TodoListViewModel()
        let todos = [
            TodoItem(title: "Active one"),
            TodoItem(title: "Done one", isCompleted: true),
        ]

        viewModel.filter = .all
        #expect(viewModel.filteredAndSorted(todos).count == 2)
    }

    @Test func activeFilterExcludesCompletedItems() {
        let viewModel = TodoListViewModel()
        let active = TodoItem(title: "Active one")
        let done = TodoItem(title: "Done one", isCompleted: true)

        viewModel.filter = .active
        let result = viewModel.filteredAndSorted([active, done])

        #expect(result == [active])
    }

    @Test func completedFilterExcludesActiveItems() {
        let viewModel = TodoListViewModel()
        let active = TodoItem(title: "Active one")
        let done = TodoItem(title: "Done one", isCompleted: true)

        viewModel.filter = .completed
        let result = viewModel.filteredAndSorted([active, done])

        #expect(result == [done])
    }

    // MARK: - Search

    @Test func searchTextMatchesTitleCaseInsensitively() {
        let viewModel = TodoListViewModel()
        let groceries = TodoItem(title: "Buy Groceries")
        let laundry = TodoItem(title: "Do laundry")

        viewModel.searchText = "grocer"
        let result = viewModel.filteredAndSorted([groceries, laundry])

        #expect(result == [groceries])
    }

    @Test func searchTextMatchesNotesToo() {
        let viewModel = TodoListViewModel()
        let itemWithMatchingNotes = TodoItem(title: "Task", notes: "Remember the milk")
        let other = TodoItem(title: "Other task", notes: "Nothing relevant")

        viewModel.searchText = "milk"
        let result = viewModel.filteredAndSorted([itemWithMatchingNotes, other])

        #expect(result == [itemWithMatchingNotes])
    }

    @Test func blankSearchTextDoesNotFilterAnything() {
        let viewModel = TodoListViewModel()
        let todos = [TodoItem(title: "One"), TodoItem(title: "Two")]

        viewModel.searchText = "   "
        #expect(viewModel.filteredAndSorted(todos).count == 2)
    }

    // MARK: - Sorting

    @Test func sortByAlphabeticalOrdersTitlesAscending() {
        let viewModel = TodoListViewModel()
        let banana = TodoItem(title: "Banana")
        let apple = TodoItem(title: "apple")
        let cherry = TodoItem(title: "Cherry")

        viewModel.sortOption = .alphabetical
        let result = viewModel.filteredAndSorted([banana, apple, cherry])

        #expect(result == [apple, banana, cherry])
    }

    @Test func sortByPriorityOrdersHighestFirst() {
        let viewModel = TodoListViewModel()
        let low = TodoItem(title: "Low", priority: .low)
        let high = TodoItem(title: "High", priority: .high)
        let medium = TodoItem(title: "Medium", priority: .medium)

        viewModel.sortOption = .priority
        let result = viewModel.filteredAndSorted([low, high, medium])

        #expect(result == [high, medium, low])
    }

    @Test func sortByDueDatePlacesSoonestFirstAndNilDatesLast() {
        let viewModel = TodoListViewModel()
        let soon = TodoItem(title: "Soon", dueDate: .now.addingTimeInterval(60))
        let later = TodoItem(title: "Later", dueDate: .now.addingTimeInterval(3600))
        let noDate = TodoItem(title: "No date")

        viewModel.sortOption = .dueDate
        let result = viewModel.filteredAndSorted([later, noDate, soon])

        #expect(result == [soon, later, noDate])
    }

    @Test func sortByDateCreatedOrdersNewestFirst() {
        let viewModel = TodoListViewModel()
        let older = TodoItem(title: "Older", createdAt: .now.addingTimeInterval(-100))
        let newer = TodoItem(title: "Newer", createdAt: .now)

        viewModel.sortOption = .dateCreated
        let result = viewModel.filteredAndSorted([older, newer])

        #expect(result == [newer, older])
    }

    // MARK: - Progress

    @Test func completionProgressIsZeroForEmptyList() {
        let viewModel = TodoListViewModel()
        #expect(viewModel.completionProgress(for: []) == 0)
    }

    @Test func completionProgressReflectsFractionCompleted() {
        let viewModel = TodoListViewModel()
        let todos = [
            TodoItem(title: "One", isCompleted: true),
            TodoItem(title: "Two", isCompleted: true),
            TodoItem(title: "Three"),
            TodoItem(title: "Four"),
        ]

        #expect(viewModel.completionProgress(for: todos) == 0.5)
    }

    // MARK: - Toggling completion

    @Test func togglingCompletionFlipsFlagAndStampsCompletedAt() {
        let viewModel = TodoListViewModel()
        let todo = TodoItem(title: "Task")

        viewModel.toggleCompletion(todo)
        #expect(todo.isCompleted == true)
        #expect(todo.completedAt != nil)

        viewModel.toggleCompletion(todo)
        #expect(todo.isCompleted == false)
        #expect(todo.completedAt == nil)
    }

    // MARK: - Adding

    @Test func addingWithValidTitleInsertsItemIntoContext() throws {
        let viewModel = TodoListViewModel()
        let context = try makeInMemoryContext()

        let didAdd = viewModel.addTodo(title: "New task", notes: "Some notes", priority: .high, to: context)

        #expect(didAdd == true)
        let inserted = try context.fetch(FetchDescriptor<TodoItem>())
        #expect(inserted.count == 1)
        #expect(inserted.first?.title == "New task")
        #expect(inserted.first?.priority == .high)
    }

    @Test func addingTrimsWhitespaceFromTitleAndNotes() throws {
        let viewModel = TodoListViewModel()
        let context = try makeInMemoryContext()

        viewModel.addTodo(title: "  Padded title  ", notes: "  Padded notes  ", to: context)

        let inserted = try context.fetch(FetchDescriptor<TodoItem>())
        #expect(inserted.first?.title == "Padded title")
        #expect(inserted.first?.notes == "Padded notes")
    }

    @Test func addingWithEmptyTitleFailsAndInsertsNothing() throws {
        let viewModel = TodoListViewModel()
        let context = try makeInMemoryContext()

        let didAdd = viewModel.addTodo(title: "   ", to: context)

        #expect(didAdd == false)
        let inserted = try context.fetch(FetchDescriptor<TodoItem>())
        #expect(inserted.isEmpty)
    }

    // MARK: - Updating

    @Test func updatingWithValidTitleAppliesAllFields() {
        let viewModel = TodoListViewModel()
        let todo = TodoItem(title: "Old title", notes: "Old notes", priority: .low)
        let newDueDate = Date.now.addingTimeInterval(3600)

        let didUpdate = viewModel.updateTodo(
            todo,
            title: "New title",
            notes: "New notes",
            dueDate: newDueDate,
            priority: .high
        )

        #expect(didUpdate == true)
        #expect(todo.title == "New title")
        #expect(todo.notes == "New notes")
        #expect(todo.dueDate == newDueDate)
        #expect(todo.priority == .high)
    }

    @Test func updatingWithEmptyTitleFailsAndLeavesItemUnchanged() {
        let viewModel = TodoListViewModel()
        let todo = TodoItem(title: "Original", notes: "Original notes", priority: .medium)

        let didUpdate = viewModel.updateTodo(todo, title: "  ", notes: "changed", dueDate: nil, priority: .high)

        #expect(didUpdate == false)
        #expect(todo.title == "Original")
        #expect(todo.notes == "Original notes")
        #expect(todo.priority == .medium)
    }

    // MARK: - Deleting

    @Test func deletingByOffsetsRemovesOnlyTargetedItems() throws {
        let viewModel = TodoListViewModel()
        let context = try makeInMemoryContext()
        let keep = TodoItem(title: "Keep me")
        let remove = TodoItem(title: "Remove me")
        context.insert(keep)
        context.insert(remove)

        viewModel.delete([keep, remove], at: IndexSet(integer: 1), from: context)

        let remaining = try context.fetch(FetchDescriptor<TodoItem>())
        #expect(remaining == [keep])
    }

    @Test func deletingSingleItemRemovesItFromContext() throws {
        let viewModel = TodoListViewModel()
        let context = try makeInMemoryContext()
        let todo = TodoItem(title: "To delete")
        context.insert(todo)

        viewModel.delete(todo, from: context)

        let remaining = try context.fetch(FetchDescriptor<TodoItem>())
        #expect(remaining.isEmpty)
    }
}
