# background_location_plus

![Pub Version](https://img.shields.io/pub/v/background_location_plus?color=blue)
![Likes](https://img.shields.io/pub/likes/background_location_plus)
![Popularity](https://img.shields.io/pub/popularity/background_location_plus)
![Points](https://img.shields.io/pub/points/background_location_plus)
![License](https://img.shields.io/badge/license-MIT-green)

A Flutter plugin for reliable **foreground and background location tracking** on iOS and Android.  
Designed for apps that require precise, continuous geolocation such as delivery, workforce tracking, attendance, trip logging, field services, and more.

---

## ✨ Features

- High-accuracy location updates  
- Background location tracking (iOS & Android)  
- Low battery consumption  
- Stream-based API  
- Fully customizable  
- Production-ready  
- Works with minimized, locked, or inactive apps  
- Safe iOS background mode setup included  

---

## 📦 Installation


Add to your `pubspec.yaml`:

```yaml
dependencies:
  background_location_plus: ^0.0.1
```

##  Run
```sh
    flutter pub get
```

### 🔧 iOS Setup (Required)

1. Add permissions to Info.plist

```xml
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Your location is used to track your trips.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Your location is used even in background.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Your location is used even when the app is closed.</string>
```
2. Enable Background Modes

```dif
    Open Xcode → Runner → Signing & Capabilities → + Capability:
    Location updates
    Background processing
```


### 🔧 Android Setup (Required)
Add these permissions inside android/app/src/main/AndroidManifest.xml:
```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
```

```xml
<service
    android:name="com.your_package.background_location_plus.LocationService"
    android:foregroundServiceType="location" />
```

### 🧪 Example App
    Check the /example folder for full working code.

## 📝 Roadmap
    Geofence support
    Activity recognition
    Custom update intervals
    Android foreground notification customization

## ❤️ Contributing
    Pull requests are welcome.
    Please open an issue if you find a bug or require a feature.

## 📄 License
    MIT License — see LICENSE file.


