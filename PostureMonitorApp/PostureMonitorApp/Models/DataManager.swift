//
//  DataManager.swift
//  PostureMonitorApp
//
//  Created by Ahmad Capstone on 2025-01-03.
//

import Foundation

class DataManager {
    static let shared = DataManager()

    private init() {}

    func parseAndStoreData(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
              let rawArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
            print("Failed to parse JSON")
            return
        }

        for rawData in rawArray {
            if let position = rawData["pos"] as? String,
               let az = rawData["az"] as? Float,
               let posture = rawData["p"] as? String {
                let postureData = PostureData(
                    timestamp: Date(),
                    position: position,
                    accelerationZ: az,
                    postureStatus: posture == "G" ? "Good" : "Bad"
                )
                storeData(postureData: postureData)
            }
        }
    }

    func storeData(postureData: PostureData) {
        CoreDataHandler.shared.insertPostureData(data: postureData)
    }
}
