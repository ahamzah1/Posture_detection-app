import Foundation
import CoreBluetooth
import CoreData
import Combine

protocol BLEManagerDelegate: AnyObject {
    func didUpdateStatus(_ status: String)
    func didReceiveData(_ data: String)
    func didDiscoverDevice(_ device: BLEDevice)
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - Properties
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?

    private var cancellables = Set<AnyCancellable>()
    
    @Published var receivedData: String = ""
    @Published var discoveredDevices: [BLEDevice] = []
    
    weak var delegate: BLEManagerDelegate?
    
    private var pairedDeviceID: UUID? {
        get {
            if let storedID = UserDefaults.standard.string(forKey: "PairedDeviceID") {
                return UUID(uuidString: storedID)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue?.uuidString, forKey: "PairedDeviceID")
        }
    }
    
    var isScanning = false
    
    // Bluetooth Identifiers
    private let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    
    // MARK: - Initializer
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    // MARK: - Public Methods
    func startScan() {
        guard centralManager.state == .poweredOn else {
            delegate?.didUpdateStatus("Bluetooth is not ready.")
            return
        }
        guard !isScanning else { return }
        isScanning = true
        discoveredDevices = []
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        delegate?.didUpdateStatus("Scanning for devices...")
    }
    
    func stopScan() {
        guard isScanning else { return }
        isScanning = false
        centralManager.stopScan()
        delegate?.didUpdateStatus("Scanning stopped.")
    }
    
    func pairWithDevice(_ device: BLEDevice) {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [device.id]).first else {
            delegate?.didUpdateStatus("Device not found for pairing.")
            return
        }
        stopScan()
        pairedDeviceID = device.id
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(peripheral)
        delegate?.didUpdateStatus("Pairing with \(device.name)...")
    }
    
    func unpairDevice() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        }
        pairedDeviceID = nil
        delegate?.didUpdateStatus("Device unpaired.")
    }
    
    func connectToPairedDevice() {
        guard let pairedID = pairedDeviceID else {
            delegate?.didUpdateStatus("No paired device found.")
            return
        }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [pairedID])
        if let peripheral = peripherals.first {
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
            centralManager.connect(peripheral)
            delegate?.didUpdateStatus("Connecting to paired device: \(peripheral.name ?? "Unknown")")
        } else {
            delegate?.didUpdateStatus("Paired device not found.")
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let statusMessage: String
        switch central.state {
        case .poweredOn:
            statusMessage = "Bluetooth is ON."
            connectToPairedDevice()
        case .poweredOff:
            statusMessage = "Bluetooth is OFF. Please turn it on."
        case .unauthorized:
            statusMessage = "Bluetooth is unauthorized. Check permissions."
        case .unsupported:
            statusMessage = "Bluetooth is not supported on this device."
        case .resetting:
            statusMessage = "Bluetooth is resetting."
        case .unknown:
            statusMessage = "Bluetooth state is unknown."
        @unknown default:
            statusMessage = "Bluetooth state is unknown."
        }
        delegate?.didUpdateStatus(statusMessage)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? "Unknown Device"
        let device = BLEDevice(name: deviceName, id: peripheral.identifier)
        
        DispatchQueue.main.async {
            if !self.discoveredDevices.contains(where: { $0.id == device.id }) {
                self.discoveredDevices.append(device)
                self.delegate?.didDiscoverDevice(device)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didUpdateStatus("Connected to \(peripheral.name ?? "Unknown Device") ✅")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            delegate?.didUpdateStatus("Failed to discover services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else {
            delegate?.didUpdateStatus("No services found on device.")
            return
        }

        for service in services {
            if service.uuid == serviceUUID {
                peripheral.delegate = self // ✅ Ensure delegate is set before discovering characteristics
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }

        delegate?.didUpdateStatus("✅ Services discovered successfully.")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            delegate?.didUpdateStatus("Failed to discover characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            delegate?.didUpdateStatus("No characteristics found for service (service.uuid).")
            return
        }

        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                dataCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic) // ✅ Enable notifications
                delegate?.didUpdateStatus("✅ Listening for posture data... 🎧")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            delegate?.didUpdateStatus("Failed to read characteristic: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value,
              let dataString = String(data: data, encoding: .utf8) else {
            delegate?.didUpdateStatus("Invalid data received.")
            return
        }
        
        DispatchQueue.main.async {
            self.receivedData = dataString
        }
        delegate?.didReceiveData(dataString)
    }
}
