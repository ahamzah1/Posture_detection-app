import Foundation
import CoreBluetooth

protocol BLEManagerDelegate: AnyObject {
    func didUpdateStatus(_ status: String)
    func didReceiveData(_ data: String)
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?

    weak var delegate: BLEManagerDelegate?
    private let dataHandler: DataHandler

    var isScanning = false

    private let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")

    override init() {
        self.dataHandler = DataHandler()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    // MARK: - Central Manager Delegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let statusMessage: String
        switch central.state {
        case .poweredOn: statusMessage = "Bluetooth is ON."
        case .poweredOff: statusMessage = "Bluetooth is OFF."
        case .unauthorized: statusMessage = "Bluetooth unauthorized."
        case .unsupported: statusMessage = "Bluetooth unsupported."
        case .resetting: statusMessage = "Bluetooth resetting."
        case .unknown: statusMessage = "Bluetooth unknown state."
        @unknown default: statusMessage = "Bluetooth unknown state."
        }
        delegate?.didUpdateStatus(statusMessage)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        stopScan()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        central.connect(peripheral)
        delegate?.didUpdateStatus("Connecting to \(peripheral.name ?? "Unknown")...")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didUpdateStatus("Connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didUpdateStatus("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didUpdateStatus("Disconnected from \(peripheral.name ?? "Unknown")")
    }

    // MARK: - Peripheral Delegate

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

    // MARK: - Public Methods

    func startScan() {
        guard centralManager.state == .poweredOn else {
            delegate?.didUpdateStatus("Bluetooth is not ready.")
            return
        }
        guard !isScanning else { return }
        isScanning = true
        centralManager.scanForPeripherals(withServices: [serviceUUID])
        delegate?.didUpdateStatus("Scanning for devices...")
    }

    func stopScan() {
        guard isScanning else { return }
        isScanning = false
        centralManager.stopScan()
        delegate?.didUpdateStatus("Scanning stopped.")
    }
    
    func processReceivedData(_ dataString: String) {
        DispatchQueue.global(qos: .background).async {
            self.dataHandler.processData(dataString)
        }
    }

}
