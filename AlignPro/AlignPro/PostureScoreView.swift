//
//  PostureScoreView.swift
//  AlignPro
//
//  Created by Ahmad Capstone on 2025-01-15.
//

import SwiftUI

struct PostureScoreView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel // Access BLEViewModel
    @State private var postureScore: Float = 0.0 // Placeholder for dynamic score

    var body: some View {
        VStack(spacing: 30) {
            Text("Posture Score")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Spacer()

            // Gauge or Progress Bar
            VStack {
                Text("Your Score: \(Int(postureScore))%")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)

                Gauge(value: postureScore, in: 0...100) {
                    Text("Score")
                } currentValueLabel: {
                    Text("\(Int(postureScore))")
                }
                .gaugeStyle(.accessoryCircular)
                .tint(Gradient(colors: [.red, .yellow, .green]))
                .frame(width: 200, height: 200)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            fetchLatestPostureScore()
        }
        .onReceive(bleViewModel.$recentPostureData) { _ in
            fetchLatestPostureScore()
        }
    }

    private func fetchLatestPostureScore() {
        // Use BLEViewModel to fetch the latest posture score from Core Data
        if let latestData = bleViewModel.recentPostureData.last {
            postureScore = calculatePostureScore(from: latestData)
        }
    }

    private func calculatePostureScore(from data: PostureData) -> Float {
        // Logic to convert PostureData into a score (e.g., normalize accelerationZ)
        let normalizedScore = max(0, min(100, data.accelerationZ * 10 + 50)) // Example formula
        return normalizedScore
    }
}

#Preview {
    PostureScoreView()
}
