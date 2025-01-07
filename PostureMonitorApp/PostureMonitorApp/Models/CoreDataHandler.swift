//
//  CoreDataHandler.swift
//  PostureMonitorApp
//
//  Created by Ahmad Capstone on 2025-01-03.
//

import CoreData
import UIKit

class CoreDataHandler {
    static let shared = CoreDataHandler()

    private var context: NSManagedObjectContext

    private init() {
        self.context = PersistenceController.shared.container.viewContext
    }

    // Custom initializer for testing
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func setContext(context: NSManagedObjectContext) {
        self.context = context
    }

    func insertPostureData(data: PostureData) {
        let entity = PostureEntity(context: context)
        entity.timestamp = data.timestamp
        entity.position = data.position
        entity.accelerationZ = data.accelerationZ
        entity.postureStatus = data.postureStatus

        do {
            try context.save()
            print("Posture data saved")
        } catch {
            print("Failed to save data: (error.localizedDescription)")
        }
    }

    func fetchPostureData() -> [PostureEntity] {
        let request: NSFetchRequest<PostureEntity> = PostureEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch data: (error.localizedDescription)")
            return []
        }
    }
}
