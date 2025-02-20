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

Adafruit_MPU6050 middleBackSensor, highBackSensor, leftShoulderSensor, rightShoulderSensor;
Adafruit_MPU6050* sensors[4] = { &middleBackSensor, &highBackSensor, &leftShoulderSensor, &rightShoulderSensor };
const char* sensorNames[4] = { "Middle Back", "High Back", "Left Shoulder", "Right Shoulder" };

// Posture thresholds
const int goodPostureThresholdMin = 2600;
const int goodPostureThresholdMax = 3000;
const int badPostureDuration = 5;

// Posture state
struct PostureStatus {
  char middleBack, highBack, leftShoulder, rightShoulder;
} previousPosture = { 'G', 'G', 'G', 'G' }, currentPosture;

int deviationCounters[4] = {0, 0, 0, 0};

// BLE Server Callbacks
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override { deviceConnected = true; }
  void onDisconnect(BLEServer* pServer) override { deviceConnected = false; }
};

// Function to initialize sensors
bool initializeSensor(Adafruit_MPU6050& sensor, const char* name, TwoWire* wire = &Wire, uint8_t address = 0x68) {
  if (!sensor.begin(address, wire)) {
    Serial.printf("%s not connected!\n", name);
    return false;
  }
  Serial.printf("%s connected!\n", name);
  return true;
}

void initializeSensors() {
  Wire.begin(21, 22);
  I2C2.begin(SDA2_PIN, SCL2_PIN);

  for (int i = 0; i < 4; i++) {
    initializeSensor(*sensors[i], sensorNames[i], (i >= 2 ? &I2C2 : &Wire), (i % 2 == 0 ? 0x68 : 0x69));
  }
}

// Function to check posture
char checkPosture(Adafruit_MPU6050& sensor, int sensorIndex) {
  sensors_event_t a, g, temp;
  sensor.getEvent(&a, &g, &temp);

  if (a.acceleration.z < goodPostureThresholdMin || a.acceleration.z > goodPostureThresholdMax) {
    if (++deviationCounters[sensorIndex] >= badPostureDuration) return 'B';
  } else {
    deviationCounters[sensorIndex] = 0;
  }
  return 'G';
}

void handleBLEConnections() {
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    pServer->startAdvertising();
    Serial.println("Restarting advertising...");
  }
  oldDeviceConnected = deviceConnected;
}

void setup() {
  Serial.begin(115200);
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
    bool postureChanged = false;
    char postureArray[4];

    for (int i = 0; i < 4; i++) {
      postureArray[i] = checkPosture(*sensors[i], i);
      if (postureArray[i] != previousPosture.middleBack + i) {
        postureChanged = true;
        *(&previousPosture.middleBack + i) = postureArray[i];
      }
    }

    if (postureChanged) {
      char postureData[50];
      snprintf(postureData, sizeof(postureData), "{\"MB\":\"%c\",\"HB\":\"%c\",\"LS\":\"%c\",\"RS\":\"%c\"}",
               postureArray[0], postureArray[1], postureArray[2], postureArray[3]);
      pCharacteristic->setValue(postureData);
      pCharacteristic->notify();
      Serial.println("Data sent: " + String(postureData));
    }
  }

  handleBLEConnections();
  delay(1000);
}