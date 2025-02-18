import Foundation
import CoreData

class CoreDataHandler {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func savePostureData(postureData: PostureData) {
        let entity = NSEntityDescription.entity(forEntityName: "PostureEntity", in: context)!
        let postureEntity = NSManagedObject(entity: entity, insertInto: context)

        postureEntity.setValue(postureData.timestamp, forKey: "timestamp")
        postureEntity.setValue(postureData.position, forKey: "position")
        postureEntity.setValue(postureData.postureStatus, forKey: "postureStatus")

        do {
            try context.save()
//            print("Posture data saved successfully.")
        } catch {
            print("Failed to save posture data: \(error.localizedDescription)")
        }
    }

    func fetchPostureData() -> [PostureData] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostureEntity")

        // Add a sort descriptor for consistent ordering
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        var postureDataList: [PostureData] = []

        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                if let timestamp = result.value(forKey: "timestamp") as? Date,
                   let position = result.value(forKey: "position") as? String,
                   let postureStatus = result.value(forKey: "postureStatus") as? String {
                    let postureData = PostureData(
                        timestamp: timestamp,
                        position: position,
                        postureStatus: postureStatus
                    )
                    postureDataList.append(postureData)
                } else{
                    print("Invalid Record: \(result)")
                }
            }
        } catch {
            print("Failed to fetch posture data: \(error.localizedDescription)")
        }

        return postureDataList
    }
    func deleteAllPostureData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PostureEntity")

        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("All posture data deleted successfully.")
        } catch {
            print("Failed to delete all posture data: \(error.localizedDescription)")
        }
    }
}
