//
//  TodoItemTests.swift
//  TodoListAppTests
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation
import Testing
@testable import TodoListApp

struct TodoItemTests {

    @Test func newItemDefaultsToIncompleteWithMediumPriorityAndNoDueDate() {
        let item = TodoItem(title: "Write tests")

        #expect(item.title == "Write tests")
        #expect(item.notes == "")
        #expect(item.isCompleted == false)
        #expect(item.completedAt == nil)
        #expect(item.dueDate == nil)
        #expect(item.priority == .medium)
    }

    @Test func itemWithPastDueDateAndNotCompletedIsOverdue() {
        let pastDate = Date.now.addingTimeInterval(-3600)
        let item = TodoItem(title: "Overdue task", dueDate: pastDate)

        #expect(item.isOverdue == true)
    }

    @Test func itemWithFutureDueDateIsNotOverdue() {
        let futureDate = Date.now.addingTimeInterval(3600)
        let item = TodoItem(title: "Upcoming task", dueDate: futureDate)

        #expect(item.isOverdue == false)
    }

    @Test func completedItemWithPastDueDateIsNotOverdue() {
        let pastDate = Date.now.addingTimeInterval(-3600)
        let item = TodoItem(title: "Finished task", isCompleted: true, dueDate: pastDate)

        #expect(item.isOverdue == false)
    }

    @Test func itemWithoutDueDateIsNeverOverdue() {
        let item = TodoItem(title: "No deadline")

        #expect(item.isOverdue == false)
    }
}
