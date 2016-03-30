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
    
    // MARK: - Variables and Constants

    //need arrays to hold the user's sports and the events that are of those sports. We dont want to display all the events in the database.
    var mySports = [String]()
    var events = [Event]()
    
    //reference the singleton in UserLocationClass. We will set initial location to the user's location provided by the class
    var locationManager = UserLocation.userLocation
    var initialLocation = CLLocation()
    let regionRadius: CLLocationDistance = 30000
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //Set initial Location so it's equal to the user's location (upon opening the app). Then center the map on that location. Then display the events returned from Firebase on the map.
        
        initialLocation = locationManager.returnLocation()
        centerMapOnLocation(initialLocation, mapView: mapView, regionRadius: regionRadius)
        displayFireBaseEvents()
    }
    
    // MARK: - MapViewAnnotations
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as?  Event {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation as MKAnnotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation as MKAnnotation, reuseIdentifier: identifier)
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
            controller.eventToDetail = sender as? Event
            
        }
    }
    
    // MARK: - Function for Map Centering

    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Firebase
    
    func displayFireBaseEvents() {
        let authData = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        
        //Set mySports - Array of sports the user has on their profile
        
        let user = Firebase(url: "https://smatchfirstdraft.firebaseio.com/users/\(authData)")
        user.observeEventType(.Value, withBlock: { snapshot in
            let userSports = snapshot.value.objectForKey("sports")
            self.mySports = userSports as! [String]
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        //Set events - Array of events that only include events of sports that are inside mySports
        
        let eventsRef = DataService.ds.REF_EVENTS
        eventsRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { snapshot in
            if let sport = snapshot.value.objectForKey("sport") {
                for i in 0...self.mySports.count-1 {
                    
                    //if the sport is one of "mySports" create an event and append it to our events array.
                    
                    if sport as! String == self.mySports[i] {
                        let eventName = snapshot.value.objectForKey("name") as! String
                        let eventAddress = snapshot.value.objectForKey("address") as! String
                        let eventCompetition = snapshot.value.objectForKey("competition_level") as! String
                        let eventDate = snapshot.value.objectForKey("date") as! String
                        let eventGender = snapshot.value.objectForKey("gender") as! String
                        let eventPlayers = snapshot.value.objectForKey("number_of_players") as! String
                        let eventSport = snapshot.value.objectForKey("sport") as! String
                        let newEvent = Event(title: eventName, date: eventDate, sport: eventSport, address: eventAddress, numberOfPlayers: eventPlayers, gender: eventGender, competition: eventCompetition)
                        self.events.append(newEvent)
                    }
                }
            }
            //geocode all the events inside our events array on the mapView
            
            for i in self.events {
                i.geocode(self.mapView, regionRadius: self.regionRadius, centeredOnPin: false)
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
}
