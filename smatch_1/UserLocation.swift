//
//  LocationManager.swift
//  smatch_1
//
//  Created by Lucas Huet-Hudson on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    
    let manager = CLLocationManager()
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    
    static var userLocation = UserLocation()
    var initialLocation = CLLocation()
    
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    
    private override init(){
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Saves the coordinates of the user location
     */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if initialLocation != locations[0] {
            initialLocation = locations[0]
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    /*
        Runs once the authorization status changes (after the user enables location services)
     */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    /*
        Returns initial location, which stores the user location
     */
    func returnLocation() -> CLLocation {
        return initialLocation
    }
    
}





    