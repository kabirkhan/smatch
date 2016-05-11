//
//  EventDetailViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  The detail view for a single event
//  User sees all information and can get directions 

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import Firebase

class EventDetailViewController: UIViewController, MKMapViewDelegate {
    
    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    let regionRadius: CLLocationDistance = 5000
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var eventToDetail: Event?
    var delegate: GoBackDelegate?
    var viewState: EventDetailViewState?
    var alert = UIAlertController()

    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var individualMapView: MKMapView!
    @IBOutlet private weak var joinButton: MaterialButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateAndTimeLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var numPlayersLabel: UILabel!
    @IBOutlet private weak var competitionLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var sportLabel: UILabel!
    
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.applyDefaultShadow(UIColor.materialMainGreen)
        self.navigationController?.navigationBar.setNavbarFonts()
        
        individualMapView.delegate = self
        displayEventInfo()
        reloadView()
        
        eventToDetail?.geocode(individualMapView, regionRadius: regionRadius, centeredOnPin: true)
        individualMapView.scrollEnabled = false
    }

    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        Creator: If user is the creator of the event
        delete the event when they press the button.
     
        Attendee: If the user is a current attendee, remove the user
        from the event and the event from their joined
        events
     
        Viewer: If user is a viewer and joins, add them to the event
        and the event to their joined events.
     */
    @IBAction func joinButtonPressed(sender: UIButton) {
        
        // References in database
        let eventRef = Firebase(url: "https://smatchfirstdraft.firebaseIO.com/events/\(eventToDetail!.eventKey)")
        let userRef = Firebase(url: "https://smatchfirstdraft.firebaseIO.com/users/\(userID)")
        
        switch viewState! {
        case EventDetailViewState.Creator:
            // CREATOR DELETES EVENT
            // Coming Soon!!!
            
            break
        case EventDetailViewState.Attendee:
            // ATTENDEE LEAVES EVENT
            
            var attendees = eventToDetail!.attendees
            var attendeesDict = Dictionary<String, AnyObject>()
            
            attendees = attendees.filter() { $0 != userID }
            attendeesDict["attendees"] = attendees
            eventRef.updateChildValues(attendeesDict)
            eventToDetail!.attendees = attendees
            
            // update user's joined events with current event
            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                var joinedEventsDict = Dictionary<String, AnyObject>()
                var joined_events = [String]()
                let eventId = self.eventToDetail?.eventKey
                
                if let events = snapshot.value.objectForKey("joined_events") {
                    joined_events = events as! [String]
                }
                
                joined_events = joined_events.filter() {$0 != eventId}
                joinedEventsDict["joined_events"] = joined_events
                
                userRef.updateChildValues(joinedEventsDict, withCompletionBlock: { (error, ref) in
                    self.viewState = EventDetailViewState.Viewer
                    self.reloadView()
                })
                
            }) { (error) in
                print(error)
            }
            
            // attendee
            break
        default:
            
            var attendees = eventToDetail!.attendees
            var attendeesDict = Dictionary<String, AnyObject>()
            attendees.append(userID)
            
            attendeesDict["attendees"] = attendees
            eventRef.updateChildValues(attendeesDict)
            eventToDetail!.attendees = attendees
            
            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                var joinedEventsDict = Dictionary<String, AnyObject>()
                var joined_events = [String]()
                
                if let events = snapshot.value.objectForKey("joined_events") {
                    joined_events = events as! [String]
                }
                
                joined_events.append(self.eventToDetail!.eventKey)
                
                joinedEventsDict["joined_events"] = joined_events
                userRef.updateChildValues(joinedEventsDict, withCompletionBlock: { (error, ref) in
                    
                    self.viewState = EventDetailViewState.Attendee
                    self.reloadView()
                })
            }) { (error) in
                print(error)
            }
            break
        }
    }

    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    
    /*
        Go back to the previous view
     */
    @IBAction func allGamesButtonPressed(sender: UIBarButtonItem) {
        delegate?.goBack(self)
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Event {
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
        Reload the button to change based off the user's status.
     */
    func reloadView() {
        
        let attendees = eventToDetail!.attendees
        let creator = eventToDetail!.creator_id
        
        if creator == userID {
            
            viewState = EventDetailViewState.Creator
            joinButton.backgroundColor = UIColor.materialCancelRedColor
            joinButton.setTitle("Delete", forState: .Normal)
        } else if attendees.contains(userID) {
            
            viewState = EventDetailViewState.Attendee
            joinButton.backgroundColor = UIColor.materialCancelRedColor
            joinButton.setTitle("Leave", forState: .Normal)
        } else {
            viewState = EventDetailViewState.Viewer
            joinButton.backgroundColor = UIColor.materialAmberAccent
            joinButton.setTitle("Join", forState: .Normal)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.view.setNeedsDisplay()
        }
    }
    
    /*
        Initialize event information
     */
    func displayEventInfo() {
        nameLabel.text = eventToDetail!.title
        dateAndTimeLabel.text = eventToDetail!.date
        locationLabel.text = eventToDetail!.address
        numPlayersLabel.text = eventToDetail!.numberOfPlayers
        competitionLabel.text = eventToDetail!.competition
        genderLabel.text = eventToDetail?.gender
        sportLabel.text = eventToDetail?.sport
    }
    
    /*
        Get directions when tapping map pin
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let mapItem = eventToDetail?.mapItem
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem!.openInMapsWithLaunchOptions(launchOptions)
    }
}



