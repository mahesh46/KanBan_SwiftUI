//
//  User.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//

import SwiftUI

struct User: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var email: String
    var avatarColor: Color
    
    init(name: String, email: String, avatarColor: Color = Color.blue) {
        self.name = name
        self.email = email
        self.avatarColor = avatarColor
    }
    
    // Custom coding for Color
    private enum CodingKeys: String, CodingKey {
        case id, name, email, avatarColorHex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        id = UUID(uuidString: idString) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        let colorHex = try container.decode(String.self, forKey: .avatarColorHex)
        avatarColor = Color(hex: colorHex) ?? .blue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(avatarColor.toHex(), forKey: .avatarColorHex)
    }
}

