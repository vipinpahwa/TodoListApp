//
//  TodoFilter.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation

enum TodoFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    var id: String { rawValue }
}

enum TodoSortOption: String, CaseIterable, Identifiable {
    case dateCreated = "Date Created"
    case priority = "Priority"
    case dueDate = "Due Date"
    case alphabetical = "Alphabetical"

    var id: String { rawValue }
}
