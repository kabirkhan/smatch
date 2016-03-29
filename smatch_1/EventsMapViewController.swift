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
    
    var ref = Firebase(url: "https://smatchfirstdraft.firebaseio.com")
    
    //references singleton in UserLocationClass. We will set initial location to the user's location provided by the class
    var locationManager = UserLocation.userLocation
    var initialLocation = CLLocation()
    
    
    let regionRadius: CLLocationDistance = 30000
    @IBOutlet weak var mapView: MKMapView!
    
    //events to display
    var events = [Event]()
    
    //sports the user currently has on their profile
    var profileSports = [AnyObject]()
    
    // MARK: - Dummy Data
    
    let event1 = Event(title: "Pick-Up Basketball", date: NSDate(), sport: "Basketball", address: "1053 25th Ave East, Seattle, WA", numberOfPlayers: 10, gender: Gender.Coed, competition: CompetitionLevel.DoesNotMatter)

    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        events.append(event1)
        
        for i in 0...events.count-1 {
            events[i].geocode(mapView, regionRadius: regionRadius, centeredOnPin: false)
        }
        
        //Set initial Location so it's equal to the user's location (upon opening the app). Then center the map on that location
        
        initialLocation = locationManager.returnLocation()
        centerMapOnLocation(initialLocation, mapView: mapView, regionRadius: regionRadius)
        
        // Firebase - Populate our sports array with the sports the users is subscribed to
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
