# TodoListApp

A SwiftUI to-do list app for iOS with local persistence via SwiftData.

## Features

- Create, edit, complete, and delete tasks
- Each task has a title, optional notes, an optional due date, and a
  priority (Low / Medium / High)
- Filter by **All**, **Active**, or **Completed**, and search by title or notes
- Sort by date created, priority, due date, or title
- Progress ring showing how many tasks are complete
- Overdue tasks are highlighted
- Data persists across app launches (backed by SwiftData / SQLite on device)

## Requirements

- Xcode 16 or later
- iOS 17+ (deployment target currently set to iOS 26.5 in the project)

## Getting Started

1. Open `TodoListApp.xcodeproj` in Xcode.
2. Select the `TodoListApp` scheme and an iOS Simulator (or a connected device).
3. Build and run with `Cmd+R`.

## Running Tests

Run the unit test suite with `Cmd+U` in Xcode, or from the command line:

```bash
xcodebuild -scheme TodoListApp \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

## Project Structure

```
TodoListApp/
├── Models/
│   ├── TodoItem.swift        # SwiftData @Model for a to-do item
│   └── Priority.swift        # Low/Medium/High priority enum
├── Extensions/
│   └── Priority+Presentation.swift  # Color/icon mapping for Priority
├── ViewModels/
│   ├── TodoFilter.swift      # Filter and sort option enums
│   └── TodoListViewModel.swift  # Filtering, search, sorting, and CRUD logic
├── Views/
│   ├── ContentView.swift
│   ├── TodoRowView.swift
│   ├── AddEditTodoView.swift
│   ├── ProgressHeaderView.swift
│   └── EmptyStateView.swift
└── TodoListAppApp.swift      # App entry point, sets up the SwiftData ModelContainer

TodoListAppTests/             # Unit tests (Swift Testing) for models and view model logic
TodoListAppUITests/           # UI tests
```

The business logic (filtering, searching, sorting, validation, and
persistence operations) lives in `TodoListViewModel`, separate from the
SwiftUI views, so it can be unit tested directly against an in-memory
SwiftData `ModelContext` without any UI involved.
