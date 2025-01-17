import SwiftUI

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
//    @Binding var correctEmail: String
//    @Binding var correctPassword: String
    
    @State private var notificationsOn = true
    @State var emailAddress: String = ""
    @State var password: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background Colour")
                    .ignoresSafeArea()
                
                VStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Text Colour"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.all)
                    
                    Toggle(isOn: $notificationsOn) {
                        Text("Push Notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("Text Colour"))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    .padding([.leading, .bottom, .trailing])
                    
                    NavigationLink(destination: SetGoodPostureView()) {
                        Text("Set Good Posture")
                    }
                    .padding(.all)
                    .foregroundStyle(Color("Button Text Colour"))
                    .fontWeight(.semibold)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                    
                    Text("Update Email Address")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("Text Colour"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .leading, .trailing])
                    
                    TextField("New Email Address", text: $emailAddress)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(Color("Text Colour"))
                        .padding([.leading, .bottom, .trailing])
                    
//                    Button("Update Email") {
//                        correctEmail = emailAddress
//                        emailAddress = ""
//                    }
                    .padding(.all)
                    .foregroundStyle(Color("Button Text Colour"))
                    .fontWeight(.semibold)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
//                    NavigationLink(destination: ChangePasswordView(correctPassword: $correctPassword)) {
//                        Text("Update Password")
//                    }
                    .padding(.all)
                    .foregroundStyle(Color("Button Text Colour"))
                    .fontWeight(.semibold)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button("Log Out") {
                        KeychainHelper.shared.delete(forKey: "authToken") // Clear token
                        isLoggedIn = false // Update state to log out
                    }
                    .padding(.all)
                    .foregroundStyle(Color("Button Text Colour"))
                    .fontWeight(.semibold)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                    
                    Spacer()
                }
            }
        }
    }
}
