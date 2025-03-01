import Foundation
import CoreData

/// Struct for temporary posture readings in buffer
struct PostureReading {
    let timestamp: Date
    let isBad: Float
}

class DataHandler {
    private let coreDataHandler: CoreDataHandler
    private var postureBuffer: [String: [PostureReading]] = [:]
    private var lastSavedMinute: Date?
    private var lastSaveTime: Date?
    private var savedTimestamps: Set<Date> = [] // ✅ Prevent duplicate saves

    init(coreDataHandler: CoreDataHandler) {
        self.coreDataHandler = coreDataHandler
    }

    func processData(_ jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { return }

        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] {
                let rawTimestamp = Date()
                let currentMinute = roundToMinute(rawTimestamp)

                // ✅ Check if this minute was already saved
                if shouldSaveData(for: currentMinute) {
                    savedTimestamps.insert(currentMinute) // ✅ Mark as saved
                    lastSavedMinute = currentMinute
                    lastSaveTime = Date()

                    print("🔥 Calling saveAggregatedData() for minute \(currentMinute)")
                    saveAggregatedData(currentMinute)
                }

                for (position, postureStatus) in jsonDict {
                    let isBad = postureStatus == "B" ? 1.0 : 0.0
                    let reading = PostureReading(timestamp: rawTimestamp, isBad: Float(isBad))
                    postureBuffer[position, default: []].append(reading)
                }
            }
        } catch {
            print("❌ Error parsing JSON: \(error.localizedDescription)")
        }
    }

    // ✅ Improved check to prevent duplicate saves
    private func shouldSaveData(for minute: Date) -> Bool {
        guard let lastTime = lastSaveTime else {
            return !savedTimestamps.contains(minute) // ✅ Prevent duplicate
        }

        let now = Date()
        let elapsedSeconds = now.timeIntervalSince(lastTime)

        return (!savedTimestamps.contains(minute)) && (elapsedSeconds >= 55)
    }

    private func saveAggregatedData(_ roundedTimestamp: Date) {
        guard !postureBuffer.isEmpty else { return }

        print("💾 Saving aggregated data for minute: \(roundedTimestamp)")

        var postureDataList: [PostureData] = []

        for (position, readings) in postureBuffer {
            let totalReadings = readings.count
            let badReadings = readings.filter { $0.isBad == 1.0 }.count
            let badPosturePercentage = (Float(badReadings) / Float(totalReadings)) * 100

            print("📌 Aggregating for \(position) at \(roundedTimestamp): \(badPosturePercentage)% bad")

            if let existingEntry = coreDataHandler.fetchExistingMinuteEntry(for: position, at: roundedTimestamp) {
                let existingPercentage = existingEntry.value(forKey: "badPosturePercentage") as? Float ?? 0.0

                if existingPercentage != badPosturePercentage {
                    existingEntry.setValue(badPosturePercentage, forKey: "badPosturePercentage")
                    print("📌 Updated \(position): \(badPosturePercentage)% bad")
                }
            } else {
                let entry = PostureData(timestamp: roundedTimestamp, position: position, badPosturePercentage: badPosturePercentage)
                postureDataList.append(entry)
            }
        }

        coreDataHandler.savePostureDataBatch(postureDataList: postureDataList)

        postureBuffer.removeAll() // ✅ Clear buffer after processing
    }

    private func roundToMinute(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySetting: .second, value: 0, of: date) ?? date
    }
}
