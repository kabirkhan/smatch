//
//  EventDetailViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI

class EventDetailViewController: UIViewController, MKMapViewDelegate {
    var delegate: UITableViewController?
    var eventToDetail: Event?
    @IBOutlet weak var individualMapView: MKMapView!
    let regionRadius: CLLocationDistance = 5000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        individualMapView.setRegion(coordinateRegion, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(eventToDetail!.address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            let placemark = placemarks![0]
            let coordinate = placemark.location!
            self.centerMapOnLocation(coordinate)
            let mkplacemark = MKPlacemark.init(placemark: placemark)
            self.individualMapView.addAnnotation(mkplacemark)
        }
    }
    //Geocode the address and get the coordinates, then set the maps center on those coordinates
   
}
