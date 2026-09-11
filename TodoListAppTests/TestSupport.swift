//
//  TestSupport.swift
//  TodoListAppTests
//
//  Created by Vipin Pahwa on 11/09/26.
//

import Foundation
import SwiftData
@testable import TodoListApp

/// Creates a fresh, in-memory `ModelContext` so persistence-touching logic
/// can be unit tested without writing to disk or leaking state between tests.
@MainActor
func makeInMemoryContext() throws -> ModelContext {
    let schema = Schema([TodoItem.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    return ModelContext(container)
}
