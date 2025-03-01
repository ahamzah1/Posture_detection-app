//
//  PostureData.swift
//  PostureMonitorApp
//
//  Created by Ahmad Capstone on 2025-01-03.
//

import Foundation


struct PostureData: CustomStringConvertible {
    let timestamp: Date
    let position: String
    let badPosturePercentage: Float

    var description: String {
        return "PostureData(timestamp: \(timestamp), position: \(position), badPosturePercentage: \(badPosturePercentage))"
    }
}
