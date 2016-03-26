//
//  EventsMapViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/23/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class EventsMapViewController: UIViewController {
    
    var events: [Event]
    let event1 = Event(description: "Pick-Up Basketball", date: "3-30-2016", sport: "Basketball", address: "1053 25th Ave East, Seattle, WA", time: "12:00pm")
    let event2 = Event(description: "Sand Volleyball", date: "3-31-2016", sport: "Volleyball", address: "130th Avenue Northeast, Bellevue, WA", time: "2:00pm")
    let event3 = Event(description: "Badminton in the Park", date: "4-2-2016", sport: "Badminton", address: "4311 University Way Northeast, Seattle, WA", time: "1:00pm")
    let event4 = Event(description: "Pick-Up Soccer", date: "3-29-2016", sport: "Soccer", address: "3510 Fremont Avenue North, Seattle, WA", time: "4:00pm")
    let event5 = Event(description: "Ultimate", date: "4-3-2016", sport: "Ultimate Frisbee", address: "Rainier Avenue South, Renton, WA", time: "7:30pm")
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        events.append(event1)
        events.append(event2)
        events.append(event3)
        events.append(event4)
        events.append(event5)
    }
}
