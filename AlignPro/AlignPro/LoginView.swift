//
//  LoginView.swift
//  AlignPro
//
//  Created by Jim Greenwood on 2025-01-02.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State var enteredEmail: String = ""
    @State var enteredPassword: String = ""
    @State var wrongEmailOrPassword: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text("Log In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.all)
            
            TextField("UserName", text: $enteredEmail)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .bottom, .trailing])
            
            SecureField("Password", text: $enteredPassword)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .bottom, .trailing])
            
            if wrongEmailOrPassword {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding([.leading, .bottom, .trailing])
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            Button("Log In") {
                handleLogin()
            }
            .padding(.all)
            .foregroundStyle(Color("Button Text Colour"))
            .fontWeight(.semibold)
            .background(Color("AccentColor"))
            .clipShape(Capsule())
            
            Spacer()
            
            NavigationLink(destination: SignUpView(isLoggedIn: $isLoggedIn)) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .padding(.bottom)
            }
            
        }
    }
    
    private func handleLogin() {
        isLoading = true
        wrongEmailOrPassword = false
        
        guard let url = URL(string: "<Ip-address>/api/login") else {
            errorMessage = "Invalid server URL"
            wrongEmailOrPassword = true
            isLoading = false
            return
        }
        
        let loginData = ["username": enteredEmail, "password": enteredPassword]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: loginData) else {
            errorMessage = "Failed to encode login data"
            wrongEmailOrPassword = true
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
                    wrongEmailOrPassword = true
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    wrongEmailOrPassword = true
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    errorMessage = "Invalid credentials"
                    wrongEmailOrPassword = true
                    return
                }
                
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let token = responseJSON?["token"] as? String {
                        // Save the token in Keychain
                        KeychainHelper.shared.save(token, forKey: "authToken")
                        isLoggedIn = true
                    } else {
                        errorMessage = "Invalid response from server"
                        wrongEmailOrPassword = true
                    }
                } catch {
                    errorMessage = "Failed to decode response"
                    wrongEmailOrPassword = true
                }
            }
        }.resume()
    }
}
#Preview {
    ContentView()
}
