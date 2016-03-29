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
import Firebase

class EventsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //need to create an array that holds all the sports the person has added. Should be in their Firebase AuthData
    
    // MARK: - Variables and Constants
    
    var ref = Firebase(url: "https://smatchfirstdraft.firebaseio.com")
    var locationManager = UserLocation.userLocation
    var initialLocation = CLLocation()
    let regionRadius: CLLocationDistance = 30000
    @IBOutlet weak var mapView: MKMapView!
    var events = [Event]()
    var profileSports = [AnyObject]()
    
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
        
        //Set up the User's Location. Prompts them to allow us to access if they havent already
        
        initialLocation = locationManager.returnLocation()
        centerMapOnLocation(initialLocation, mapView: mapView, regionRadius: regionRadius)
        
        //Firebase
        let authData = ref.authData.uid
        let user = Firebase(url: "https://smatchfirstdraft.firebaseio.com/users/\(authData)/sports")
        print(user)
        user.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            self.profileSports.append(snapshot.value)
        })
        print(profileSports)
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
                view.rightCalloutAccessoryView?.tintColor = UIColor.materialMainGreen
            }
            //make the pin color change depending on the sport
            switch annotation.sport {
                case "Basketball":
                    view.pinTintColor = UIColor.redColor()
                case "Tennis":
                    view.pinTintColor = UIColor.materialMainGreen
                case "Softball":
                    view.pinTintColor = UIColor.materialAmberAccent
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
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EventDetailViewController
            controller.eventToDetail = sender as! Event
            
        }
    }
    
    // MARK: - Function for Map Centering

    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
