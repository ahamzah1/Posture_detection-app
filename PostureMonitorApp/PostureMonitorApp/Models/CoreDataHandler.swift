import Foundation
import CoreData
import UIKit

class CoreDataHandler {
    static let shared = CoreDataHandler() // Singleton instance
    private let context: NSManagedObjectContext

    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: - Save Data
    func savePostureData(postureData: PostureData) {
        let entity = NSEntityDescription.entity(forEntityName: "PostureEntity", in: context)! // Use "PostureEntity"
        let postureEntity = NSManagedObject(entity: entity, insertInto: context)

        postureEntity.setValue(postureData.timestamp, forKey: "timestamp")
        postureEntity.setValue(postureData.position, forKey: "position")
        postureEntity.setValue(postureData.accelerationZ, forKey: "accelerationZ")
        postureEntity.setValue(postureData.postureStatus, forKey: "postureStatus")

        do {
            try context.save()
            print("Posture data saved successfully.")
        } catch let error as NSError {
            print("Failed to save data: \(error), \(error.userInfo)")
        }
    }

    // MARK: - Fetch Data
    func fetchPostureData() -> [PostureData] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostureEntity") // Use "PostureEntity"
        var postureDataList: [PostureData] = []

        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                if let timestamp = result.value(forKey: "timestamp") as? Date,
                   let position = result.value(forKey: "position") as? String,
                   let accelerationZ = result.value(forKey: "accelerationZ") as? Float,
                   let postureStatus = result.value(forKey: "postureStatus") as? String {
                    let postureData = PostureData(timestamp: timestamp, position: position, accelerationZ: accelerationZ, postureStatus: postureStatus)
                    postureDataList.append(postureData)
                }
            }
        } catch let error as NSError {
            print("Failed to fetch data: \(error), \(error.userInfo)")
        }

        return postureDataList
    }

    // MARK: - Delete Data
    func deleteAllPostureData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PostureEntity") // Use "PostureEntity"
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All posture data deleted successfully.")
        } catch let error as NSError {
            print("Failed to delete data: \(error), \(error.userInfo)")
        }
    }
}
