// BLEView.swift
// PostureMonitorApp
//
// Created by Ahmad Capstone on 2025-01-09.

import SwiftUI

struct BLEView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack {
                Text(bleViewModel.statusText)
                    .font(.headline)
                    .padding()

                Text(bleViewModel.receivedData)
                    .font(.body)
                    .padding()

                Button(action: {
                    bleViewModel.toggleScan()
                }) {
                    Text(bleViewModel.isScanning ? "Stop Scanning" : "Start Scan")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

class BLEViewModel: ObservableObject {
    @Published var statusText: String = "Status: Not Connected"
    @Published var receivedData: String = ""
    @Published var isScanning: Bool = false

    private let bleManager = BLEManager()

    init() {
        bleManager.delegate = self
    }

    func setup() {
        NotificationCenter.default.addObserver(forName: Notification.Name("BLEDataReceived"),
                                               object: nil, queue: .main) { [weak self] notification in
            self?.handleNotification(notification)
        }
    }

    func cleanup() {
        NotificationCenter.default.removeObserver(self)
    }

    func toggleScan() {
        if isScanning {
            bleManager.stopScan()
            isScanning = false
        } else {
            bleManager.startScan()
            isScanning = true
        }
    }

    private func handleNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let data = userInfo["data"] as? String else { return }

        receivedData += "\nReceived Data: \(data)"
    }
}

extension BLEViewModel: BLEManagerDelegate {
    func didUpdateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.statusText = "Status: \(status)"
        }
    }

    func didReceiveData(_ data: String) {
        DispatchQueue.main.async {
            self.receivedData += "\nReceived Data: \(data)"
        }
        // Post notification to update other listeners if needed
        NotificationCenter.default.post(name: Notification.Name("BLEDataReceived"),
                                        object: nil, userInfo: ["data": data])
    }
}
