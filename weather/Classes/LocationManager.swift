//
//  LocationManager.swift
//  weather
//
//  Created by Dmitriy Paranichev on 16.10.2022.
//

import Foundation
import CoreLocation

enum LocationKeys: String {
    case isLocation
}

class LocationManager {
    
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    var locationIsOn: Bool {
        UserDefaults.standard.value(forKey: LocationKeys.isLocation.rawValue) as? Bool ?? false
    }
    
    private init() {}
    
    func setLocation(isLocation: Bool) {
        UserDefaults.standard.set(isLocation, forKey: LocationKeys.isLocation.rawValue)
    }
    
    func authLocation(for object: CLLocationManagerDelegate) {
        self.locationManager.delegate = object
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
}
