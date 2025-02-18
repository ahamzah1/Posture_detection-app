import SwiftUI
import CoreData

class BLEViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var statusText: String = "Status: Not Connected"
    @Published var receivedData: String = ""
    @Published var isScanning: Bool = false
    @Published var recentPostureData: [PostureData] = []
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var pairedDevice: BLEDevice?

    private let bleManager: BLEManager
    private let coreDataHandler: CoreDataHandler
    private let context: NSManagedObjectContext

    @AppStorage("PairedDeviceID") private var savedDeviceID: String?
    @AppStorage("PairedDeviceName") private var savedDeviceName: String?

    // MARK: - Initializer
    init(context: NSManagedObjectContext) {
        self.context = context
        let dataHandler = DataHandler(context: context)
        self.bleManager = BLEManager(dataHandler: dataHandler)
        self.coreDataHandler = CoreDataHandler(context: context)
        self.bleManager.delegate = self

        // Load previously paired device, if any
        loadPairedDevice()
    }

    // MARK: - Scanning Methods
    func startScanning() {
        guard !isScanning else { return }
        discoveredDevices = [] // Clear previous scan results
        bleManager.startScan()
        isScanning = true
    }

    func stopScanning() {
        guard isScanning else { return }
        bleManager.stopScan()
        isScanning = false
    }

    // MARK: - Pairing Methods
    func pairWithDevice(_ device: BLEDevice) {
        stopScanning()
        bleManager.pairWithDevice(device)
        pairedDevice = device
        savedDeviceID = device.id.uuidString
        savedDeviceName = device.name
        statusText = "Paired with \(device.name)"
    }

    func unpairDevice() {
        guard let pairedDevice = pairedDevice else { return }
        bleManager.unpairDevice()
        self.pairedDevice = nil
        savedDeviceID = nil
        savedDeviceName = nil
        statusText = "Unpaired from \(pairedDevice.name)"
    }

    func loadPairedDevice() {
        guard let idString = savedDeviceID,
              let name = savedDeviceName,
              let uuid = UUID(uuidString: idString) else { return }

        pairedDevice = BLEDevice(name: name, id: uuid)
        statusText = "Paired with \(name)"
        bleManager.connectToPairedDevice()
    }

    // MARK: - Data Methods
    func fetchRecentPostureData() {
        let today = Calendar.current.startOfDay(for: Date())
        recentPostureData = coreDataHandler.fetchPostureData().filter { $0.timestamp >= today }
    }

    func deleteAllData() {
        coreDataHandler.deleteAllPostureData()
        recentPostureData = []
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

    func didDiscoverDevice(_ device: BLEDevice) {
        DispatchQueue.main.async {
            if !self.discoveredDevices.contains(where: { $0.id == device.id }) {
                self.discoveredDevices.append(device)
            }
        }
    }
}
