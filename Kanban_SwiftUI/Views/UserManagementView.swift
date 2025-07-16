//
//  UserManagementView.swift
//  Kanban_SwiftUI
//
//  Created by mahesh lad on 16/07/2025.
//
import SwiftUI
// MARK: - User Management View
struct UserManagementView: View {
    @State private var users: [User]
    let onUsersUpdate: ([User]) -> Void
    
    @State private var showingAddUser = false
    @State private var newUserName = ""
    @State private var newUserEmail = ""
    @State private var newUserColor = Color.blue
    @Environment(\.dismiss) private var dismiss
    
    let availableColors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .teal, .indigo]
    
    init(users: [User], onUsersUpdate: @escaping ([User]) -> Void) {
        self._users = State(initialValue: users)
        self.onUsersUpdate = onUsersUpdate
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(users) { user in
                    HStack {
                        Circle()
                            .fill(user.avatarColor)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(user.name.prefix(1)))
                                    .font(.headline)
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
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteUsers)
            }
            .navigationTitle("Team Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        onUsersUpdate(users)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add User") {
                        showingAddUser = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddUser) {
            NavigationView {
                Form {
                    Section(header: Text("User Details")) {
                        TextField("Name", text: $newUserName)
                        TextField("Email", text: $newUserEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Section(header: Text("Avatar Color")) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(availableColors.indices, id: \.self) { index in
                                Circle()
                                    .fill(availableColors[index])
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: newUserColor == availableColors[index] ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        newUserColor = availableColors[index]
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .navigationTitle("Add User")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddUser = false
                            resetForm()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            let newUser = User(name: newUserName, email: newUserEmail, avatarColor: newUserColor)
                            users.append(newUser)
                            showingAddUser = false
                            resetForm()
                        }
                        .disabled(newUserName.isEmpty || newUserEmail.isEmpty)
                    }
                }
            }
        }
    }
    
    private func deleteUsers(offsets: IndexSet) {
        users.remove(atOffsets: offsets)
    }
    
    private func resetForm() {
        newUserName = ""
        newUserEmail = ""
        newUserColor = Color.blue
    }
}
