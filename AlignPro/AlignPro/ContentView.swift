import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false

    var body: some View {
        ZStack {
            Color("Background Colour").ignoresSafeArea()

            VStack {
                ZStack {
                    Color("AccentColor")
                        .ignoresSafeArea()
                        .frame(height: 80)

                    Image("AppTitle")
                }

                if isLoggedIn {
                    MainTabView(isLoggedIn: $isLoggedIn)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
        .onAppear {
            checkIfLoggedIn()
        }
    }

    private func checkIfLoggedIn() {
        if KeychainHelper.shared.retrieve(forKey: "authToken") != nil {
            isLoggedIn = true
        }
    }
}

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView {
            PostureScoreView()
                .tabItem {
                    Label("Posture", systemImage: "figure.stand")
                }
            DevicesView()
                .tabItem {
                    Label("Devices", systemImage: "app.connected.to.app.below.fill")
                }
            FAQView()
                .tabItem {
                    Label("FAQ", systemImage: "questionmark.app")
                }
            SettingsView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
