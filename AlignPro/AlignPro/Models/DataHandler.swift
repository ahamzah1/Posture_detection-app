import Foundation
import CoreData

class DataHandler {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func processData(_ jsonString: String) {
        // Convert the string to Data
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert string to UTF-8 data")
            return
        }

        do {
            // Parse the JSON into a dictionary
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                for (position, postureStatus) in jsonDict {
                    // Validate fields
                    guard !position.isEmpty, !postureStatus.isEmpty else {
                        print("Invalid or missing data in position or postureStatus")
                        continue
                    }

                    // Create a PostureData object
                    let postureData = PostureData(
                        timestamp: Date(),
                        position: position,
                        postureStatus: postureStatus == "B" ? "Bad" : "Good" // Convert "B" to "Bad" and others to "Good"
                    )

                    // Save to Core Data
                    CoreDataHandler(context: context).savePostureData(postureData: postureData)
                    print("Saved record: \(postureData)")
                }
            } else {
                print("JSON is not a dictionary")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
