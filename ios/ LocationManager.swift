//
//   LocationManager.swift
//  Runner
//
//  Created by Mikir Parekh on 07/09/24.
//

import CoreLocation
import Foundation
import Reachability

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private var reachability: Reachability?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true // Critical for background location updates
        locationManager.pausesLocationUpdatesAutomatically = false // Prevents iOS from pausing updates
        locationManager.startMonitoringSignificantLocationChanges() // To track significant changes even when app is terminated

        // Initialize Reachability
        reachability = try? Reachability()
        reachability?.whenReachable = { [weak self] _ in
            self?.syncOfflineData() // Sync offline data when network becomes reachable
        }
        reachability?.whenUnreachable = { _ in
            // Handle network unreachable case if needed
        }

        // Start monitoring network reachability
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start network reachability notifier")
        }
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let timestamp = Date().timeIntervalSince1970

        if isNetworkAvailable() {
            sendLocationToServer(latitude: latitude, longitude: longitude, timestamp: timestamp)
            syncOfflineData() // Sync stored locations when network is available
        } else {
            saveLocationOffline(latitude: latitude, longitude: longitude, timestamp: timestamp)
        }
    }

    private func sendLocationToServer(latitude: Double, longitude: Double, timestamp: TimeInterval) {
        let url = URL(string: "https://yourapiendpoint.com/location/update")! // Replace with your server's endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let locationData: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": timestamp
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: locationData, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending location: \(error)")
                return
            }

            // Handle success
            print("Location sent successfully!")
        }

        task.resume()
    }

    private func isNetworkAvailable() -> Bool {
        return reachability?.connection != .unavailable
    }

    private func saveLocationOffline(latitude: Double, longitude: Double, timestamp: TimeInterval) {
        var offlineLocations = UserDefaults.standard.array(forKey: "offlineLocations") as? [[String: Any]] ?? []
        let locationData: [String: Any] = ["latitude": latitude, "longitude": longitude, "timestamp": timestamp]
        offlineLocations.append(locationData)
        UserDefaults.standard.set(offlineLocations, forKey: "offlineLocations")
    }

    private func syncOfflineData() {
        guard isNetworkAvailable() else { return }

        var offlineLocations = UserDefaults.standard.array(forKey: "offlineLocations") as? [[String: Any]] ?? []
        for location in offlineLocations {
            if let latitude = location["latitude"] as? Double,
               let longitude = location["longitude"] as? Double,
               let timestamp = location["timestamp"] as? TimeInterval {
                // Send each location to the server
                sendLocationToServer(latitude: latitude, longitude: longitude, timestamp: timestamp)
            }
        }
        // Clear offline data after sync
        UserDefaults.standard.removeObject(forKey: "offlineLocations")
    }
}

