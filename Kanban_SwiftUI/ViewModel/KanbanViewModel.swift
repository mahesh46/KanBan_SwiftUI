//
//  KanbanViewModel.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 15/07/2025.
//

import SwiftUI

// MARK: - Kanban View Model
class KanbanViewModel: ObservableObject {
    @Published var tasks: [Column: [Task]] = [:]
    @Published var users: [User] = []
    
    private let tasksKey = "kanban_tasks"
    private let usersKey = "kanban_users"
    
    init() {
        loadData()
    }
    
    // MARK: - Data Persistence
    func saveData() {
        do {
            let tasksData = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(tasksData, forKey: tasksKey)
            
            let usersData = try JSONEncoder().encode(users)
            UserDefaults.standard.set(usersData, forKey: usersKey)
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    func loadData() {
        // Load Tasks
        if let tasksData = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasks = try JSONDecoder().decode([Column: [Task]].self, from: tasksData)
            } catch {
                print("Error loading tasks: \(error.localizedDescription)")
                setupDefaultTasks()
            }
        } else {
            setupDefaultTasks()
        }
        
        // Load Users
        if let usersData = UserDefaults.standard.data(forKey: usersKey) {
            do {
                users = try JSONDecoder().decode([User].self, from: usersData)
            } catch {
                print("Error loading users: \(error.localizedDescription)")
                setupDefaultUsers()
            }
        } else {
            setupDefaultUsers()
        }
    }
    
    // MARK: - Task Management
    func addTask(_ task: Task, to column: Column) {
        tasks[column, default: []].append(task)
        saveData()
    }
    
    func moveTask(_ task: Task, to newColumn: Column, at index: Int? = nil) {
        var sourceColumn: Column?
        var sourceIndex: Int?

        // Find the task's current location
        for (col, tasksInCol) in tasks {
            if let idx = tasksInCol.firstIndex(where: { $0.id == task.id }) {
                sourceColumn = col
                sourceIndex = idx
                break
            }
        }

        guard let srcCol = sourceColumn, let srcIndex = sourceIndex else { return }

        // Remove the task from its original position
        let removedTask = tasks[srcCol]!.remove(at: srcIndex)

        // Determine the insertion index
        var finalIndex = index

        // If dropping into the same column, adjust the index if the source was before the destination
        if srcCol == newColumn, let toIndex = finalIndex, srcIndex < toIndex {
            finalIndex = toIndex - 1
        }

        // Insert the task into the new position
        if let idx = finalIndex, idx <= tasks[newColumn, default: []].count {
            tasks[newColumn, default: []].insert(removedTask, at: idx)
        } else {
            // If index is nil or out of bounds, append to the end
            tasks[newColumn, default: []].append(removedTask)
        }

        saveData()
    }
    
    func deleteTask(_ task: Task) {
        for (column, tasksInColumn) in tasks {
            if let index = tasksInColumn.firstIndex(where: { $0.id == task.id }) {
                tasks[column]?.remove(at: index)
                saveData()
                return
            }
        }
    }
    
    func updateTask(_ task: Task) {
        for (column, tasksInColumn) in tasks {
            if let index = tasksInColumn.firstIndex(where: { $0.id == task.id }) {
                tasks[column]?[index] = task
                saveData()
                return
            }
        }
    }
    
    // MARK: - User Management
    func updateUsers(_ updatedUsers: [User]) {
        self.users = updatedUsers
        saveData()
    }
    
    // MARK: - Default Data
    private func setupDefaultUsers() {
        users = [
            User(name: "Alice", email: "alice@example.com", avatarColor: .blue),
            User(name: "Bob", email: "bob@example.com", avatarColor: .green),
            User(name: "Charlie", email: "charlie@example.com", avatarColor: .orange)
        ]
    }
    
    private func setupDefaultTasks() {
        let user1 = users.first
        let user2 = users.dropFirst().first
        
        tasks = [
            .todo: [
                Task(title: "Design new logo", description: "Create a modern and fresh logo for the company.", priority: .high, createdAt: Date(), dueDate: Date().addingTimeInterval(86400 * 3), assignedUser: user1),
                Task(title: "Develop user authentication", description: "Implement email/password and social login.", priority: .high, createdAt: Date(), dueDate: Date().addingTimeInterval(86400 * 5)),
                Task(title: "Plan marketing campaign", description: "Outline the strategy for the upcoming product launch.", priority: .medium, createdAt: Date())
            ],
            .inProgress: [
                Task(title: "Build settings screen", description: "Add options for notifications and theme.", priority: .medium, createdAt: Date(), assignedUser: user2),
                Task(title: "Fix API bug", description: "Resolve the issue with the user data endpoint.", priority: .high, createdAt: Date(), dueDate: Date().addingTimeInterval(86400 * 1))
            ],
            .done: [
                Task(title: "Setup project repository", description: "Initialize Git and push to GitHub.", priority: .low, createdAt: Date(), dueDate: Date().addingTimeInterval(-86400 * 2), assignedUser: user1)
            ]
        ]
    }
}
