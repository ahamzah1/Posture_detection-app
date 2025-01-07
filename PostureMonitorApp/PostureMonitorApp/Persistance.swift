import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    // In-memory context for testing or SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Add mock data for previews
        for _ in 0..<10 {
            let newItem = PostureEntity(context: viewContext)
            newItem.timestamp = Date()
            newItem.position = "Neutral"
            newItem.accelerationZ = 0.0
            newItem.postureStatus = "Good"
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to save preview data: (error.localizedDescription)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PostureMonitorApp")

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error (error), (error.userInfo)")
            }
        }
    }
}
