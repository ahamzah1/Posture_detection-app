import SwiftUI
import CoreData
import Combine
import UserNotifications

class BLEViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var statusText: String = "Status: Not Connected"
    @Published var receivedData: String = ""
    @Published var isScanning: Bool = false
    @Published var recentPostureData: [PostureData] = []
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var pairedDevice: BLEDevice?
    @Published var postureScore: Float = 100.0 // ✅ Track overall posture score
    @Published var perSensorBreakdown: [String: Float] = [:] // ✅ Per-sensor breakdown
    @Published var postureTrend: [(Date, Float)] = [] // ✅ Trend data
    @Published var weeklyPostureScores: [(Date, Float)] = [] // ✅ Weekly scores
    private var lastProcessedMinute: Date? // ✅ Stores the last minute checked

    private let sensorNameMapping: [String: String] = [
        "LS": "Left Shoulder",
        "HB": "High Back",
        "MB": "Middle Back",
        "RS": "Right Shoulder"
    ]


    private let bleManager: BLEManager
    private let dataHandler: DataHandler
    private let coreDataHandler: CoreDataHandler
    private let context: NSManagedObjectContext

    @AppStorage("PairedDeviceID") private var savedDeviceID: String?
    @AppStorage("PairedDeviceName") private var savedDeviceName: String?

    private var cancellables = Set<AnyCancellable>()
    private var scoreUpdateTimer: Timer?
    private var lastNotificationTimePerSensor: [String: Date] = [:]
    private let notificationCooldown: TimeInterval = 180 // ✅ 3-minute cooldown per sensor
    @AppStorage("postureThreshold") private var postureThreshold: Int = 40 // ✅ Default threshold is 40%
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true // ✅ Default ON

    
    
    // MARK: - Initializer
    init(context: NSManagedObjectContext) {
        self.context = context
        self.coreDataHandler = CoreDataHandler(context: context)
        self.dataHandler = DataHandler(coreDataHandler: coreDataHandler) // ✅ Processing layer
        self.bleManager = BLEManager()
        
        super.init()
        UNUserNotificationCenter.current().delegate = self
        
        self.bleManager.delegate = self
        setupDataListener()
        requestNotificationPermission()
        loadPairedDevice()
        startLiveScoreUpdates()

    }
    // MARK: - Live Score Update (Every 10 Seconds)
    private func startLiveScoreUpdates() {
        scoreUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.loadPostureDataFromCoreData()
        }
    }

    deinit {
        scoreUpdateTimer?.invalidate()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Notifications enabled" : "⚠️ Notifications disabled")
            }
        }
    }

    // MARK: - Scanning & Pairing Methods
    func startScanning() {
        guard !isScanning else { return }
        discoveredDevices = []
        bleManager.startScan()
        isScanning = true
    }

    func stopScanning() {
        guard isScanning else { return }
        bleManager.stopScan()
        isScanning = false
    }

    func pairWithDevice(_ device: BLEDevice) {
        stopScanning()
        bleManager.pairWithDevice(device)
        pairedDevice = device
        savedDeviceID = device.id.uuidString
        savedDeviceName = device.name
        statusText = "Paired with \(device.name)"
    }

    func unpairDevice() {
        guard let pairedDevice = pairedDevice else { return }
        bleManager.unpairDevice()
        self.pairedDevice = nil
        savedDeviceID = nil
        savedDeviceName = nil
        statusText = "Unpaired from \(pairedDevice.name)"
    }

    func loadPairedDevice() {
        guard let idString = savedDeviceID,
              let name = savedDeviceName,
              let uuid = UUID(uuidString: idString) else { return }

        pairedDevice = BLEDevice(name: name, id: uuid)
        statusText = "Paired with \(name)"
        bleManager.connectToPairedDevice()
    }

    // MARK: - Data Handling
    private func setupDataListener() {
        bleManager.$receivedData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.receivedData = newData
                self?.processReceivedData(newData)
            }
            .store(in: &cancellables)
    }

    private func processReceivedData(_ data: String) {
        guard !data.isEmpty else { return }

        // ✅ Forward raw data to DataHandler (No storing here)
        dataHandler.processData(data)
    }

    func loadPostureDataFromCoreData() {
        let todayStart = Calendar.current.startOfDay(for: Date()) // ✅ Get today's start time

        let fetchedData = coreDataHandler.fetchPostureData().filter { $0.timestamp >= todayStart } // ✅ Fetch all posture data for today

        DispatchQueue.main.async {
            self.recentPostureData = fetchedData
            self.calculatePostureScore()
            self.calculatePerSensorBreakdown() // ✅ Update per-sensor breakdown
            self.calculatePostureTrend() // ✅ Update trend
            self.checkForBadPosture() // ✅ Check for alerts
            self.calculateWeeklyPostureScores() // ✅ Update weekly scores
            print("📌 Loaded \(self.recentPostureData.count) records from Core Data.")
        }
    }

    func deleteAllPostureData() {
        coreDataHandler.deleteAllPostureData()
        recentPostureData = []
        print("🗑️ Deleted all stored posture data to reset aggregation.")
    }

    // MARK: - Posture Analysis & Notifications
    private func checkForBadPosture() {
        guard let latestEntry = recentPostureData.last else {
            print("⚠️ No posture data available for analysis.")
            return
        }

        let currentMinute = Calendar.current.date(bySetting: .second, value: 0, of: latestEntry.timestamp)
        
        // ✅ Ensure posture check runs only for the latest minute
        if let lastMinute = lastProcessedMinute, lastMinute == currentMinute {
            print("🛑 Skipping check: Already processed minute \(lastMinute)")
            return
        }

        lastProcessedMinute = currentMinute // ✅ Update last processed minute
        print("🕒 Processing posture for latest aggregated minute: \(currentMinute!)")

        var badSensors: [String] = []

        // ✅ Filter only the latest minute's data
        let latestMinuteData = recentPostureData.filter {
            Calendar.current.date(bySetting: .second, value: 0, of: $0.timestamp) == currentMinute
        }

        for entry in latestMinuteData {
            let sensor = entry.position
            let badPercentage = entry.badPosturePercentage

            print("🔍 Checking posture for \(sensor) - Bad %: \(badPercentage), Threshold: \(postureThreshold)")

            if badPercentage > Float(postureThreshold), shouldNotifySensor(sensor) {
                print("🚨 Bad posture detected on \(sensor)! Sending notification.")
                badSensors.append(sensor)
            }
        }

        if !badSensors.isEmpty {
            sendPostureNotification(sensors: badSensors)
        } else {
            print("✅ No sensors exceeded threshold, no notification sent.")
        }
    }

    private func shouldNotifySensor(_ sensor: String) -> Bool {
        if let lastNotified = lastNotificationTimePerSensor[sensor] {
            let timeSinceLastNotification = Date().timeIntervalSince(lastNotified)
            print("⏳ Last notification for \(sensor) was \(timeSinceLastNotification) seconds ago (Cooldown: \(notificationCooldown)s)")

            return timeSinceLastNotification > notificationCooldown
        }
        return true
    }

    private func sendPostureNotification(sensors: [String]) {
        if !notificationsEnabled {
            print("🔕 Notifications are disabled. Skipping alert.")
            return
        }

        let sensorList = sensors.map { sensorNameMapping[$0] ?? $0 }.joined(separator: ", ")
        print("🚀 Attempting to send notification for: \(sensorList)")

        let content = UNMutableNotificationContent()
        content.title = "Posture Alert 🚨"
        content.body = "Bad posture detected at: \(sensorList). Adjust your posture!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Notification failed: \(error.localizedDescription)")
                } else {
                    print("✅ Notification sent for: \(sensorList)")
                    for sensor in sensors {
                        self.lastNotificationTimePerSensor[sensor] = Date()
                        print("🕒 Updated last notification time for \(sensor) to \(self.lastNotificationTimePerSensor[sensor]!)")
                    }
                }
            }
        }
    }

    // MARK: - Posture Score Calculation
    private func calculatePostureScore() {
        let totalEntries = recentPostureData.count
        guard totalEntries > 0 else {
            postureScore = 100.0
            return
        }

        let totalBadPercentage = recentPostureData.reduce(0) { $0 + $1.badPosturePercentage }
        postureScore = max(0, 100 - (totalBadPercentage / Float(totalEntries))) // ✅ Score calculation
    }
    // MARK: - Per-Sensor Breakdown Calculation
    private func calculatePerSensorBreakdown() {
        let groupedData = Dictionary(grouping: recentPostureData, by: { $0.position })
        var breakdown: [String: Float] = [:]

        for (sensor, dataEntries) in groupedData {
            let avgBadPercentage = dataEntries.map { $0.badPosturePercentage }.reduce(0, +) / Float(dataEntries.count)
            breakdown[sensor] = avgBadPercentage
        }

        DispatchQueue.main.async {
            self.perSensorBreakdown = breakdown
            print("📊 Per-Sensor Breakdown Updated: \(breakdown)")
        }
    }

    // MARK: - Posture Trend Calculation (Minute-by-Minute Score)
    private func calculatePostureTrend() {
        let groupedByMinute = Dictionary(grouping: recentPostureData, by: {
            Calendar.current.date(bySetting: .second, value: 0, of: $0.timestamp)!
        })
        var trendData: [(Date, Float)] = []

        for (minute, dataEntries) in groupedByMinute {
            let avgBadPercentage = dataEntries.map { $0.badPosturePercentage }.reduce(0, +) / Float(dataEntries.count)
            let score = max(0, 100 - avgBadPercentage)
            trendData.append((minute, score))
        }

        DispatchQueue.main.async {
            self.postureTrend = trendData.sorted(by: { $0.0 < $1.0 })
            print("📈 Posture Trend Updated: \(self.postureTrend)")
        }
    }
    // MARK: - Weekly Posture Scores Calculation
    private func calculateWeeklyPostureScores() {
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today

        let fetchedData = coreDataHandler.fetchPostureData().filter { $0.timestamp >= sevenDaysAgo } // ✅ Fetch full week

        let groupedByDay = Dictionary(grouping: fetchedData, by: { Calendar.current.startOfDay(for: $0.timestamp) })
        
        var weeklyScores: [(Date, Float)] = []

        // ✅ Ensure every day has a value (Default to 100% good posture if missing)
        for i in 0..<7 {
            let day = Calendar.current.date(byAdding: .day, value: -i, to: today) ?? today

            if let dataEntries = groupedByDay[day] {
                let avgBadPercentage = dataEntries.map { $0.badPosturePercentage }.reduce(0, +) / Float(dataEntries.count)
                let score = max(0, 100 - avgBadPercentage)
                weeklyScores.append((day, score))
            } else {
                weeklyScores.append((day, 100)) // ✅ Default score for days with no data
            }
        }

        DispatchQueue.main.async {
            self.weeklyPostureScores = weeklyScores.sorted(by: { $0.0 < $1.0 }) // ✅ Ensure sorted order
            print("📆 Weekly Posture Scores Updated: \(self.weeklyPostureScores)")
        }
    }
    
    
    
}

// MARK: - BLEManagerDelegate
extension BLEViewModel: BLEManagerDelegate {
    func didUpdateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.statusText = "Status: \(status)"
        }
    }

    func didReceiveData(_ data: String) {
        DispatchQueue.main.async {
            self.receivedData += "\(data)"
        }
    }

    func didDiscoverDevice(_ device: BLEDevice) {
        DispatchQueue.main.async {
            if !self.discoveredDevices.contains(where: { $0.id == device.id }) {
                self.discoveredDevices.append(device)
            }
        }
    }
}

extension BLEViewModel: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // ✅ Show notification in foreground
    }
}

