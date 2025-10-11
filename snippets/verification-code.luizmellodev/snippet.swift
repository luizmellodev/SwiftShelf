import SwiftUI
import Combine

struct OTPVerificationView: View, ViewTemplate {
    let id = "otpverification"
    let name = "OTP Verification"
    
    var view: AnyView {
        AnyView(self)
    }
    
  @State private var otpCode: [String] = Array(repeating: "", count: 4)
  @State private var currentField: Int = 0
  @FocusState private var fieldFocus: Int?
  
  var body: some View {
      VStack(spacing: 32) {
          // Icon
          ZStack {
              Circle()
                  .fill(Color.blue.opacity(0.1))
                  .frame(width: 80, height: 80)
              
              Image(systemName: "iphone")
                  .font(.system(size: 32))
                  .foregroundColor(.blue)
          }
          
          // Header
          VStack(spacing: 8) {
              Text("Verification Code")
                  .font(.title2)
                  .fontWeight(.bold)
              
              Text("We've sent a code to +1 (555) 123-4567")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)
          }
          
          // OTP Fields
          HStack(spacing: 12) {
              ForEach(0..<4, id: \.self) { index in
                  OTPTextField(text: $otpCode[index], isFocused: fieldFocus == index)
                      .focused($fieldFocus, equals: index)
                      .onChange(of: otpCode[index]) { newValue in
                          if newValue.count > 0 && index < 3 {
                              fieldFocus = index + 1
                          }
                      }
              }
          }
          .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  self.fieldFocus = 0
              }
          }
          
          // Resend code
          Button(action: {
              // Handle resend code
          }) {
              HStack(spacing: 4) {
                  Text("Didn't receive code?")
                      .font(.footnote)
                  
                  Text("Resend")
                      .font(.footnote)
                      .fontWeight(.medium)
                      .foregroundColor(.blue)
              }
          }
          
          // Verify button
          Button(action: {
              // Handle verification
          }) {
              Text("Verify")
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(16)
          }
          .padding(.top, 16)
      }
      .padding(.horizontal, 24)
  }
}

struct OTPTextField: View {
  @Binding var text: String
  var isFocused: Bool
  
  var body: some View {
      ZStack {
          RoundedRectangle(cornerRadius: 12)
              .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
              .frame(width: 50, height: 60)
          
          TextField("", text: $text)
              .keyboardType(.numberPad)
              .multilineTextAlignment(.center)
              .font(.title2.bold())
              .foregroundColor(.primary)
              .frame(width: 50, height: 60)
              .onReceive(Just(text)) { _ in
                  if text.count > 1 {
                      text = String(text.prefix(1))
                  }
              }
      }
  }
}
