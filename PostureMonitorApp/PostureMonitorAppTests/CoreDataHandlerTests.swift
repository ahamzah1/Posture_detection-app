import XCTest
@testable import PostureMonitorApp // Replace with your app's module name

final class TestDataHandler: XCTestCase {
    var dataHandler: DataHandler!
    var coreDataHandler: CoreDataHandler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataHandler = DataHandler()
        coreDataHandler = CoreDataHandler.shared
        
        // Clean up existing data in Core Data before tests
        coreDataHandler.deleteAllPostureData()
    }

    override func tearDownWithError() throws {
        dataHandler = nil
        coreDataHandler = nil
        try super.tearDownWithError()
    }

    // Test processData function in DataHandler
    func testProcessData_2() {
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
    
    func testProcessData() {
        // Sample JSON with two records
        let sampleJSON = """
        [
            {"pos":"MB", "az":2600.0, "p":"G"},
            {"pos":"HB", "az":2800.0, "p":"B"}
        ]
        """

        let dataHandler = DataHandler()
        dataHandler.processData(sampleJSON)

        let savedData = CoreDataHandler.shared.fetchPostureData()
        XCTAssertEqual(savedData.count, 2, "Expected 2 records, but found (savedData.count)")
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
