//
//  SignUpView.swift
//  AlignPro
//
//  Created by Ahmad Hamzah on 2025-01-02.
//

import SwiftUI

struct SignUpView: View {
    @Binding var isLoggedIn: Bool
    @State private var enteredName: String = ""
    @State private var enteredEmail: String = ""
    @State private var enteredPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.all)

            TextField("Full Name", text: $enteredName)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .bottom, .trailing])

            TextField("Username", text: $enteredEmail)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .bottom, .trailing])

            SecureField("Password", text: $enteredPassword)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .bottom, .trailing])

            SecureField("Confirm Password", text: $confirmPassword)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .bottom, .trailing])

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding([.leading, .bottom, .trailing])
            }

            if isLoading {
                ProgressView()
                    .padding()
            }

            Button("Sign Up") {
                handleSignUp()
            }
            .padding()
            .foregroundStyle(Color("Button Text Colour"))
            .fontWeight(.semibold)
            .background(Color("AccentColor"))
            .clipShape(Capsule())

            Spacer()
        }
        .padding()
    }

    private func handleSignUp() {
        guard !enteredName.isEmpty else {
            errorMessage = "Name cannot be empty"
            showError = true
            return
        }
        
        guard enteredPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }

        isLoading = true
        showError = false

        guard let url = URL(string: "<Ip-address>/api/users") else {
            errorMessage = "Invalid server URL"
            showError = true
            isLoading = false
            return
        }

        let signUpData: [String: String] = [
            "username": enteredEmail,
            "name": enteredName,
            "password": enteredPassword
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: signUpData) else {
            errorMessage = "Failed to encode signup data"
            showError = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showError = true
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    showError = true
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    isLoggedIn = true
                } else {
                    errorMessage = "Sign up failed"
                    showError = true
                }
            }
        }.resume()
    }
}
