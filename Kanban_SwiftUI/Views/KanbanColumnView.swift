//
//  KanbanColumnView.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//

import SwiftUI
// MARK: - Column View
struct KanbanColumnView: View {
    let column: Column
    let tasks: [Task]
    let users: [User]
    @Binding var draggedTask: Task?
    let onTaskMove: (Task, Column, Int?) -> Void
    let onTaskDelete: (Task) -> Void
    let onTaskEdit: (Task) -> Void
    
    @State private var dropTarget: (id: UUID, edge: Edge)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(column.color)
                    .frame(width: 6, height: 20)
                
                Text(column.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
            // Tasks
            LazyVStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskCardView(
                        task: task,
                        users: users,
                        onDelete: { onTaskDelete(task) },
                        onEdit: { onTaskEdit($0) }
                    )
                    .draggable(task)
                    .dropDestination(for: Task.self) { items, location in
                        guard let draggedTask = items.first, draggedTask.id != task.id else { return false }
                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                            onTaskMove(draggedTask, column, index)
                        }
                        return true
                    } isTargeted: { isTargeted in
                        if isTargeted {
                            dropTarget = (task.id, .top) // Simplified indicator
                        } else if dropTarget?.id == task.id {
                            dropTarget = nil
                        }
                    }
                    .overlay(dropIndicator(for: task))
                }
            }
            
            // Empty space drop zone
            Rectangle()
                .fill(Color.clear)
                .frame(minHeight: 20, maxHeight: .infinity)
                .dropDestination(for: Task.self) { items, location in
                    guard let task = items.first else { return false }
                    if dropTarget == nil {
                        onTaskMove(task, column, nil)
                    }
                    return true
                }
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(width: 300)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func dropIndicator(for task: Task) -> some View {
        if let dropTarget = dropTarget, dropTarget.id == task.id {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 2)
        }
    }
}


