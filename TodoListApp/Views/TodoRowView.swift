//
//  TodoRowView.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.isCompleted ? Color.accentColor : Color.secondary)
                    .symbolEffect(.bounce, value: todo.isCompleted)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body.weight(.medium))
                    .strikethrough(todo.isCompleted, color: .secondary)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    Label(todo.priority.label, systemImage: todo.priority.symbolName)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(todo.priority.color)

                    if let dueDate = todo.dueDate {
                        Label {
                            Text(dueDate, format: .dateTime.month(.abbreviated).day())
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(todo.isOverdue ? .red : .secondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: todo.isCompleted)
    }
}

#Preview {
    List {
        TodoRowView(
            todo: TodoItem(title: "Buy groceries", notes: "Milk, eggs, bread", dueDate: .now, priority: .high),
            onToggle: {}
        )
        TodoRowView(
            todo: TodoItem(title: "Finish report", isCompleted: true, priority: .low),
            onToggle: {}
        )
    }
}
