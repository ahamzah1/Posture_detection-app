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
    let accelerationZ: Float
    let postureStatus: String

    var description: String {
        return "PostureData(timestamp: \(timestamp), position: \(position), accelerationZ: \(accelerationZ), postureStatus: \(postureStatus))"
    }
}
