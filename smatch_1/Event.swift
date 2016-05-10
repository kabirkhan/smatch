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
import Contacts
import CoreLocation

class Event: NSObject, MKAnnotation {
    
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
    var subtitle: String? {
        return address
    }
    var coordinate = CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661)
    var mapItem: MKMapItem?
    
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
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Creates link to Apple Maps that loads when the callout button is clicked
     */
    func mapItem(coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    /*
        Takes the event address and geocodes it into usable coordinates, then adds an annotation for each pin
     */
    func geocode(mapView: MKMapView, regionRadius: CLLocationDistance, centeredOnPin: Bool) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if let placemark = placemarks?[0] {
                
                self.coordinate = placemark.location!.coordinate
                self.mapItem = self.mapItem(self.coordinate)
                if centeredOnPin == true {
                    self.centerMapOnLocation(placemark.location!, mapView: mapView, regionRadius: regionRadius)
                }
                mapView.addAnnotation(self)
            }
        }
    }
    
    /*
        Centers the map on inout coordinates
     */
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /*
        Removes the annotation from the map
     */
    func remove(mapView: MKMapView) {
        mapView.removeAnnotation(self)
    }
}
