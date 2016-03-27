//
//  Event.swift
//  smatch_1
//
//  Created by Lucas Huet-Hudson on 3/26/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
import MapKit
import AddressBook
import CoreLocation

class Event: NSObject {
    var descript: String
    var date: String
    var sport: String
    var address: String
    var time: String
    var numberOfPlayers: Int
    var Seattle = CLLocation(latitude: 47.608013, longitude: -122.335167)
    init (description: String, date: String, sport: String, address: String, time: String, numberOfPlayers: Int) {
        self.descript = description
        self.date = date
        self.sport = sport
        self.address = address
        self.time = time
        self.numberOfPlayers = numberOfPlayers
        super.init()
    }
    func geocode(mapView: MKMapView, regionRadius: CLLocationDistance, centeredOnPin: Bool) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            let placemark = placemarks![0]
            let coordinate = placemark.location!
            if centeredOnPin == true {
                 self.centerMapOnLocation(coordinate, mapView: mapView, regionRadius: regionRadius)
            } else {
                 self.centerMapOnLocation(self.Seattle, mapView: mapView, regionRadius: regionRadius)
            }
            let mkplacemark = MKPlacemark.init(placemark: placemark)
            mapView.addAnnotation(mkplacemark)
        }
    }
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
