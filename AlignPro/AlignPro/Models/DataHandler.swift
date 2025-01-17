import Foundation
import CoreData

class DataHandler {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func processData(_ jsonString: String) {
//        print("Raw JSON String: \(jsonString)")

        // Convert the string to Data
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert string to UTF-8 data")
            return
        }

        do {
            // Parse the JSON into an array of dictionaries
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for entry in jsonArray {
                    // Extract and validate fields
                    guard let position = entry["pos"] as? String else {
                        print("Invalid or missing 'pos' in record: \(entry)")
                        continue
                    }
                    guard let az = entry["az"] as? Double else {
                        print("Invalid or missing 'az' in record: \(entry)")
                        continue
                    }
                    guard let postureStatus = entry["p"] as? String else {
                        print("Invalid or missing 'p' in record: \(entry)")
                        continue
                    }

                    // If all fields are valid, create a PostureData object
                    let postureData = PostureData(
                        timestamp: Date(),
                        position: position,
                        accelerationZ: Float(az),
                        postureStatus: postureStatus
                    )

                    // Save to Core Data
                    CoreDataHandler(context: context).savePostureData(postureData: postureData)
//                    print("Saved record: \(postureData)")
                }
            } else {
                print("JSON is not an array of dictionaries")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
