#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// BLE UUIDs
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHAR1_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// BLE objects
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// I2C Bus and MPU6050 sensors
#define SDA2_PIN 25
#define SCL2_PIN 26
TwoWire I2C2 = TwoWire(1);

Adafruit_MPU6050 middleBackSensor;
Adafruit_MPU6050 highBackSensor;
Adafruit_MPU6050 leftShoulderSensor;
Adafruit_MPU6050 rightShoulderSensor;

// Posture thresholds
const int goodPostureThresholdMin = 2600;
const int goodPostureThresholdMax = 3000;

// BLE Server Callbacks
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override { deviceConnected = true; }
  void onDisconnect(BLEServer* pServer) override { deviceConnected = false; }
};

// Function to initialize a sensor
bool initializeSensor(Adafruit_MPU6050& sensor, const char* name, TwoWire* wire = &Wire, uint8_t address = 0x68) {
  if (!sensor.begin(address, wire)) {
    Serial.printf("%s not connected!\n", name);
    return false;
  }
  Serial.printf("%s connected!\n", name);
  return true;
}

// Function to read and process sensor data
String readSensorData(Adafruit_MPU6050& sensor, const char* position) {
  sensors_event_t a, g, temp;
  sensor.getEvent(&a, &g, &temp);

  // Determine posture
  bool goodPosture = (a.acceleration.z >= goodPostureThresholdMin && a.acceleration.z <= goodPostureThresholdMax);

  // Return compact JSON string
  return String("{\"pos\":\"") + position +
         "\",\"az\":" + a.acceleration.z +
         ",\"p\":\"" + (goodPosture ? "G" : "B") + "\"}";
}

// Function to initialize all sensors
void initializeSensors() {
  Wire.begin(21, 22);
  I2C2.begin(SDA2_PIN, SCL2_PIN);

  initializeSensor(middleBackSensor, "Middle Back Sensor");
  initializeSensor(highBackSensor, "High Back Sensor", &Wire, 0x69);
  initializeSensor(leftShoulderSensor, "Left Shoulder Sensor", &I2C2);
  initializeSensor(rightShoulderSensor, "Right Shoulder Sensor", &I2C2, 0x69);
}

void setup() {
  Serial.begin(115200);

  // Initialize sensors
  initializeSensors();

  // Initialize BLE
  BLEDevice::setMTU(512);
  BLEDevice::init("PostureDevice");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(CHAR1_UUID, BLECharacteristic::PROPERTY_NOTIFY);
  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();
  pServer->getAdvertising()->start();
  Serial.println("Waiting for client to connect...");
}

void loop() {
  if (deviceConnected) {
    // Collect data from all sensors
    String postureData = "[" +
                         readSensorData(middleBackSensor, "MB") + "," +
                         readSensorData(highBackSensor, "HB") + "," +
                         readSensorData(leftShoulderSensor, "LS") + "," +
                         readSensorData(rightShoulderSensor, "RS") + "]";

    // Send data via BLE
    pCharacteristic->setValue(postureData.c_str());
    pCharacteristic->notify();
    Serial.println("Data sent: " + postureData);
  }

  // Handle connection state changes
  if (!deviceConnected && oldDeviceConnected) {
    delay(500); // Allow disconnection to complete
    pServer->startAdvertising();
    Serial.println("Restarting advertising...");
    oldDeviceConnected = deviceConnected;
  } else if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  delay(1000); // 1-second interval
}
