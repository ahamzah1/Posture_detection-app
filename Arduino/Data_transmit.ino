#include <Wire.h>
#include <MPU6050.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// BLE UUIDs
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHAR1_UUID          "beb5483e-36e1-4688-b7f5-ea07361b26a8"  // Used for sending sensor data

// BLE objects
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
BLE2902* pBLE2902;

bool deviceConnected = false;
bool oldDeviceConnected = false;

// Initialize MPU6050 object
MPU6050 mpu;

// Thresholds for determining good or bad posture based on Z-axis values
const int goodPostureThresholdMin = 2600;
const int goodPostureThresholdMax = 3000;

// BLE Server Callbacks
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};


void setup() {
  Serial.begin(115200);   // Start serial communication
  Wire.begin(21, 22);     // SDA = GPIO 21, SCL = GPIO 22

  // Initialize the MPU6050 sensor
  mpu.initialize();
  if (!mpu.testConnection()) {
    Serial.println("MPU6050 connection failed");
    while (1); // Halt if the sensor is not connected
  }
  Serial.println("MPU6050 connected successfully");

  // Initialize BLE
  BLEDevice::setMTU(512);
  BLEDevice::init("PostureDevice");  // BLE device name
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);

  // Create BLE characteristic for sending sensor data
  pCharacteristic = pService->createCharacteristic(
    CHAR1_UUID,
    BLECharacteristic::PROPERTY_NOTIFY
  );

  // Add descriptor for notification
  pBLE2902 = new BLE2902();
  pBLE2902->setNotifications(true);
  pCharacteristic->addDescriptor(pBLE2902);

  pService->start();
  pServer->getAdvertising()->start();
  Serial.println("Waiting for client to connect...");
}

void loop() {
  // Read accelerometer data from MPU-6050
  int16_t ax, ay, az;
  mpu.getAcceleration(&ax, &ay, &az);

  // Determine posture based on Z-axis value
  bool goodPosture = (az >= abs(goodPostureThresholdMin) && az <= abs(goodPostureThresholdMax));

  // Format posture data into JSON-like string
  String postureData = String("{\"ax\":") + ax +
                       ",\"ay\":" + ay +
                       ",\"az\":" + az +
                       ",\"posture\":\"" + (goodPosture ? "Good" : "Bad") + "\"}";

  // Send data to the connected BLE client (iOS app)
  if (deviceConnected) {
    // String simpleData = "Hello";
    // pCharacteristic->setValue(simpleData.c_str());
    // pCharacteristic->notify();
    pCharacteristic->setValue(postureData.c_str());  // Send posture data
    pCharacteristic->notify();  // Notify connected client
    Serial.println("Data sent: " + postureData);
  }

  // Handle BLE connection status
  if (!deviceConnected && oldDeviceConnected) {
    delay(500); // Allow Bluetooth stack time to clean up
    pServer->startAdvertising(); // Restart advertising
    Serial.println("Restart advertising");
    oldDeviceConnected = deviceConnected;
  }
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }
  // Serial.println(postureData);
  delay(1000);  // Wait for 1 second between readings
}
