//
//  KanbanBoardView.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//
import SwiftUI

// MARK: - Kanban Board View
struct KanbanBoardView: View {
    @StateObject private var viewModel = KanbanViewModel()
    @State private var showingAddTask = false
    @State private var selectedColumn: Column = .todo
    @State private var searchText = ""
    @State private var selectedPriority: Task.Priority?
    @State private var selectedUser: User?
    @State private var showOverdueOnly = false
    @State private var showingUserManagement = false
    @State private var draggedTask: Task?

    var filteredTasks: [Column: [Task]] {
        var filtered: [Column: [Task]] = [:]
        
        for column in Column.allCases {
            let tasks = viewModel.tasks[column] ?? []
            filtered[column] = tasks.filter { task in
                // Search filter
                let matchesSearch = searchText.isEmpty ||
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
                
                // Priority filter
                let matchesPriority = selectedPriority == nil || task.priority == selectedPriority
                
                // User filter
                let matchesUser = selectedUser == nil || task.assignedUser?.id == selectedUser?.id
                
                // Overdue filter
                let matchesOverdue = !showOverdueOnly || task.isOverdue
                
                return matchesSearch && matchesPriority && matchesUser && matchesOverdue
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search tasks...", text: $searchText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Priority Filter
                            Menu {
                                Button("All Priorities") {
                                    selectedPriority = nil
                                }
                                ForEach(Task.Priority.allCases, id: \.self) { priority in
                                    Button(action: {
                                        selectedPriority = priority
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(priority.color)
                                                .frame(width: 12, height: 12)
                                            Text(priority.rawValue)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if let priority = selectedPriority {
                                        Circle()
                                            .fill(priority.color)
                                            .frame(width: 12, height: 12)
                                        Text(priority.rawValue)
                                    } else {
                                        Text("Priority")
                                    }
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedPriority != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            }
                            
                            // User Filter
                            Menu {
                                Button("All Users") {
                                    selectedUser = nil
                                }
                                ForEach(viewModel.users) { user in
                                    Button(action: {
                                        selectedUser = user
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(user.avatarColor)
                                                .frame(width: 12, height: 12)
                                            Text(user.name)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if let user = selectedUser {
                                        Circle()
                                            .fill(user.avatarColor)
                                            .frame(width: 12, height: 12)
                                        Text(user.name)
                                    } else {
                                        Text("Assignee")
                                    }
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedUser != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            }
                            
                            // Overdue Filter
                            Button(action: {
                                showOverdueOnly.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "clock.badge.exclamationmark")
                                    Text("Overdue")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(showOverdueOnly ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            }
                            .foregroundColor(showOverdueOnly ? .red : .primary)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                
                // Kanban Board
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(Column.allCases, id: \.self) { column in
                            KanbanColumnView(
                                column: column,
                                tasks: filteredTasks[column] ?? [],
                                users: viewModel.users,
                                draggedTask: $draggedTask,
                                onTaskMove: { task, newColumn, index in
                                    viewModel.moveTask(task, to: newColumn, at: index)
                                },
                                onTaskDelete: { task in
                                    viewModel.deleteTask(task)
                                },
                                onTaskEdit: { task in
                                    viewModel.updateTask(task)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Kanban Board")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingUserManagement = true
                    }) {
                        Image(systemName: "person.2")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(Column.allCases, id: \.self) { column in
                            Button(action: {
                                selectedColumn = column
                                showingAddTask = true
                            }) {
                                Label("Add to \(column.rawValue)", systemImage: "plus")
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddEditTaskView(
                column: selectedColumn,
                users: viewModel.users,
                onSave: { task in
                    viewModel.addTask(task, to: selectedColumn)
                }
            )
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView(
                users: viewModel.users,
                onUsersUpdate: { users in
                    viewModel.updateUsers(users)
                }
            )
        }
    }
}
