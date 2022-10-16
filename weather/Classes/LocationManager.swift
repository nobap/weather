//
//  LocationManager.swift
//  weather
//
//  Created by Dmitriy Paranichev on 16.10.2022.
//

import Foundation
import CoreLocation

class LocationManager {
    
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    var locationIsOn: Bool {
        UserDefaults.standard.value(forKey: "isLocation") as? Bool ?? false
    }
    
    //MARK: - inits
    private init() {}
    
    func setLocation(isLocation: Bool) {
        UserDefaults.standard.set(isLocation, forKey: "isLocation")
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
