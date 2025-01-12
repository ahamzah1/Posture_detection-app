import XCTest
import CoreData
@testable import PostureMonitorApp // Replace with your app's module name

final class TestDataHandler: XCTestCase {
    var dataHandler: DataHandler!
    var coreDataHandler: CoreDataHandler!
    var persistentContainer: NSPersistentContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Set up in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "PostureModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to set up in-memory Core Data store: \(error)")
            }
        }

        // Initialize handlers with test context
        let context = persistentContainer.viewContext
        coreDataHandler = CoreDataHandler(context: context)
        dataHandler = DataHandler(context: context)

        // Clean up any pre-existing data
        coreDataHandler.deleteAllPostureData()
    }

    override func tearDownWithError() throws {
        dataHandler = nil
        coreDataHandler = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    // Test processData function in DataHandler
    func testProcessData() {
        let jsonData = """
        [
            {"pos":"MB", "az":2850.5, "p":"G"},
            {"pos":"HB", "az":2800.0, "p":"B"}
        ]
        """

        dataHandler.processData(jsonData)

        let fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 2, "Expected 2 records in Core Data.")

        // Validate the first record
        let firstRecord = fetchedData[0]
        XCTAssertEqual(firstRecord.position, "MB", "Incorrect position in first record.")
        XCTAssertEqual(firstRecord.accelerationZ, 2850.5, "Incorrect accelerationZ in first record.")
        XCTAssertEqual(firstRecord.postureStatus, "G", "Incorrect postureStatus in first record.")
    }

    // Test savePostureData in CoreDataHandler
    func testSavePostureData() {
        let testData = PostureData(
            timestamp: Date(),
            position: "LS",
            accelerationZ: 2900.7,
            postureStatus: "G"
        )

        coreDataHandler.savePostureData(postureData: testData)

        let fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 1, "Expected 1 record in Core Data.")

        let savedRecord = fetchedData[0]
        XCTAssertEqual(savedRecord.position, "LS", "Incorrect position in saved record.")
        XCTAssertEqual(savedRecord.accelerationZ, 2900.7, "Incorrect accelerationZ in saved record.")
        XCTAssertEqual(savedRecord.postureStatus, "G", "Incorrect postureStatus in saved record.")
    }

    // Test fetchPostureData in CoreDataHandler
    func testFetchPostureData() {
        // Insert test data
        let testData1 = PostureData(timestamp: Date(), position: "MB", accelerationZ: 2800.0, postureStatus: "G")
        let testData2 = PostureData(timestamp: Date(), position: "HB", accelerationZ: 2700.0, postureStatus: "B")
        coreDataHandler.savePostureData(postureData: testData1)
        coreDataHandler.savePostureData(postureData: testData2)

        let fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 2, "Expected 2 records in Core Data.")

        // Validate data integrity
        XCTAssertTrue(fetchedData.contains(where: { $0.position == "MB" && $0.accelerationZ == 2800.0 && $0.postureStatus == "G" }))
        XCTAssertTrue(fetchedData.contains(where: { $0.position == "HB" && $0.accelerationZ == 2700.0 && $0.postureStatus == "B" }))
    }

    // Test deleteAllPostureData in CoreDataHandler
    func testDeleteAllPostureData() {
        // Insert test data
        let testData = PostureData(timestamp: Date(), position: "MB", accelerationZ: 2800.0, postureStatus: "G")
        coreDataHandler.savePostureData(postureData: testData)

        var fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 1, "Expected 1 record before deletion.")

        // Perform delete operation
        coreDataHandler.deleteAllPostureData()

        fetchedData = coreDataHandler.fetchPostureData()
        XCTAssertEqual(fetchedData.count, 0, "Expected 0 records after deletion.")
    }
}
