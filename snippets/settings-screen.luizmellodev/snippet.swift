import SwiftUI

struct ModernSettingsView: View, ViewTemplate {
    let id = "modernsettings"
    let name = "Modern Settings"
    
    var view: AnyView {
        AnyView(self)
    }
    
  var body: some View {
      NavigationView {
          ScrollView {
              VStack(spacing: 24) {
                  // Profile section
                  HStack(spacing: 16) {
                      Circle()
                          .fill(Color.blue.opacity(0.1))
                          .frame(width: 64, height: 64)
                          .overlay(
                              Circle()
                                  .fill(Color.blue)
                                  .frame(width: 32, height: 32)
                          )
                      
                      VStack(alignment: .leading, spacing: 4) {
                          Text("Alex Johnson")
                              .fontWeight(.bold)
                          
                          Text("alex@example.com")
                              .font(.caption)
                              .foregroundColor(.secondary)
                          
                          Button(action: {
                              // Edit profile action
                          }) {
                              Text("Edit Profile")
                                  .font(.caption)
                                  .fontWeight(.medium)
                                  .foregroundColor(.blue)
                          }
                      }
                      
                      Spacer()
                  }
                  .padding(.horizontal)
                  
                  // Account section
                  VStack(alignment: .leading, spacing: 8) {
                      Text("ACCOUNT")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                      
                      VStack(spacing: 0) {
                          SettingsRow(title: "Personal Information")
                          SettingsRow(title: "Password")
                          SettingsRow(title: "Notifications")
                          SettingsRow(title: "Privacy", isLast: true)
                      }
                      .background(Color(.systemBackground))
                      .cornerRadius(16)
                      .padding(.horizontal)
                  }
                  
                  // Preferences section
                  VStack(alignment: .leading, spacing: 8) {
                      Text("PREFERENCES")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                      
                      VStack(spacing: 0) {
                          SettingsRow(title: "Appearance")
                          SettingsRow(title: "Language")
                          SettingsRow(title: "Accessibility", isLast: true)
                      }
                      .background(Color(.systemBackground))
                      .cornerRadius(16)
                      .padding(.horizontal)
                  }
                  
                  // About section
                  VStack(alignment: .leading, spacing: 8) {
                      Text("ABOUT")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.secondary)
                          .padding(.horizontal)
                      
                      VStack(spacing: 0) {
                          SettingsRow(title: "Help Center")
                          SettingsRow(title: "Terms of Service")
                          SettingsRow(title: "Privacy Policy")
                          SettingsRow(title: "App Version", isLast: true) {
                              Text("1.0.0")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                          }
                      }
                      .background(Color(.systemBackground))
                      .cornerRadius(16)
                      .padding(.horizontal)
                  }
                  
                  // Sign out button
                  Button(action: {
                      // Sign out action
                  }) {
                      Text("Sign Out")
                          .fontWeight(.medium)
                          .foregroundColor(.red)
                          .frame(maxWidth: .infinity)
                          .padding()
                          .background(Color(.systemBackground))
                          .cornerRadius(16)
                  }
                  .padding(.horizontal)
                  .padding(.top, 8)
              }
              .padding(.vertical)
          }
          .background(Color(.systemGroupedBackground))
          .navigationTitle("Settings")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                  Button(action: {
                      // Close action
                  }) {
                      Image(systemName: "xmark")
                          .padding(8)
                          .background(Color(.systemGray5))
                          .clipShape(Circle())
                  }
              }
          }
      }
  }
}

struct SettingsRow<Trailing: View>: View {
  var title: String
  var isLast: Bool = false
  var trailing: Trailing
  
  init(title: String, isLast: Bool = false, @ViewBuilder trailing: @escaping () -> Trailing = { Image(systemName: "chevron.right").foregroundColor(.secondary) }) {
      self.title = title
      self.isLast = isLast
      self.trailing = trailing()
  }
  
  var body: some View {
      HStack {
          Text(title)
              .font(.subheadline)
          
          Spacer()
          
          trailing
      }
      .padding()
      .background(Color(.systemBackground))
      .overlay(
          !isLast ?
              Divider()
                  .padding(.leading)
                  .opacity(0.5)
              : nil,
          alignment: .bottom
      )
  }
}