//
//  ContentView.swift
//  PostureMonitorApp
//
//  Created by Ahmad Capstone on 2025-01-07.
//

import SwiftUI

struct ContentView: View {
    @State private var statusText: String = "Scanning for devices..."
    @State private var receivedData: String = "No data received yet."

    // MARK: - UI Elements
    var body: some View {
        NavigationView {
            VStack {
                Text(statusText)
                    .font(.headline)
                    .padding()
                
                Text(receivedData)
                    .font(.body)
                    .padding()

                Button(action: {
                    startScanning()
                }) {
                    Text("Start Scan")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Posture Monitor")
            .onAppear {
                setupNotifications()
            }
            .onDisappear {
                // Clean up when the view disappears
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    // MARK: - Notification Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: Notification.Name("BLEDataReceived"),
                                               object: nil, queue: .main) { notification in
            updateUI(notification)
        }
    }

    // MARK: - Actions
    private func startScanning() {
        statusText = "Scanning for devices..."
        BLEManager.shared.startScanning()
    }

    private func updateUI(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let data = userInfo["data"] as? String else { return }

        statusText = "Connected to BLE Device"
        receivedData = "Received Data:\n\(data)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
