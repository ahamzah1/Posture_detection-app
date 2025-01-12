//
//  SavedPostureDataView.swift
//  PostureMonitorApp
//
//  Created by Ahmad Capstone on 2025-01-12.
//
import SwiftUI

struct SavedPostureDataView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel

    var body: some View {
        VStack {
            if bleViewModel.recentPostureData.isEmpty {
                Text("No posture data available.")
                    .foregroundColor(.gray)
                    .font(.headline)
            } else {
                List(bleViewModel.recentPostureData, id: \.timestamp) { record in
                    VStack(alignment: .leading) {
                        Text("Position: \(record.position)")
                        Text("Acceleration Z: \(record.accelerationZ)")
                        Text("Posture Status: \(record.postureStatus)")
                        Text("Timestamp: \(record.timestamp)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Button(action: {
                bleViewModel.deleteAllData()
            }) {
                Text("Delete All Data")
                    .font(.title2)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .navigationTitle("Saved Posture Data")
        .onAppear {
            bleViewModel.fetchRecentPostureData()
        }
    }
}
