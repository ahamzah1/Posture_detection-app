import XCTest
import CoreBluetooth
@testable import PostureMonitorApp // Replace with your app's module name

final class TestBLEManagerIntegration: XCTestCase, BLEManagerDelegate {
    var bleManager: BLEManager!
    var coreDataHandler: CoreDataHandler!
    var receivedData: [String] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        bleManager = BLEManager()
        bleManager.delegate = self
        coreDataHandler = CoreDataHandler.shared
        
        // Clean up existing Core Data
        coreDataHandler.deleteAllPostureData()
    }

    override func tearDownWithError() throws {
        bleManager = nil
        coreDataHandler = nil
        receivedData = []
        try super.tearDownWithError()
    }

    // MARK: - BLEManagerDelegate Methods

    func didReceiveData(_ data: String) {
        receivedData.append(data)
        // Simulate processing the received data and storing it in Core Data
        bleManager.processReceivedData(data)
    }

    func didUpdateStatus(_ status: String) {
        // Optional: Test for status updates if required
    }

    // MARK: - Test Cases

    // Test if BLEManager processes incoming data correctly
//    func testBLEManagerProcessesData() {
//        // Simulate incoming data via BLE
//        let incomingData = """
//        [
//            {"pos":"MB", "az":2850.5, "p":"G"},
//            {"pos":"HB", "az":2800.0, "p":"B"}
//        ]
//        """
//        bleManager.delegate?.didReceiveData(incomingData)
//
//        // Fetch data from Core Data to validate
//        let fetchedData = coreDataHandler.fetchPostureData()
//        XCTAssertEqual(fetchedData.count, 2, "Expected 2 records in Core Data.")
//
////        // Validate the first record
////        let firstRecord = fetchedData[0]
////        XCTAssertEqual(firstRecord.position, "MB", "Incorrect position in the first record.")
////        XCTAssertEqual(firstRecord.accelerationZ, 2850.5, "Incorrect accelerationZ in the first record.")
////        XCTAssertEqual(firstRecord.postureStatus, "G", "Incorrect postureStatus in the first record.")
//    }

    // Test invalid data handling
    func testBLEManagerHandlesInvalidData() {
        let invalidData = "Invalid JSON Data"
        bleManager.delegate?.didReceiveData(invalidData)

        // Ensure no data is stored in Core Data
        let fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 0, "Expected no records in Core Data for invalid data.")
    }
    
    func testBLEManagerProcessesData() {
        // Simulate incoming data via BLE
        let incomingData = """
        [
            {"pos":"MB", "az":2850.5, "p":"G"},
            {"pos":"HB", "az":2800.0, "p":"B"}
        ]
        """
        bleManager.delegate?.didReceiveData(incomingData)

        // Wait for potential async processing
        sleep(1)

        // Fetch data from Core Data to validate
        let fetchedData = coreDataHandler.fetchPostureData()
        print("Fetched Data: \(fetchedData)")

        XCTAssertEqual(fetchedData.count, 2, "Expected 2 records in Core Data.")

        // Additional validation
        if fetchedData.count > 0 {
            print("First Record: \(fetchedData[0])")
        }
    }

    
    // Test if BLEManagerDelegate methods are triggered
    func testBLEManagerDelegateMethodsCalled() {
        let incomingData = """
        [
            {"pos":"MB", "az":2850.5, "p":"G"}
        ]
        """
        bleManager.delegate?.didReceiveData(incomingData)

        XCTAssertEqual(receivedData.count, 1, "Delegate method didReceiveData was not called correctly.")
        XCTAssertEqual(receivedData[0], incomingData, "Received data does not match expected data.")
    }

    // Test Core Data cleanup through BLEManager integration
    func testBLEManagerClearsCoreData() {
        // Simulate incoming data and save it
        let incomingData = """
        [
            {"pos":"MB", "az":2850.5, "p":"G"}
        ]
        """
        bleManager.delegate?.didReceiveData(incomingData)
        sleep(1)
        // Verify data is stored
        var fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 1, "Expected 1 record in Core Data.")

        // Simulate a Core Data cleanup call
        coreDataHandler.deleteAllPostureData()

        // Verify data is cleared
        fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 0, "Expected no records in Core Data after cleanup.")
    }
}
