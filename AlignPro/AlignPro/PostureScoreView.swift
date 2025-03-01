import SwiftUI
import Charts

struct PostureScoreView: View {
    @EnvironmentObject var bleViewModel: BLEViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // **1️⃣ Daily Posture Score**
                VStack {
                    Text("Your Posture Score")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Text(String(format: "%.1f", bleViewModel.postureScore)) // ✅ Directly use @Published value
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(scoreColor(bleViewModel.postureScore))
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.3), radius: 10)
                        )
                }
                .padding(.top, 20)

                // **2️⃣ Per-Sensor Breakdown**
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sensor Breakdown")
                        .font(.headline)

                    ForEach(bleViewModel.perSensorBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { sensor, percentage in
                        HStack {
                            Text(sensor)
                                .font(.subheadline)
                                .bold()

                            Spacer()

                            ProgressView(value: percentage, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: scoreColor(100 - percentage)))
                                .frame(width: 150)

                            Text("\(Int(percentage))%")
                                .foregroundColor(scoreColor(100 - percentage))
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))

                // **3️⃣ Posture Trend Over the Day (Line Chart)**
                VStack(alignment: .leading) {
                    Text("Posture Trend (Today)")
                        .font(.headline)

                    Chart {
                        ForEach(bleViewModel.postureTrend, id: \.0) { data in
                            LineMark(
                                x: .value("Time", data.0, unit: .minute),
                                y: .value("Score", data.1)
                            )
                            .foregroundStyle(scoreColor(data.1))
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .frame(height: 200)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                }
                .padding()

                // **4️⃣ Weekly Posture Scores (Bar Chart)**
                VStack(alignment: .leading) {
                    Text("Weekly Posture Scores")
                        .font(.headline)

                    Chart {
                        ForEach(bleViewModel.weeklyPostureScores, id: \.0) { data in
                            BarMark(
                                x: .value("Day", data.0, unit: .day),
                                y: .value("Score", data.1)
                            )
                            .foregroundStyle(scoreColor(data.1))
                        }
                    }
                    .frame(height: 200)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                }
                .padding()
            }
            .padding()
        }
    }

    // **🎨 Determines color based on score**
    private func scoreColor(_ score: Float) -> Color {
        if score >= 80 { return .green }
        if score >= 50 { return .yellow }
        return .red
    }
}

//import SwiftUI
//import Charts
//
//struct PostureScoreView: View {
//    @EnvironmentObject var bleViewModel: BLEViewModel
//    @State private var groupedPostureData: [Date: [PostureData]] = [:] // ✅ Grouped by minute
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Title
//                Text("Posture Score")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.top, 20)
//
//                Divider()
//
//                // Saved Posture Data (Grouped by Minute)
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Saved Posture Data")
//                        .font(.headline)
//
//                    List {
//                        ForEach(groupedPostureData.keys.sorted(by: { $0 < $1 }), id: \.self) { minute in
//                            Section(header: Text(minute, style: .time).font(.headline)) {
//                                ForEach(groupedPostureData[minute] ?? [], id: \.position) { entry in
//                                    HStack {
//                                        Text(entry.position) // ✅ Show Sensor Type
//                                            .font(.caption)
//                                            .frame(width: 40)
//
//                                        Spacer()
//
//                                        Text("\(Int(entry.badPosturePercentage))% Bad")
//                                            .fontWeight(.bold)
//                                            .foregroundColor(entry.badPosturePercentage > 60 ? .red : .green)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .frame(height: 300)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//                .padding(.horizontal)
//
//                // 🗑 "Delete All" Button
//                Button(action: {
//                    deleteAllPostureData()
//                }) {
//                    Text("Delete All Data")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//
//                Spacer()
//            }
//            .padding()
//        }
//        .onAppear {
//            bleViewModel.loadPostureDataFromCoreData()
//            groupDataByMinute()
//        }
//        .onReceive(bleViewModel.$recentPostureData) { _ in
//            groupDataByMinute()
//        }
//    }
//
//    // MARK: - Group Data by Minute
//    private func groupDataByMinute() {
//        let data = bleViewModel.recentPostureData
//        groupedPostureData = Dictionary(grouping: data, by: { roundToMinute($0.timestamp) })
//    }
//
//    // ✅ Helper function to round timestamps to minutes
//    private func roundToMinute(_ date: Date) -> Date {
//        let calendar = Calendar.current
//        return calendar.date(bySetting: .second, value: 0, of: date) ?? date
//    }
//
//    // MARK: - Delete All Posture Data
//    private func deleteAllPostureData() {
//        bleViewModel.deleteAllPostureData() // Call function to remove all Core Data entries
//        groupedPostureData.removeAll() // Clear local state
//    }
//}
//
//#Preview {
//    PostureScoreView()
//}

