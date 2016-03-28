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
    
    let regionRadius: CLLocationDistance = 15000
    @IBOutlet weak var mapView: MKMapView!
    var events = [Event]()
    
    // MARK: - Dummy Data
    
    let event1 = Event(title: "Pick-Up Basketball", date: "3-30-2016", sport: "Basketball", address: "1053 25th Ave East, Seattle, WA", time: "12:00pm", numberOfPlayers: 10)
    let event2 = Event(title: "Sand Volleyball", date: "3-31-2016", sport: "Volleyball", address: "130th Avenue Northeast, Bellevue, WA", time: "2:00pm", numberOfPlayers: 12)
    let event3 = Event(title: "Badminton in the Park", date: "4-2-2016", sport: "Badminton", address: "4311 University Way Northeast, Seattle, WA", time: "1:00pm", numberOfPlayers: 4)
    let event4 = Event(title: "Pick-Up Soccer", date: "3-29-2016", sport: "Soccer", address: "3510 Fremont Avenue North, Seattle, WA", time: "4:00pm", numberOfPlayers: 20)
    let event5 = Event(title: "Ultimate", date: "4-3-2016", sport: "Ultimate Frisbee", address: "Rainier Avenue South, Renton, WA", time: "7:30pm", numberOfPlayers: 12)
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        events.append(event1)
        events.append(event2)
        events.append(event3)
        events.append(event4)
        events.append(event5)
        for i in 0...events.count-1 {
            events[i].geocode(mapView, regionRadius: regionRadius, centeredOnPin: false)
        }
        
        mapView.delegate = self
    }
    
    // MARK: - MapViewAnnotations
    
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
            //make the pin color change depending on the sport
            switch annotation.sport {
                case "Basketball":
                    view.pinTintColor = UIColor.redColor()
                case "Tennis":
                    view.pinTintColor = UIColor.yellowColor()
                case "Softball":
                    view.pinTintColor = UIColor.whiteColor()
                case "Soccer":
                    view.pinTintColor = UIColor.blueColor()
                case "Football":
                    view.pinTintColor = UIColor.blackColor()
                case "Ultimate Frisbee":
                    view.pinTintColor = UIColor.purpleColor()
                case "Volleyball":
                    view.pinTintColor = UIColor.blueColor()
                default:
                    view.pinTintColor = UIColor.grayColor()
                
            }
            
            //need to add switch statment for pin color
            return view
        }
        return nil
    }
    
    // MARK: - Segues
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            let specificEvent = view.annotation as! Event
            performSegueWithIdentifier("showEventDetails", sender: specificEvent)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEventDetails" {
            let controller = segue.destinationViewController as! EventDetailViewController
            controller.eventToDetail = sender as! Event
            
        }
    }
    
}
