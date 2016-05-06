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
import CZPicker

class EventsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GoBackDelegate {
    
    // MARK: - Variables and Constants

    //need arrays to hold the user's sports and the events that are of those sports. We dont want to display all the events in the database.
    var mySports = [String]()
    var events = [Event]()
    
    //reference the singleton in UserLocationClass. We will set initial location to the user's location provided by the class
    var initialLocation = CLLocation()
    let regionRadius: CLLocationDistance = 30000
    @IBOutlet weak var mapView: MKMapView!
    

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    override func viewDidAppear(animated: Bool) {
        //Set initial Location so it's equal to the user's location (upon opening the app). Then center the map on that location. Then display the events returned from Firebase on the map.
        let locationManager = UserLocation.userLocation
        initialLocation = locationManager.returnLocation()
        let seattle = CLLocation(latitude: 47.61, longitude: -122.33)
        centerMapOnLocation(seattle, mapView: mapView, regionRadius: regionRadius)
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
                    view.pinTintColor = UIColor.yellowColor()
                case "Soccer":
                    view.pinTintColor = UIColor.cyanColor()
                case "Football":
                    view.pinTintColor = UIColor.orangeColor()
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

    
    // MARK: - Function for Map Centering

    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Firebase
    
    func displayFireBaseEvents() {
        
        let userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        
        //Set mySports - Array of sports the user has on their profile
        
        let user = Firebase(url: "https://smatchfirstdraft.firebaseio.com/users/\(userId)")
        user.observeEventType(.Value, withBlock: { snapshot in
            let userSports = snapshot.value.objectForKey("sports")
            self.mySports = userSports as! [String]
            self.sports = userSports as! [String]
            
            //Set events - Array of events that only include events of sports that are inside mySports
            let eventsRef = DataService.ds.REF_EVENTS
            eventsRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { snapshot in
                if let sport = snapshot.value.objectForKey("sport") {
                    for index in self.mySports {
                        
                        //if the sport is one of "mySports" create an event and append it to our events array.
                        
                        if sport as! String == index {
                            
                            let eventName = snapshot.value.objectForKey("name") as! String
                            let eventKey = snapshot.key
                            let eventAddress = snapshot.value.objectForKey("address") as! String
                            let eventCompetition = snapshot.value.objectForKey("competition_level") as! String
                            let eventDate = snapshot.value.objectForKey("date") as! String
                            let eventGender = snapshot.value.objectForKey("gender") as! String
                            let eventPlayers = snapshot.value.objectForKey("number_of_players") as! String
                            let eventSport = snapshot.value.objectForKey("sport") as! String
                            let eventAttendees = snapshot.value.objectForKey("attendees") as! [String]
                            let eventCreatorId = snapshot.value.objectForKey("creator_id") as! String
                            
                            let newEvent = Event(title: eventName, eventKey: eventKey, date: eventDate, sport: eventSport, address: eventAddress, numberOfPlayers: eventPlayers, gender: eventGender, competition: eventCompetition, attendees: eventAttendees, creator_id: eventCreatorId)
                            self.events.append(newEvent)
                        }
                    }
                }
                
                //geocode all the events inside our events array on the mapView
                for index in self.events {
                    index.geocode(self.mapView, regionRadius: self.regionRadius, centeredOnPin: false)
                }
                }, withCancelBlock: { error in
                    print(error.description)
            })
            }, withCancelBlock: { error in
                print(error.description)
        })
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
            controller.delegate = self

        }
    }
    
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - CZPicker
    var sports = [String]()
    var filteredSports = [String]()
    func showWithMultipleSelections(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Sports", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.allowMultipleSelection = true
        picker.headerBackgroundColor = UIColor.materialAmberAccent
        picker.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker.cancelButtonNormalColor = UIColor.blackColor()
        picker.confirmButtonNormalColor = UIColor.whiteColor()
        picker.checkmarkColor = UIColor.materialMainGreen
        picker.show()
    }
    @IBAction func filterButtonClicked(sender: AnyObject) {
        showWithMultipleSelections(sender)
    }
        func removeAllGames(){
            print("removing")
            for event in self.events {
                event.remove(self.mapView)
            }
        }
    
        func geocodeAllGames(){
            print("geocoding")
            for event in self.events {
                for sport in self.filteredSports {
                    if sport == event.sport {
                        print(event.title)
                        event.geocode(self.mapView, regionRadius: self.regionRadius, centeredOnPin: false)
                    }
                }
            }
        }
}
extension EventsMapViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        return sports.count
    }
    
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return sports[row]
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        filteredSports = [String]()
        for row in rows {
            if let row = row as? Int {
                filteredSports.append(sports[row])
            }
        }
        removeAllGames()
        geocodeAllGames()
    }
}
