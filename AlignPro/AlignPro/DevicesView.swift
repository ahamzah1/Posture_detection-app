import SwiftUI

struct DevicesView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("PostureDevice") private var pairedDeviceName: String? // Save paired device name
    
    @State private var isPairing = false // Tracks if the user is in the pairing process
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status Display
                Text(bleViewModel.statusText)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                
                // Paired Device Section
                if let pairedDevice = pairedDeviceName {
                    VStack {
                        Text("Paired Device:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(pairedDevice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Button(action: {
                            unpairDevice()
                        }) {
                            Text("Unpair Device")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                } else {
                    Text("No device paired")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.vertical, 20)
                
                // Pairing Section
                if isPairing {
                    VStack {
                        Text("Available Devices:")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        ScrollView {
                            ForEach(bleViewModel.discoveredDevices, id: \.id) { device in
                                Button(action: {
                                    pairDevice(device: device)
                                }) {
                                    HStack {
                                        Text(device.name)
                                            .font(.body)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // Pairing/Scanning Button
                Button(action: {
                    togglePairingMode()
                }) {
                    Text(isPairing ? "Cancel Pairing" : "Pair Device")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isPairing ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Devices")
        }
        .onAppear {
            bleViewModel.loadPairedDevice() // Ensure BLEViewModel handles pre-paired device
        }
    }
    
    // MARK: - Helper Methods
    private func togglePairingMode() {
        isPairing.toggle()
        if isPairing {
            bleViewModel.startScanning()
        } else {
            bleViewModel.stopScanning()
        }
    }
    
    private func pairDevice(device: BLEDevice) {
        pairedDeviceName = device.name
        bleViewModel.pairWithDevice(device)
        isPairing = false
        bleViewModel.stopScanning()
    }
    
    private func unpairDevice() {
        pairedDeviceName = nil
        bleViewModel.unpairDevice()
    }
}
