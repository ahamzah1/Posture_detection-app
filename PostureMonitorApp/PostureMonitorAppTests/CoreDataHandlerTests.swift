import XCTest
import CoreData
@testable import PostureMonitorApp

class CoreDataHandlerTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var coreDataHandler: CoreDataHandler!

    override func setUp() {
        super.setUp()

        // Ensure PersistenceController is initialized
        persistenceController = PersistenceController(inMemory: true)
        // Set the context after loading stores
        context = persistenceController.container.viewContext

        // Initialize CoreDataHandler with the test context
        coreDataHandler = CoreDataHandler(context: context)
    }

    override func tearDown() {
        persistenceController = nil
        context = nil
        coreDataHandler = nil
        super.tearDown()
    }

    func testInsertAndFetchPostureData() {
        // Create a test data object
        let testData = PostureData(
            timestamp: Date(),
            position: "MB",
            accelerationZ: -9.81,
            postureStatus: "Good"
        )

        // Insert data into Core Data
        coreDataHandler.insertPostureData(data: testData)

        // Fetch data from Core Data
        let fetchedData = coreDataHandler.fetchPostureData()

        XCTAssertFalse(fetchedData.isEmpty, "Fetched data should not be empty.")
        XCTAssertEqual(fetchedData.last?.position, "MB", "Position should match.")
        XCTAssertEqual(fetchedData.last?.accelerationZ, -9.81, "Acceleration Z should match.")
    }

    func testParseAndStoreData() {
        // JSON string for testing
        let jsonString = """
        [
            {"pos":"MB","az":-9.81,"p":"G"},
            {"pos":"LS","az":-7.00,"p":"B"}
        ]
        """

        // Parse and store the JSON data
        DataManager.shared.parseAndStoreData(jsonString: jsonString)

        // Fetch data from Core Data
        let fetchedData = coreDataHandler.fetchPostureData()

        XCTAssertEqual(fetchedData.count, 2, "There should be 2 records.")
        XCTAssertEqual(fetchedData.first?.position, "MB", "First record's position should match.")
        XCTAssertEqual(fetchedData.last?.position, "LS", "Last record's position should match.")
    }
}
