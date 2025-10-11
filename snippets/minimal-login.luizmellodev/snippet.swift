import SwiftUI

struct MinimalLoginView: View, ViewTemplate {
    let id = "minimal_login"
    let name = "Minimal Login"
    
    var view: AnyView {
        AnyView(self)
    }
    
  @State private var email: String = ""
  @State private var password: String = ""
  
  var body: some View {
      VStack(spacing: 32) {
          // Logo and header
          VStack(spacing: 8) {
              Circle()
                  .fill(Color.blue.opacity(0.1))
                  .frame(width: 80, height: 80)
                  .overlay(
                      Circle()
                          .fill(Color.blue)
                          .frame(width: 40, height: 40)
                  )
              
              Text("Sign In")
                  .font(.title2)
                  .fontWeight(.bold)
              
              Text("Access your account")
                  .font(.caption)
                  .foregroundColor(.secondary)
          }
          
          // Form fields
          VStack(spacing: 24) {
              VStack(alignment: .leading, spacing: 8) {
                  TextField("Email", text: $email)
                      .autocapitalization(.none)
                      .keyboardType(.emailAddress)
                      .padding(.vertical, 8)
                  
                  Divider()
              }
              
              VStack(alignment: .leading, spacing: 8) {
                  SecureField("Password", text: $password)
                      .padding(.vertical, 8)
                  
                  Divider()
              }
              
              HStack {
                  Spacer()
                  Button(action: {
                      // Handle forgot password
                  }) {
                      Text("Forgot Password?")
                          .font(.caption)
                          .fontWeight(.medium)
                          .foregroundColor(.blue)
                  }
              }
          }
          
          // Sign in button
          Button(action: {
              // Handle sign in
          }) {
              Text("Sign In")
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(16)
          }
          .padding(.top, 16)
          
          // Create account prompt
          HStack(spacing: 4) {
              Text("New user?")
                  .font(.caption)
              
              Button(action: {
                  // Handle create account navigation
              }) {
                  Text("Create Account")
                      .font(.caption)
                      .fontWeight(.medium)
                      .foregroundColor(.blue)
              }
          }
          .padding(.top, 8)
      }
      .padding(.horizontal, 24)
  }
}