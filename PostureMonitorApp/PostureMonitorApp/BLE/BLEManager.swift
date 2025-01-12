import Foundation
import CoreBluetooth
import CoreData

protocol BLEManagerDelegate: AnyObject {
    func didUpdateStatus(_ status: String)
    func didReceiveData(_ data: String)
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?

    weak var delegate: BLEManagerDelegate?
    private let dataHandler: DataHandler // Dependency Injection

    var isScanning = false

    private let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    private let targetDeviceName = "PostureDevice" // Replace with your device's name

    // MARK: - Initializer
    init(dataHandler: DataHandler) {
        self.dataHandler = dataHandler
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    // MARK: - Start Scanning
    func startScan() {
        guard centralManager.state == .poweredOn else {
            delegate?.didUpdateStatus("Bluetooth is not ready.")
            return
        }
        guard !isScanning else { return }

        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        delegate?.didUpdateStatus("Scanning for devices...")
    }

    // MARK: - Stop Scanning
    func stopScan() {
        guard isScanning else { return }

        isScanning = false
        centralManager.stopScan()
        delegate?.didUpdateStatus("Scanning stopped.")
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let statusMessage: String
        switch central.state {
        case .poweredOn:
            statusMessage = "Bluetooth is ON."
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
        print("Discovered device: \(peripheral.name ?? "Unknown") with RSSI: \(RSSI)")
        print("Advertisement Data: \(advertisementData)")

        // Filter by target device name
        guard let name = peripheral.name, name == targetDeviceName else {
            print("Device \(peripheral.name ?? "Unknown") does not match target device name \(targetDeviceName)")
            return
        }

        print("Target device \(name) found. Stopping scan and connecting...")
        stopScan()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        central.connect(peripheral)
        delegate?.didUpdateStatus("Connecting to (name)...")
    }
    

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didUpdateStatus("Connected to \(peripheral.name ?? "Unknown Device")")
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didUpdateStatus("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didUpdateStatus("Disconnected from \(peripheral.name ?? "Unknown Device")")
    }

    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            delegate?.didUpdateStatus("Failed to discover services: \(error.localizedDescription)")
            return
        }

        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            delegate?.didUpdateStatus("Service UUID not found.")
            return
        }
        peripheral.discoverCharacteristics([characteristicUUID], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            delegate?.didUpdateStatus("Failed to discover characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            delegate?.didUpdateStatus("Characteristic UUID not found.")
            return
        }

        dataCharacteristic = characteristic
        peripheral.setNotifyValue(true, for: characteristic)
        delegate?.didUpdateStatus("Listening for data...")
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

        delegate?.didReceiveData(dataString)
        DispatchQueue.global(qos: .background).async {
            self.dataHandler.processData(dataString)
        }
    }
}
