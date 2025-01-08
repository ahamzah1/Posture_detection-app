import Foundation
import CoreData
import UIKit

class DataHandler {
    private let context: NSManagedObjectContext

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }

    func processData(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            print("Invalid JSON")
            return
        }

        print("Processing (jsonArray.count) records from JSON.") // Debugging output

        for entry in jsonArray {
            if let position = entry["pos"] as? String,
               let az = entry["az"] as? Float, // Ensure type matches your model
               let postureStatus = entry["p"] as? String {
                let postureData = PostureData(timestamp: Date(), position: position, accelerationZ: az, postureStatus: postureStatus)
                CoreDataHandler.shared.savePostureData(postureData: postureData)
            } else {
                print("Invalid record: (entry)") // Debugging output
            }
        }
    }

    // Function to save PostureData objects into Core Data
    private func saveToCoreData(_ postureDataArray: [PostureData]) {
        for postureData in postureDataArray {
            let coreDataObject = NSEntityDescription.insertNewObject(forEntityName: "PostureEntity", into: context)
            coreDataObject.setValue(postureData.timestamp, forKey: "timestamp")
            coreDataObject.setValue(postureData.position, forKey: "position")
            coreDataObject.setValue(postureData.accelerationZ, forKey: "accelerationZ")
            coreDataObject.setValue(postureData.postureStatus, forKey: "postureStatus")
        }

        do {
            try context.save()
            print("Data saved successfully.")
        } catch {
            print("Failed to save data: (error)")
        }
    }
}
