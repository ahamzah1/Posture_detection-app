import XCTest
import CoreBluetooth
@testable import PostureMonitorApp // Replace with your app's module name

final class TestBLEManager: XCTestCase, BLEManagerDelegate {
    var bleManager: BLEManager!
    var mockCentralManager: CBCentralManager!
    var mockPeripheral: CBPeripheral!
    var mockCharacteristic: CBCharacteristic!
    var didReceiveDataCalled = false
    var receivedData: String?
    var updatedStatus: String?

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize BLEManager and set the delegate
        bleManager = BLEManager()
        bleManager.delegate = self
    }

    override func tearDownWithError() throws {
        bleManager = nil
        mockCentralManager = nil
        mockPeripheral = nil
        mockCharacteristic = nil
        try super.tearDownWithError()
    }

    // MARK: - BLEManagerDelegate Methods

    func didUpdateStatus(_ status: String) {
        updatedStatus = status
    }

    func didReceiveData(_ data: String) {
        didReceiveDataCalled = true
        receivedData = data
    }

    // Example Test Case
    func testDidUpdateStatus() {
        bleManager.delegate?.didUpdateStatus("Bluetooth is ON.")
        XCTAssertEqual(updatedStatus, "Bluetooth is ON.")
    }

    func testDidReceiveData() {
        bleManager.delegate?.didReceiveData("Test Data")
        XCTAssertTrue(didReceiveDataCalled)
        XCTAssertEqual(receivedData, "Test Data")
    }
}
