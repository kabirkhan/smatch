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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventToDetail?.geocode(individualMapView, regionRadius: regionRadius, centeredOnPin: true)
    }
}
