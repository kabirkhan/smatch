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
    
//--------------------------------------------------
// MARK: - Constants
//--------------------------------------------------
    
    
    
//--------------------------------------------------
// MARK: - Variables
//--------------------------------------------------
    
    var title: String?
    var eventKey: String
    var date: String
    var sport: String
    var address: String
    var numberOfPlayers: String
    var gender: String
    var competition: String
    var attendees: [String]
    var creator_id: String
    //subtitle and title are used for the annotations
    var subtitle: String? {
        return address
    }
    var coordinate = CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661)
    var mapItem: MKMapItem?
    
//--------------------------------------------------
// MARK: - Outlets
//--------------------------------------------------
    
    
    
//--------------------------------------------------
// MARK: - View Lifecycle
//--------------------------------------------------
    
    init (title: String, eventKey: String, date: String, sport: String, address: String, numberOfPlayers: String, gender: String, competition: String, attendees: [String], creator_id: String) {
        self.title = title
        self.eventKey = eventKey
        self.date = date
        self.sport = sport
        self.address = address
        self.numberOfPlayers = numberOfPlayers
        self.gender = gender
        self.competition = competition
        self.attendees = attendees
        self.creator_id = creator_id
        super.init()
    }
    
//--------------------------------------------------
// MARK: - Actions
//--------------------------------------------------
    
    
    
//--------------------------------------------------
// MARK: - Segues
//--------------------------------------------------
    
    
    
//--------------------------------------------------
// MARK: - Helper Functions
//--------------------------------------------------
    
    func geocode(mapView: MKMapView, regionRadius: CLLocationDistance, centeredOnPin: Bool) {
        
        // Create a CoreLocation Geocoder
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            //address has been geocoded into a placemark for use. This is the first entry in the placemark array.
            if let placemark = placemarks?[0] {
                
                self.coordinate = placemark.location!.coordinate
                self.mapItem = self.mapItem(self.coordinate)
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
    }
    
    func mapItem(coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    //function called from geocode()
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func remove(mapView: MKMapView) {
        mapView.removeAnnotation(self)
    }
    
}

//--------------------------------------------------
// MARK: - Extensions
//--------------------------------------------------
