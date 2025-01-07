import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager()

    private var centralManager: CBCentralManager!
    private var postureDevice: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - CBCentralManagerDelegate Methods

    // Check Bluetooth state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on. Scanning for peripherals...")
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")])
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .unsupported:
            print("Bluetooth is not supported on this device.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unknown:
            print("Bluetooth state is unknown.")
        case .resetting:
            print("Bluetooth is resetting.")
        @unknown default:
            print("An unknown state occurred.")
        }
    }

    // Discover peripherals
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        if peripheral.name == "PostureDevice" {
            postureDevice = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral)
            print("Connecting to \(peripheral.name ?? "PostureDevice")...")
        }
    }

    // Peripheral connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        postureDevice = peripheral
        postureDevice?.delegate = self
        postureDevice?.discoverServices([CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")])
    }

    // Discover services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // Discover characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")
            if characteristic.uuid == CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
                dataCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("Set notify for characteristic \(characteristic.uuid)")
            }
        }
    }

    // Receive data updates
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value, let jsonString = String(data: data, encoding: .utf8) else {
            print("Failed to decode received data.")
            return
        }

        print("Received data: \(jsonString)")
        DataManager.shared.parseAndStoreData(jsonString: jsonString)

        // Notify UI or pass data to a delegate for further handling
        NotificationCenter.default.post(name: Notification.Name("BLEDataReceived"), object: nil, userInfo: ["data": jsonString])
    }

    // Peripheral disconnected
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown"). Retrying connection...")
        centralManager.connect(peripheral)
    }

    // Handle connection failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")
    }
    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")])
            print("Started scanning for devices...")
        } else {
            print("Bluetooth is not powered on")
        }
    }
}
