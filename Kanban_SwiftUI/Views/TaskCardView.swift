//
//  TaskCardView.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//

import SwiftUI

// MARK: - Task Card View
struct TaskCardView: View {
    let task: Task
    let users: [User]
    let onDelete: () -> Void
    let onEdit: (Task) -> Void
    @State private var showingDetail = false
    @State private var showingEdit = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    if let dueDate = task.dueDate {
                        HStack {
                            Image(systemName: task.isOverdue ? "clock.badge.exclamationmark" : "clock")
                                .foregroundColor(task.isOverdue ? .red : .secondary)
                            Text(task.dueDateText)
                                .font(.caption)
                                .foregroundColor(task.isOverdue ? .red : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: {
                        showingDetail = true
                    }) {
                        Label("View Details", systemImage: "info.circle")
                    }
                    
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                // Priority Badge
                Text(task.priority.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(task.priority.color)
                    .cornerRadius(6)
                
                Spacer()
                
                // Assigned User
                if let user = task.assignedUser {
                    HStack(spacing: 4) {
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
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task)
        }
        .sheet(isPresented: $showingEdit) {
            AddEditTaskView(
                task: task,
                users: users,
                onSave: { updatedTask in
                    onEdit(updatedTask)
                }
            )
        }
    }
}

