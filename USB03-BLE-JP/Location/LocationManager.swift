//
//  LocationManager.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    // @Published var currentLocation: CLLocationCoordinate2D?
    @Published var latitude: String = "..."
    @Published var longitude: String = "..."
    @Published var formattedLAT: Int16 = 0
    @Published var formattedLNG: Int16 = 0
    @Published var sunrise: String = "..."
    @Published var sunset: String = "..."

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        // 일출/일몰 시간 계산
        fetchSunriseSunset(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // 위치 계산
        let formattedLatitude = String(format: "%.2f", location.coordinate.latitude)
        let formattedLongitude = String(format: "%.1f", location.coordinate.longitude)
        self.latitude = formattedLatitude
        self.longitude = formattedLongitude
        
        if let LAT = Double(formattedLatitude), let LNG = Double(formattedLongitude) {
            self.formattedLAT = Int16(Int(LAT * 100))
            self.formattedLNG = Int16(Int(LNG * 10))
        }
    }
    
    private func fetchSunriseSunset(latitude: Double, longitude: Double) {
        let urlString = "https://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&formatted=0"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.sunrise = "..."
                    self.sunset = "..."
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(SunriseSunsetResponse.self, from: data)
                DispatchQueue.main.async {
                    self.sunrise = result.results?.sunrise?.formattedDate() ?? "No sunrise data"
                    self.sunset = result.results?.sunset?.formattedDate() ?? "No sunset data"
                }
            } catch {
                DispatchQueue.main.async {
                    self.sunrise = "JSON decode error"
                    self.sunset = "JSON decode error"
                }
            }
        }
        .resume()
    }
    
    struct SunriseSunsetResponse: Codable {
        var results: SunResults?
    }

    struct SunResults: Codable {
        var sunrise: Date?
        var sunset: Date?
    }
}

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

