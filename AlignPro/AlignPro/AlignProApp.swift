//
//  AlignProApp.swift
//  AlignPro
//
//  Created by Jim Greenwood on 2024-12-30.
//

import SwiftUI
import CoreData

@main
struct AlignProApp: App {
    // Persistent container for Core Data
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PostureModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        return container
    }()

    // BLE ViewModel with Core Data context
        @StateObject private var bleViewModel: BLEViewModel

        init() {
            // Initialize BLEViewModel with the managed object context
            let context = persistentContainer.viewContext
            _bleViewModel = StateObject(wrappedValue: BLEViewModel(context: context))
        }

    var body: some Scene {
        WindowGroup {
            ContentView() // Main BLE View
                .environment(\.managedObjectContext, persistentContainer.viewContext) // Inject Core Data
                .environmentObject(bleViewModel) // Inject BLEViewModel
        }
    }
}
