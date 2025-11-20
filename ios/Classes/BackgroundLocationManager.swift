import Foundation
import CoreLocation
import Flutter
import UIKit

class BackgroundLocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = BackgroundLocationManager()
    private let manager = CLLocationManager()
    private var timeInterval: Int = 0
    private var lastSentTime: TimeInterval = 0
    private(set) var isRunning: Bool = false
    var eventSink: FlutterEventSink?

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
    }

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .authorizedAlways:
            completion(true)

        case .authorizedWhenInUse:
            // Hay que pedir Always
            manager.requestAlwaysAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let newStatus: CLAuthorizationStatus
                if #available(iOS 14.0, *) {
                    newStatus = self.manager.authorizationStatus
                } else {
                    newStatus = CLLocationManager.authorizationStatus()
                }
                completion(newStatus == .authorizedAlways)
            }

        case .notDetermined:
            manager.requestAlwaysAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let newStatus: CLAuthorizationStatus
                if #available(iOS 14.0, *) {
                    newStatus = self.manager.authorizationStatus
                } else {
                    newStatus = CLLocationManager.authorizationStatus()
                }
                completion(newStatus == .authorizedAlways)
            }

        default:
            completion(false)
        }
    }

    func configure(with args: [String: Any]) {
        if let df = args["distanceFilter"] as? Double {
            manager.distanceFilter = df
        }

        if let interval = args["timeInterval"] as? Int {
            self.timeInterval = interval
        }

        if let acc = args["accuracy"] as? String {
            switch acc {
                case "best": manager.desiredAccuracy = kCLLocationAccuracyBest
                case "balanced": manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                case "low": manager.desiredAccuracy = kCLLocationAccuracyKilometer
                default: break
            }
        }
    }


    func start() {
        guard !isRunning else { return }

        isRunning = true
        manager.startUpdatingLocation()

        print("📍 BackgroundLocationManager: STARTED")
    }

    func stop() {
        guard isRunning else { return }

        isRunning = false
        manager.stopUpdatingLocation()

        print("📍 BackgroundLocationManager: STOPPED")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRunning else { return }
        guard let loc = locations.last else { return }

        // ---- TIME INTERVAL FILTER ----
        if timeInterval > 0 {
            let now = Date().timeIntervalSince1970
            if lastSentTime > 0 && (now - lastSentTime) < Double(timeInterval) {
                return   // saltar update si no ha pasado el tiempo
            }
            lastSentTime = now
        }


        // ---- BUILD LOCATION PAYLOAD ----
        let data: [String: Any] = [
            "latitude": loc.coordinate.latitude,
            "longitude": loc.coordinate.longitude,
            "accuracy": loc.horizontalAccuracy,
            "speed": loc.speed,
            "timestamp": loc.timestamp.timeIntervalSince1970
        ]

        eventSink?(data)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
}
