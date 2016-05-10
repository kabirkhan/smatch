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

class EventsMapViewController: UIViewController, CLLocationManagerDelegate {
    
    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    
    let seattle = CLLocation(latitude: 47.61, longitude: -122.33)
    let regionRadius: CLLocationDistance = 30000
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    
    var mySports = [String]()
    var events = [Event]()
    var initialLocation = CLLocation()
    var sports = [String]()
    var filteredSports = [String]()
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        let locationManager = UserLocation.userLocation
        initialLocation = locationManager.returnLocation()
        centerMapOnLocation(seattle, mapView: mapView, regionRadius: regionRadius)
        displayFireBaseEvents()
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        showWithMultipleSelections(sender)
    }
    
    //--------------------------------------------------
    // MARK: - Segues
    //--------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEventDetails" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EventDetailViewController
            controller.eventToDetail = sender as? Event
            controller.delegate = self
        }
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Takes the users sports from the database, then takes all the events from the database.
        If the event is of a sport that the user is subscribed to,
        it will geocode the event on the map.
     */
    func displayFireBaseEvents() {
        let userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        let user = Firebase(url: "https://smatchfirstdraft.firebaseio.com/users/\(userId)")
        user.observeEventType(.Value, withBlock: { snapshot in
            let userSports = snapshot.value.objectForKey("sports")
            self.mySports = userSports as! [String]
            self.sports = userSports as! [String]
            let eventsRef = DataService.ds.REF_EVENTS
            eventsRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { snapshot in
                if let sport = snapshot.value.objectForKey("sport") {
                    for index in self.mySports {
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
    
    /*
        Removes all the pins from the map
     */
    func removeAllGames(){
        for event in self.events {
            event.remove(self.mapView)
        }
    }
    
    /*
        Re geocodes all the events (after filters have been applied).
     */
    func geocodeAllGames(){
        for event in self.events {
            for sport in self.filteredSports {
                if sport == event.sport {
                    event.geocode(self.mapView, regionRadius: self.regionRadius, centeredOnPin: false)
                }
            }
        }
    }
}

//--------------------------------------------------
// MARK: - MKMapView Delegate
//--------------------------------------------------

extension EventsMapViewController: MKMapViewDelegate {
    
    /*
        Creates the annotation for each event with a callout accessory button.
        Different pin colors correspond to different sports.
     */
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
    
    /*
        Segues to the event detail controller when the callout accessory is clicked.
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let specificEvent = view.annotation as! Event
        performSegueWithIdentifier("showEventDetails", sender: specificEvent)
    }
    
    /*
        Centers the map on the users location
     */
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

//--------------------------------------------------
// MARK: - Go Back Delegate
//--------------------------------------------------

extension EventsMapViewController: GoBackDelegate {
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

//--------------------------------------------------
// MARK: - CZPickerView Data Source
//--------------------------------------------------

extension EventsMapViewController: CZPickerViewDataSource {

    /*
        Sets number of rows in the CZ Picker
     */
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        return sports.count
    }
    
    /*
        Sets title of rows in the CZ Picker depending on which sports the user is subscribed to
     */
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return sports[row]
    }
}

//--------------------------------------------------
// MARK: - CZPickerView Delegate
//--------------------------------------------------

extension EventsMapViewController: CZPickerViewDelegate {
    
    /*
        Sets CZ Picker properties
     */
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
    
    /*
        Saves the filtered sports the user selected.
        Then goes through the events and if an event corresponds to one of those sports,
        after the pins are removed from the map, the event will be re geocoded.
     */
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

