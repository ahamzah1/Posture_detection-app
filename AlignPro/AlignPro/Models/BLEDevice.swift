//
//  BLEDevice.swift
//  AlignPro
//
//  Created by Ahmad Capstone on 2025-01-18.
//

import Foundation

struct BLEDevice: Identifiable, Equatable {
    let name: String
    let id: UUID

    // Optional: Equatable conformance
    static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        return lhs.id == rhs.id
    }
}
