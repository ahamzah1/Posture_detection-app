import SwiftUI

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @AppStorage("postureThreshold") private var postureThreshold: Int = 40
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true // ✅ Toggle notifications

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
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.all)

                    // ✅ Toggle Push Notifications
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Push Notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("Text Colour"))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    .padding([.leading, .bottom, .trailing])

                    // ✅ Adjust Posture Sensitivity
                    VStack(alignment: .leading) {
                        Text("Posture Alert Sensitivity")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("Text Colour"))

                        Stepper("Threshold: \(postureThreshold)%", value: $postureThreshold, in: 10...90, step: 5)
                            .padding(.horizontal)
                            .onChange(of: postureThreshold) { newValue in
                                print("⚙️ New posture threshold set: \(newValue)%")
                            }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))

                    Spacer()

                    Button("Log Out") {
                        KeychainHelper.shared.delete(forKey: "authToken")
                        isLoggedIn = false
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
