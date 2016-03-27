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

class EventsMapViewController: UIViewController, MKMapViewDelegate {
    
    var events = [Event]()
    let event1 = Event(description: "Pick-Up Basketball", date: "3-30-2016", sport: "Basketball", address: "1053 25th Ave East, Seattle, WA", time: "12:00pm", numberOfPlayers: 10)
    let event2 = Event(description: "Sand Volleyball", date: "3-31-2016", sport: "Volleyball", address: "130th Avenue Northeast, Bellevue, WA", time: "2:00pm", numberOfPlayers: 12)
    let event3 = Event(description: "Badminton in the Park", date: "4-2-2016", sport: "Badminton", address: "4311 University Way Northeast, Seattle, WA", time: "1:00pm", numberOfPlayers: 4)
    let event4 = Event(description: "Pick-Up Soccer", date: "3-29-2016", sport: "Soccer", address: "3510 Fremont Avenue North, Seattle, WA", time: "4:00pm", numberOfPlayers: 20)
    let event5 = Event(description: "Ultimate", date: "4-3-2016", sport: "Ultimate Frisbee", address: "Rainier Avenue South, Renton, WA", time: "7:30pm", numberOfPlayers: 12)
    
    let regionRadius: CLLocationDistance = 15000
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialLocation = CLLocation(latitude: 47.608013, longitude: -122.335167)
        centerMapOnLocation(initialLocation)
        events.append(event1)
        events.append(event2)
        events.append(event3)
        events.append(event4)
        events.append(event5)
        
        let geocoder = CLGeocoder()
        var placemarkArray = [MKPlacemark]()
        for i in 0...events.count-1 {
            geocoder.geocodeAddressString(events[i].address, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                for placemark in placemarks! {
                    let mkplacemark = MKPlacemark.init(placemark: placemark)
                    placemarkArray.append(mkplacemark)
                }
                
            })
        }
        print("hello \(placemarkArray)")
        mapView.delegate = self
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as?  Event {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation as? MKAnnotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation as? MKAnnotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
}
