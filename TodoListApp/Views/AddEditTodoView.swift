//
//  AddEditTodoView.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI

/// A sheet used both to create a new item and to edit an existing one.
/// Pass `todoToEdit: nil` to create; pass an item to edit it in place.
struct AddEditTodoView: View {
    let todoToEdit: TodoItem?
    let onSave: (_ title: String, _ notes: String, _ dueDate: Date?, _ priority: Priority) -> Bool

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var priority: Priority
    @State private var showsValidationError = false
    @FocusState private var titleFieldIsFocused: Bool

    init(
        todoToEdit: TodoItem? = nil,
        onSave: @escaping (_ title: String, _ notes: String, _ dueDate: Date?, _ priority: Priority) -> Bool
    ) {
        self.todoToEdit = todoToEdit
        self.onSave = onSave
        _title = State(initialValue: todoToEdit?.title ?? "")
        _notes = State(initialValue: todoToEdit?.notes ?? "")
        _hasDueDate = State(initialValue: todoToEdit?.dueDate != nil)
        _dueDate = State(initialValue: todoToEdit?.dueDate ?? .now)
        _priority = State(initialValue: todoToEdit?.priority ?? .medium)
    }

    private var isEditing: Bool { todoToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .focused($titleFieldIsFocused)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { level in
                            Label(level.label, systemImage: level.symbolName)
                                .foregroundStyle(level.color)
                                .tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Due Date") {
                    Toggle("Set a due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                if showsValidationError {
                    Section {
                        Label("Title can't be empty.", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { titleFieldIsFocused = true }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let saved = onSave(title, notes, hasDueDate ? dueDate : nil, priority)
        if saved {
            dismiss()
        } else {
            showsValidationError = true
        }
    }
}

#Preview("Add") {
    AddEditTodoView { _, _, _, _ in true }
}

#Preview("Edit") {
    AddEditTodoView(todoToEdit: TodoItem(title: "Existing task", notes: "Some notes", priority: .high)) { _, _, _, _ in true }
}
