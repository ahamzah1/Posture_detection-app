#include <Wire.h>
#include <MPU6050.h>

// Initialize MPU6050 object
MPU6050 mpu;

// Thresholds for determining good or bad posture based on Z-axis values
const int goodPostureThresholdMin = 15000;
const int goodPostureThresholdMax = 18000;

void setup() {
  Serial.begin(115200);  // Start serial communication
  Wire.begin(21, 22);    // SDA = GPIO 21, SCL = GPIO 22

  // Initialize the MPU6050 sensor
  mpu.initialize();
  if (!mpu.testConnection()) {
    Serial.println("MPU6050 connection failed");
    while (1);
  }
  Serial.println("MPU6050 connected successfully");
}

void loop() {
  // Read accelerometer data from MPU-6050
  int16_t ax, ay, az;
  mpu.getAcceleration(&ax, &ay, &az);

  // Determine posture based on Z-axis value
  bool goodPosture = (az >= goodPostureThresholdMin && az <= goodPostureThresholdMax);

  // Output the posture result
  if (goodPosture) {
    Serial.println("Good Posture");
  } else {
    Serial.println("Bad Posture");
  }

  // Print the raw Z-axis value for debugging
  Serial.print("Accel Z: ");
  Serial.println(az);

  delay(1000);  // Wait for 1 second between readings
}