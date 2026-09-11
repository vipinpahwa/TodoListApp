//
//  ContentView.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]

    @State private var viewModel = TodoListViewModel()
    @State private var isPresentingAddSheet = false
    @State private var editingTodo: TodoItem?

    private var visibleTodos: [TodoItem] {
        viewModel.filteredAndSorted(todos)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressHeaderView(
                    completedCount: todos.filter(\.isCompleted).count,
                    totalCount: todos.count,
                    progress: viewModel.completionProgress(for: todos)
                )

                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TodoFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)

                if visibleTodos.isEmpty {
                    Spacer()
                    EmptyStateView(filter: viewModel.filter, isSearching: !viewModel.searchText.isEmpty)
                    Spacer()
                } else {
                    List {
                        ForEach(visibleTodos) { todo in
                            TodoRowView(todo: todo) {
                                withAnimation {
                                    viewModel.toggleCompletion(todo)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    withAnimation { viewModel.toggleCompletion(todo) }
                                } label: {
                                    Label(
                                        todo.isCompleted ? "Mark Active" : "Mark Done",
                                        systemImage: todo.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill"
                                    )
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation { viewModel.delete(todo, from: modelContext) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .onTapGesture { editingTodo = todo }
                        }
                        .onDelete(perform: deleteFromVisible)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Tasks")
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(TodoSortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Label("Add Task", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddEditTodoView { title, notes, dueDate, priority in
                    viewModel.addTodo(title: title, notes: notes, dueDate: dueDate, priority: priority, to: modelContext)
                }
            }
            .sheet(item: $editingTodo) { todo in
                AddEditTodoView(todoToEdit: todo) { title, notes, dueDate, priority in
                    viewModel.updateTodo(todo, title: title, notes: notes, dueDate: dueDate, priority: priority)
                }
            }
        }
    }

    private func deleteFromVisible(at offsets: IndexSet) {
        withAnimation {
            viewModel.delete(visibleTodos, at: offsets, from: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
