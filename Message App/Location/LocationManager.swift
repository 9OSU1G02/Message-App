//
//  LocationManager.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var locationManager: CLLocationManager?
    //to get latitude and lontitude
    var currentLocation: CLLocationCoordinate2D?
    private override init() {
        super.init()
        // Request location access
        requestLocation()
    }
    func requestLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            //How we want accurary of location
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestAlwaysAuthorization()
        }
    }
    
    func startUpdating() {
        locationManager!.startUpdatingLocation()
    }
    
    func stopUpdating() {
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    // MARK: - Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("faild to get location")
    }
    
    //Call every when user location change
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get coordinate of lastest location
        currentLocation = locations.last!.coordinate
    }
    
    //Call when the app creates the location manager and when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //If The user has not chosen whether the app can use location services.
        if manager.authorizationStatus == .notDetermined {
            //--> Request Authorization
            self.locationManager!.requestAlwaysAuthorization()
        }
        else if manager.authorizationStatus == .denied {
            self.locationManager!.requestAlwaysAuthorization()
        }
        
        else if manager.authorizationStatus == .restricted {
            self.locationManager!.requestAlwaysAuthorization()
        }
        
    }
}
