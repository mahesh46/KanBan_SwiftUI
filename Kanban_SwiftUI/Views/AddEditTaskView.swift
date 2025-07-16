//
//  AddEditTaskView.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//

import SwiftUI

// MARK: - Add/Edit Task View
struct AddEditTaskView: View {
    let column: Column?
    let users: [User]
    let onSave: (Task) -> Void
    
    @State private var task: Task
    @State private var title: String
    @State private var description: String
    @State private var priority: Task.Priority
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    @State private var assignedUser: User?
    @Environment(\.dismiss) private var dismiss
    
    private let isEditing: Bool
    
    init(task: Task? = nil, column: Column? = nil, users: [User], onSave: @escaping (Task) -> Void) {
        self.column = column
        self.users = users
        self.onSave = onSave
        self.isEditing = task != nil
        
        if let task = task {
            self.task = task
            self._title = State(initialValue: task.title)
            self._description = State(initialValue: task.description)
            self._priority = State(initialValue: task.priority)
            self._dueDate = State(initialValue: task.dueDate)
            self._hasDueDate = State(initialValue: task.dueDate != nil)
            self._assignedUser = State(initialValue: task.assignedUser)
        } else {
            self.task = Task(title: "", description: "", priority: .medium, createdAt: Date())
            self._title = State(initialValue: "")
            self._description = State(initialValue: "")
            self._priority = State(initialValue: .medium)
            self._dueDate = State(initialValue: nil)
            self._hasDueDate = State(initialValue: false)
            self._assignedUser = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Due Date")) {
                    Toggle("Has Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
                
                Section(header: Text("Assignment")) {
                    Picker("Assigned User", selection: $assignedUser) {
                        Text("Unassigned").tag(nil as User?)
                        ForEach(users) { user in
                            HStack {
                                Circle()
                                    .fill(user.avatarColor)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Text(String(user.name.prefix(1)))
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                Text(user.name)
                            }
                            .tag(user as User?)
                        }
                    }
                }
                
                if !isEditing, let column = column {
                    Section(header: Text("Column")) {
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(column.color)
                                .frame(width: 6, height: 20)
                            Text(column.rawValue)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedTask = task
                        updatedTask.title = title
                        updatedTask.description = description
                        updatedTask.priority = priority
                        updatedTask.dueDate = hasDueDate ? dueDate : nil
                        updatedTask.assignedUser = assignedUser
                        
                        onSave(updatedTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

