// import UIKit
// import CoreData

// @main
// class AppDelegate: UIResponder, UIApplicationDelegate {

//     var window: UIWindow?

//     lazy var persistentContainer: NSPersistentContainer = {
//         let container = NSPersistentContainer(name: "PostureModel")
//         container.loadPersistentStores { _, error in
//             if let error = error as NSError? {
//                 fatalError("Unresolved error \(error), \(error.userInfo)")
//             }
//         }
//         return container
//     }()

//     func saveContext() {
//         let context = persistentContainer.viewContext
//         if context.hasChanges {
//             do {
//                 try context.save()
//             } catch {
//                 let nserror = error as NSError
//                 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//             }
//         }
//     }

//     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//         return true
//     }
// }
