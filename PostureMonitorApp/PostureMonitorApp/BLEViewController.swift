import SwiftUI

struct BLEView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSavedData = false // State to control navigation

    var body: some View {
        NavigationView {
            VStack {
                Text(bleViewModel.statusText)
                    .font(.headline)
                    .padding()

                ScrollView {
                    Text(bleViewModel.receivedData)
                        .font(.body)
                        .padding()
                }

                Button(action: {
                    bleViewModel.toggleScan()
                }) {
                    Text(bleViewModel.isScanning ? "Stop Scanning" : "Start Scanning")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

                Button(action: {
                    print("Fetching recent posture data...")
                    bleViewModel.fetchRecentPostureData() // Fetch data
                    showSavedData = true // Trigger navigation
                }) {
                    Text("Saved Posture Data")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)

                // NavigationLink triggered by showSavedData
                NavigationLink(destination: SavedPostureDataView(), isActive: $showSavedData) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}
