//
//  TaskDetailView.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//

import SwiftUI

// MARK: - Task Detail View
struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Description
                    if !task.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            Text(task.description)
                                .font(.body)
                        }
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.headline)
                        HStack {
                            Circle()
                                .fill(task.priority.color)
                                .frame(width: 16, height: 16)
                            Text(task.priority.rawValue)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Due Date
                    if let dueDate = task.dueDate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.headline)
                            HStack {
                                Image(systemName: task.isOverdue ? "clock.badge.exclamationmark" : "clock")
                                    .foregroundColor(task.isOverdue ? .red : .primary)
                                Text(task.dueDateText)
                                    .font(.body)
                                    .foregroundColor(task.isOverdue ? .red : .primary)
                                if task.isOverdue {
                                    Text("(Overdue)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    // Assigned User
                    if let user = task.assignedUser {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assigned To")
                                .font(.headline)
                            HStack {
                                Circle()
                                    .fill(user.avatarColor)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(String(user.name.prefix(1)))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .fontWeight(.medium)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Created Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Created")
                            .font(.headline)
                        Text(task.createdAt, style: .date)
                            .font(.body)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
