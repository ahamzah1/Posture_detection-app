import XCTest
import CoreBluetooth
import CoreData
@testable import PostureMonitorApp // Replace with your app's module name

final class TestBLEManagerIntegration: XCTestCase, BLEManagerDelegate {
    var bleManager: BLEManager!
    var dataHandler: DataHandler!
    var coreDataHandler: CoreDataHandler!
    var persistentContainer: NSPersistentContainer!
    var receivedData: [String] = []

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Set up an in-memory Core Data stack
        persistentContainer = NSPersistentContainer(name: "PostureModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to set up in-memory Core Data store: \(error)")
            }
        }

        // Initialize CoreDataHandler with the in-memory context
        let context = persistentContainer.viewContext
        coreDataHandler = CoreDataHandler(context: context)

        // Initialize DataHandler with CoreDataHandler dependency
        dataHandler = DataHandler(context: context)

        // Initialize BLEManager with DataHandler dependency
        bleManager = BLEManager(dataHandler: dataHandler)
        bleManager.delegate = self

        // Clean Core Data before tests
        coreDataHandler.deleteAllPostureData()
    }

    override func tearDownWithError() throws {
        bleManager = nil
        dataHandler = nil
        coreDataHandler = nil
        persistentContainer = nil
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

    func testBLEManagerProcessesData() throws {
        // Simulate incoming data via BLE
        let incomingData = """
        [
            {"pos":"MB", "az":2850.5, "p":"G"},
            {"pos":"HB", "az":2800.0, "p":"B"}
        ]
        """
        bleManager.delegate?.didReceiveData(incomingData)

        // Wait for asynchronous processing
        let expectation = self.expectation(description: "Core Data save completion")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Fetch data from Core Data to validate
        let fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 2, "Expected 2 records in Core Data.")

        // Validate the first record
        let firstRecord = fetchedData[0]
        XCTAssertEqual(firstRecord.position, "MB", "Incorrect position in first record.")
        XCTAssertEqual(firstRecord.accelerationZ, 2850.5, "Incorrect accelerationZ in first record.")
        XCTAssertEqual(firstRecord.postureStatus, "G", "Incorrect postureStatus in first record.")
    }

    func testBLEManagerHandlesInvalidData() {
        let invalidData = "Invalid JSON Data"
        bleManager.delegate?.didReceiveData(invalidData)

        // Ensure no data is stored in Core Data
        let fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 0, "Expected no records in Core Data for invalid data.")
    }

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

    func testBLEManagerClearsCoreData() {
        // Simulate incoming data and save it
        let incomingData = """
        [
            {"pos":"MB", "az":2850.5, "p":"G"}
        ]
        """
        bleManager.delegate?.didReceiveData(incomingData)

        // Wait for asynchronous processing
        let expectation = self.expectation(description: "Core Data save completion")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

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
