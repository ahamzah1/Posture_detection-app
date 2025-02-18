import SwiftUI
import Charts

struct PostureScoreView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel // Access BLEViewModel
    @State private var postureScore: Float = 0.0 // Overall posture score
    @State private var postureHistory: [(time: Date, score: Float)] = [] // Posture history for the chart

    var body: some View {
        VStack(spacing: 20) {
            Text("Posture Score")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Posture Score Display
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

            Divider()

            // Posture Over Time Chart
            Text("Posture Throughout the Day")
                .font(.headline)

            Chart(postureHistory, id: \.time) {
                LineMark(
                    x: .value("Time", $0.time),
                    y: .value("Score", $0.score)
                )
                .foregroundStyle(Color.blue)
                .symbol(Circle())
            }
            .frame(height: 200)
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            fetchPostureData()
        }
        .onReceive(bleViewModel.$recentPostureData) { _ in
            fetchPostureData()
        }
    }

    private func fetchPostureData() {
        // Fetch posture data and calculate scores
        let data = bleViewModel.recentPostureData
        postureHistory = calculatePostureHistory(from: data)
        postureScore = calculateOverallScore(from: postureHistory)
    }

    private func calculatePostureHistory(from data: [PostureData]) -> [(time: Date, score: Float)] {
        var history: [(time: Date, score: Float)] = []
        var totalScore: Float = 0

        for entry in data {
            // Calculate score for each entry
            let score = entry.postureStatus == "B" ? -1 : 1 // Example scoring
            totalScore += Float(score)
            history.append((time: entry.timestamp, score: totalScore))
        }

        return history
    }

    private func calculateOverallScore(from history: [(time: Date, score: Float)]) -> Float {
        guard !history.isEmpty else { return 0.0 }

        // Normalize score to percentage
        let totalScore = history.last?.score ?? 0.0
        let maxScore = Float(history.count) // Max possible score (all good posture)
        return (totalScore / maxScore) * 100
    }
}

#Preview {
    PostureScoreView()
}
