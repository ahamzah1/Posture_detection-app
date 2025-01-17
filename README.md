# Posture Detection App

## Overview

The **Posture Detection App** is  designed to monitor and improve user posture using an **ESP32 microcontroller** paired with **four sensors**. This app captures real-time posture data, sends it to an iOS app for display, and stores it in local CoreData for immediate analysis. Long-term posture trends are further analyzed using **machine learning** (ML) models supplied by an external backend, offering insightful feedback on posture improvements over time.

In addition to its posture-tracking capabilities, the app features **secure login functionality**, integrated with a robust external backend to handle user authentication and data management.

---

## Features

- **Real-time Posture Monitoring:**  
  Data from four sensors connected to an ESP32 is continuously monitored and transmitted to the iOS app, providing real-time feedback on posture.

- **Local Data Storage:**  
  The app stores posture data locally using **CoreData**, allowing users to track their current trends, monitor improvements, and review posture performance over time.

- **Long-term Trend Analysis with Machine Learning:**  
  An advanced **machine learning model** analyzes stored posture data from the app's backend, offering long-term posture trends and insights into user progress.

- **User Authentication:**  
  Secure login functionality powered by an external backend. Users can securely log in to the app, ensuring their posture data is personal and protected.

- **External Backend Integration:**  
  The app communicates with a dedicated backend that not only handles machine learning for long-term trend analysis but also manages user data and authentication, ensuring a seamless experience for the end-user.

---

## Technology Stack

- **Hardware:**
  - **ESP32 Microcontroller**: Utilized for real-time sensor data collection and communication with the iOS app.
  - **Four Sensors**: Collect posture data to be sent to the mobile app.

- **Software:**
  - **iOS App** (Swift): The primary mobile application that displays posture data, trends, and long-term analysis.
  - **CoreData**: Local data storage to manage user posture data and trends.
  - **Machine Learning Model**: Analyzes posture trends based on historical data and provides long-term posture feedback.
  - **External Backend**: Powers authentication and machine learning model integration, ensuring smooth data synchronization and user management.

---

## Key Features in Detail

### Posture Data Collection & Display
- The app uses **ESP32** to collect real-time data from four sensors placed at various points to detect the user's posture. 
- The data is sent to the iOS app where users can view their posture in real-time, along with relevant feedback.

### Long-Term Trend Analysis with ML
- By utilizing a **machine learning model** hosted on an external backend, the app can predict and display long-term trends in the user’s posture.
- The machine learning model uses data collected from previous sessions to generate valuable insights and make suggestions for improving posture.

### Secure User Authentication
- The app supports a secure login system, ensuring that each user’s posture data remains private.
- **Backend authentication** verifies the user’s credentials and manages the user data securely, with features like token-based authentication.

### CoreData Integration
- Posture data, including trends and daily measurements, are saved locally using **CoreData**.
- This allows users to access their most recent posture information and review past data without requiring a constant internet connection.

---

## How It Works

1. **Posture Data Collection**: The ESP32 collects data from the sensors and sends it to the iOS app.
2. **Local Data Storage**: The iOS app stores this data in **CoreData** to maintain a local record of the user’s posture.
3. **Trend Analysis**: The app then communicates with an external backend, where a **machine learning model** analyzes the data and provides long-term insights.
4. **Login and Authentication**: Users can securely log into the app, ensuring their posture data remains private and accessible only to them.

---

## Setup and Installation

### iOS App Setup

1. Clone the repository:

2. Open the `Posture_Detection-App.xcodeproj` in Xcode.

3. Ensure the project is linked with the necessary dependencies (CoreData, external backend, etc.).

4. Connect the ESP32 hardware with the app via Bluetooth or Wi-Fi.

5. Run the app on your iOS device for real-time posture monitoring and data tracking.

---

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

## Acknowledgments

- **ESP32** for the hardware and sensor integration.
- **CoreData** for local data storage.
- **Machine Learning Model** for long-term analysis.
- **External Backend** for user management and data analysis.

---

This **Posture Detection App** offers a powerful and efficient way for users to monitor and improve their posture using advanced hardware and software technologies. By combining real-time data collection, long-term trend analysis, secure user authentication, and local storage with **CoreData**, this app provides an all-in-one solution for posture health and improvement.
