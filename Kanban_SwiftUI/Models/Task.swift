//
//  Task.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//

import SwiftUI

struct Task: Identifiable, Codable, Transferable {
    let id: UUID
    var title: String
    var description: String
    var priority: Priority
    var createdAt: Date
    var dueDate: Date?
    var assignedUser: User?

    init(title: String, description: String, priority: Priority, createdAt: Date = Date(), dueDate: Date? = nil, assignedUser: User? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.priority = priority
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.assignedUser = assignedUser
    }

    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date()
    }

    var dueDateText: String {
        guard let dueDate = dueDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: dueDate)
    }

    // MARK: - Transferable Implementation
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .taskType)
    }
}
