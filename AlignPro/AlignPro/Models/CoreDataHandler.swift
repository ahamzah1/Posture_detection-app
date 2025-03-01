import Foundation
import CoreData

class CoreDataHandler {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Save a single PostureData record asynchronously
    func savePostureData(postureData: PostureData, completion: ((Bool, Error?) -> Void)? = nil) {
        context.perform {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "PostureEntity", into: self.context)
            entity.setValue(postureData.timestamp, forKey: "timestamp")
            entity.setValue(postureData.position, forKey: "position")
            entity.setValue(postureData.badPosturePercentage, forKey: "badPosturePercentage")

            do {
                try self.context.save()
                completion?(true, nil)  // ✅ Success callback
            } catch {
                print("❌ Failed to save posture data: \(error.localizedDescription)")
                completion?(false, error) // ❌ Error callback
            }
        }
    }

    /// Save multiple posture records in a batch (efficient for large data)
    func savePostureDataBatch(postureDataList: [PostureData], completion: ((Bool, Error?) -> Void)? = nil) {
        guard !postureDataList.isEmpty else {
            completion?(false, nil)
            return
        }

        context.perform {
            for postureData in postureDataList {
                let entity = NSEntityDescription.insertNewObject(forEntityName: "PostureEntity", into: self.context)
                entity.setValue(postureData.timestamp, forKey: "timestamp")
                entity.setValue(postureData.position, forKey: "position")
                entity.setValue(postureData.badPosturePercentage, forKey: "badPosturePercentage")
            }

            do {
                try self.context.save()
                completion?(true, nil) // ✅ Success callback
                print("✅ Batch save successful (\(postureDataList.count) records).")
            } catch {
                print("❌ Failed to save batch posture data: \(error.localizedDescription)")
                completion?(false, error)
            }
        }
    }

    /// Fetch all posture data
    func fetchPostureData() -> [PostureData] {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "PostureEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { result in
                guard let timestamp = result.value(forKey: "timestamp") as? Date,
                      let position = result.value(forKey: "position") as? String,
                      let badPosturePercentage = result.value(forKey: "badPosturePercentage") as? Float else {
                    print("⚠️ Skipped invalid record: \(result)")
                    return nil
                }
                return PostureData(timestamp: timestamp, position: position, badPosturePercentage: badPosturePercentage)
            }
        } catch {
            print("❌ Failed to fetch posture data: \(error.localizedDescription)")
            return []
        }
    }

    /// Fetch a specific record by position and timestamp
    func fetchPostureRecord(for position: String, at timestamp: Date) -> PostureData? {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "PostureEntity")
        fetchRequest.predicate = NSPredicate(format: "position == %@ AND timestamp == %@", position, timestamp as CVarArg)
        fetchRequest.fetchLimit = 1

        guard let result = try? context.fetch(fetchRequest).first else {
            return nil
        }

        if let timestamp = result.value(forKey: "timestamp") as? Date,
           let position = result.value(forKey: "position") as? String,
           let badPosturePercentage = result.value(forKey: "badPosturePercentage") as? Float {
            return PostureData(timestamp: timestamp, position: position, badPosturePercentage: badPosturePercentage)
        }

        return nil
    }

    /// Update a record's bad posture percentage
    func updatePostureRecord(for position: String, at timestamp: Date, newPercentage: Float, completion: ((Bool, Error?) -> Void)? = nil) {
        context.perform {
            if let existingRecord = self.fetchPostureRecord(for: position, at: timestamp) {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "PostureEntity")
                fetchRequest.predicate = NSPredicate(format: "position == %@ AND timestamp == %@", position, timestamp as CVarArg)
                fetchRequest.fetchLimit = 1

                if let result = try? self.context.fetch(fetchRequest).first {
                    result.setValue(newPercentage, forKey: "badPosturePercentage")

                    do {
                        try self.context.save()
                        completion?(true, nil)  // ✅ Success callback
                        print("📌 Updated \(position) at \(timestamp) to \(newPercentage)% bad posture")
                    } catch {
                        print("❌ Failed to update record: \(error.localizedDescription)")
                        completion?(false, error)
                    }
                }
            } else {
                completion?(false, nil)
            }
        }
    }
    
    public func fetchExistingMinuteEntry(for position: String, at timestamp: Date) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostureEntity")
        fetchRequest.predicate = NSPredicate(format: "position == %@ AND timestamp == %@", position, timestamp as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("❌ Failed to fetch existing record for \(position) at \(timestamp): \(error.localizedDescription)")
            return nil
        }
    }
    

    /// Delete all posture data
    func deleteAllPostureData(completion: ((Bool, Error?) -> Void)? = nil) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PostureEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        context.perform {
            do {
                try self.context.execute(deleteRequest)
                try self.context.save()
                completion?(true, nil)
                print("🗑️ All posture data deleted successfully.")
            } catch {
                print("❌ Failed to delete posture data: \(error.localizedDescription)")
                completion?(false, error)
            }
        }
    }
}
