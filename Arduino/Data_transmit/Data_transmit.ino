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
const int badPostureDuration = 5; // seconds

// Posture state and timers
char previousPosture[4] = {'G', 'G', 'G', 'G'};
int deviationCounters[4] = {0, 0, 0, 0};

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

// Function to check posture with deviation logic
char checkPosture(Adafruit_MPU6050& sensor, int sensorIndex) {
  sensors_event_t a, g, temp;
  sensor.getEvent(&a, &g, &temp);

  if (a.acceleration.z < goodPostureThresholdMin || a.acceleration.z > goodPostureThresholdMax) {
    deviationCounters[sensorIndex]++;
    if (deviationCounters[sensorIndex] >= badPostureDuration) {
      return 'B'; // Bad posture
    }
  } else {
    deviationCounters[sensorIndex] = 0; // Reset counter if back within range
  }
  return 'G'; // Good posture
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
    // Check posture for each sensor
    char currentPosture[4];
    currentPosture[0] = checkPosture(middleBackSensor, 0);
    currentPosture[1] = checkPosture(highBackSensor, 1);
    currentPosture[2] = checkPosture(leftShoulderSensor, 2);
    currentPosture[3] = checkPosture(rightShoulderSensor, 3);

    // Only send data if there is a change in posture status
    if (currentPosture[0] != previousPosture[0] ||
        currentPosture[1] != previousPosture[1] ||
        currentPosture[2] != previousPosture[2] ||
        currentPosture[3] != previousPosture[3]) {
      
      String postureData = String("{\"MB\":\"") + currentPosture[0] +
                           "\",\"HB\":\"" + currentPosture[1] +
                           "\",\"LS\":\"" + currentPosture[2] +
                           "\",\"RS\":\"" + currentPosture[3] + "\"}";

      pCharacteristic->setValue(postureData.c_str());
      pCharacteristic->notify();
      Serial.println("Data sent: " + postureData);

      // Update previous posture states
      for (int i = 0; i < 4; i++) {
        previousPosture[i] = currentPosture[i];
      }
    }
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