# TodoListApp Specification

## Goal

Provide a native iOS to-do list app that lets a single user capture, organize,
and track personal tasks on-device. A task carries a title, optional notes,
an optional due date, and a priority. The user can filter, search, and sort
their task list, mark tasks complete, and see overall progress at a glance.
All data persists locally across app launches with no server or account
required.

## Constraints

- **Platform**: iOS only, built with SwiftUI and SwiftData. Deployment
  target iOS 17+ (project currently configured for iOS 26.5).
- **Toolchain**: Xcode 16 or later.
- **Persistence**: On-device only, via SwiftData (SQLite-backed). No network
  calls, no remote sync, no third-party backend.
- **Architecture**: Business logic (filtering, searching, sorting,
  validation, CRUD) must live in `TodoListViewModel`, independent of any
  SwiftUI `View`, so it is unit-testable against an in-memory
  `ModelContext` without standing up UI.
- **Single user, single device**: no multi-user accounts, no collaboration,
  no cross-device sync.
- **No comments/attachments/subtasks**: a task is limited to title, notes,
  due date, priority, completion state, and timestamps — no richer item
  types.

## Inputs and Outputs

### Inputs

- **Title** (`String`, required): free text; leading/trailing whitespace is
  trimmed; empty or whitespace-only titles are rejected.
- **Notes** (`String`, optional): free text, trimmed; defaults to empty.
- **Due date** (`Date?`, optional): toggled on/off in the add/edit form;
  includes date and time when set.
- **Priority** (`Priority`, required): one of `.low`, `.medium`, `.high`;
  defaults to `.medium`.
- **Filter selection** (`TodoFilter`): `.all`, `.active`, or `.completed`.
- **Sort selection** (`TodoSortOption`): `.dateCreated`, `.priority`,
  `.dueDate`, or `.alphabetical`.
- **Search text** (`String`): matched case-insensitively against title and
  notes.
- **Completion toggle**: user action marking a task complete/incomplete.
- **Delete action**: user action removing one or more tasks.

### Outputs

- **Task list view**: the filtered, searched, and sorted set of
  `TodoItem`s rendered as rows, each showing title, priority, due date (with
  overdue tasks visually highlighted), and completion state.
- **Progress indicator**: a ring/header showing the fraction of tasks
  completed (`completedCount / totalCount`, `0` when the list is empty).
- **Persisted store**: a SwiftData/SQLite database on device containing all
  `TodoItem` records, surviving app relaunches.
- **Empty state view**: shown when the current filter/search yields no
  tasks.

## Acceptance Criteria

1. **Create**: Submitting the add form with a non-empty title creates a new
   task with `createdAt = now`, `isCompleted = false`, and the entered
   notes/due date/priority; the form dismisses. Submitting with an empty or
   whitespace-only title does not create a task and shows a validation
   error instead.
2. **Edit**: Submitting the edit form with a non-empty title updates the
   existing task's title, notes, due date, and priority in place, leaving
   `createdAt` and completion state untouched; an empty title is rejected
   the same way as on create.
3. **Complete/incomplete toggle**: Toggling a task sets `isCompleted` and
   stamps `completedAt = now` when completed, or clears `completedAt` to
   `nil` when un-completed.
4. **Delete**: Deleting a task (single item or via row offsets) removes it
   from the store; it no longer appears in any filter/search result.
5. **Filtering**: `.all` shows every task; `.active` shows only
   `!isCompleted`; `.completed` shows only `isCompleted`.
6. **Search**: A non-empty, trimmed search query filters tasks to those
   whose title or notes contain the query, case-insensitively; an
   empty/whitespace query applies no filtering.
7. **Sorting**:
   - `.dateCreated` — newest first.
   - `.priority` — highest priority first; ties broken by newest first.
   - `.dueDate` — earliest due date first; tasks without a due date sort
     after all tasks with a due date, and among themselves sort newest
     first.
   - `.alphabetical` — by title, case-insensitive ascending.
8. **Overdue detection**: A task is overdue only when it has a due date in
   the past and is not completed; completed tasks are never overdue.
9. **Progress calculation**: Progress equals the count of completed tasks
   divided by total task count, and is `0` for an empty list.
10. **Persistence**: Tasks created, edited, completed, or deleted persist
    across an app relaunch (backed by the on-device SwiftData store).
11. **Testability**: All rules above are covered by unit tests running
    against an in-memory `ModelContext`, independent of the UI layer.

## Output Files

- `TodoListApp/Models/TodoItem.swift` — SwiftData `@Model` for a to-do item.
- `TodoListApp/Models/Priority.swift` — priority enum (Low/Medium/High).
- `TodoListApp/Extensions/Priority+Presentation.swift` — color/icon mapping
  for `Priority`.
- `TodoListApp/ViewModels/TodoFilter.swift` — filter and sort option enums.
- `TodoListApp/ViewModels/TodoListViewModel.swift` — filtering, search,
  sorting, and CRUD logic.
- `TodoListApp/Views/ContentView.swift` — main list screen.
- `TodoListApp/Views/TodoRowView.swift` — single task row.
- `TodoListApp/Views/AddEditTodoView.swift` — create/edit form sheet.
- `TodoListApp/Views/ProgressHeaderView.swift` — completion progress ring.
- `TodoListApp/Views/EmptyStateView.swift` — empty-state placeholder.
- `TodoListApp/TodoListAppApp.swift` — app entry point, SwiftData
  `ModelContainer` setup.
- `TodoListAppTests/` — unit tests (Swift Testing) for models and view
  model logic (`TodoItemTests.swift`, `PriorityTests.swift`,
  `TodoListViewModelTests.swift`, `TestSupport.swift`).
- `TodoListAppUITests/` — UI test target
  (`TodoListAppUITests.swift`, `TodoListAppUITestsLaunchTests.swift`).
