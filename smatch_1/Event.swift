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

class Event: NSObject, MKAnnotation {
    
    // MARK: - Variables and Initialization
    
    var title: String?
    var eventDescription: String?
    var date: NSDate
    var sport: String
    var address: String
    var numberOfPlayers: Int
    var gender: Gender
    var competition: CompetitionLevel
    
    //subtitle and title are used for the annotations
    var subtitle: String? {
        return address
    }
    var coordinate = CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661)
    
    //variable for seattle in order to center the large map on it. need to set up grabbing users location
    
    var Seattle = CLLocation(latitude: 47.608013, longitude: -122.335167)
    init (title: String, date: NSDate, sport: String, address: String,numberOfPlayers: Int, gender: Gender, competition: CompetitionLevel) {
        self.title = title
        self.date = date
        self.sport = sport
        self.address = address
        self.numberOfPlayers = numberOfPlayers
        self.gender = gender
        self.competition = competition
        super.init()
    }
    
    
    // MARK: - Map Functions
    
    
    func geocode(mapView: MKMapView, regionRadius: CLLocationDistance, centeredOnPin: Bool) {
        
        // Create a CoreLocation Geocoder
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            //address has been geocoded into a placemark for use. This is the first entry in the placemark array.
            let placemark = placemarks![0]
            self.coordinate = placemark.location!.coordinate
            if centeredOnPin == true {
                //run when we want to center the map on the pin itself
                self.centerMapOnLocation(placemark.location!, mapView: mapView, regionRadius: regionRadius)
            } else {
                // This only applies to the Map View with all of the pins on the same map. At some point we would probably want to change this over to being centered on the users location rather than self.Seattle
//                self.centerMapOnLocation(self.Seattle, mapView: mapView, regionRadius: regionRadius)
            }
            mapView.addAnnotation(self)
        }
    }
    
    //function called from geocode()
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
