import SwiftUI
import CoreData

class BLEViewModel: ObservableObject {
    @Published var statusText: String = "Status: Not Connected"
    @Published var receivedData: String = ""
    @Published var isScanning: Bool = false
    @Published var recentPostureData: [PostureData] = [] // For displaying the saved data

    private let bleManager: BLEManager
    private let coreDataHandler: CoreDataHandler

    init(context: NSManagedObjectContext) {
        let dataHandler = DataHandler(context: context) // Pass context to DataHandler
        self.bleManager = BLEManager(dataHandler: dataHandler) // Pass DataHandler to BLEManager
        self.coreDataHandler = CoreDataHandler(context: context) // Core Data handler for fetching data
        bleManager.delegate = self
    }

    func toggleScan() {
        if isScanning {
            bleManager.stopScan()
            isScanning = false
        } else {
            bleManager.startScan()
            isScanning = true
        }
    }

    func fetchRecentPostureData() {
        // Filter records saved in the last 5 minutes
        let now = Date()
        let fiveMinutesAgo = now.addingTimeInterval(-300) // 300 seconds = 5 minutes
        recentPostureData = coreDataHandler.fetchPostureData().filter { $0.timestamp >= fiveMinutesAgo }
    }
    
    func deleteAllData() {
            coreDataHandler.deleteAllPostureData()
            recentPostureData = [] // Clear in-memory data
            print("All posture data deleted.")
        }
    
}

extension BLEViewModel: BLEManagerDelegate {
    func didUpdateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.statusText = "Status: \(status)"
        }
    }

    func didReceiveData(_ data: String) {
        DispatchQueue.main.async {
            self.receivedData += "\(data)"
        }
    }
}
