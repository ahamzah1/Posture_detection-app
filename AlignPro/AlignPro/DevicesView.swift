import SwiftUI

struct DevicesView: View {
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
                
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}
