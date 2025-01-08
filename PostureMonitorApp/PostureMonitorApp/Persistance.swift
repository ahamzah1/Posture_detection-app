//import CoreData
//
//struct PersistenceController {
//    static let shared = PersistenceController()
//    // In-memory context for testing or SwiftUI previews
//    static var preview: PersistenceController = {
//        let controller = PersistenceController(inMemory: true)
//        let viewContext = controller.container.viewContext
//
//
//        return controller
//    }()
//
//    let container: NSPersistentContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "PostureModel")
//
//        if inMemory {
//            let description = NSPersistentStoreDescription()
//            description.type = NSInMemoryStoreType
//            container.persistentStoreDescriptions = [description]
//        }
//
//        container.loadPersistentStores { storeDescription, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            } else{
//                print("Persistent store loaded: \(storeDescription)")
//            }
//        }
//    }
//}
