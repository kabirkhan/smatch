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
import Firebase

class EventDetailViewController: UIViewController, MKMapViewDelegate {
    
//--------------------------------------------------
// MARK: - Constants
//--------------------------------------------------
    
    let regionRadius: CLLocationDistance = 5000
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    let userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
    
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
    
    @IBOutlet weak var individualMapView: MKMapView!
    @IBOutlet weak var joinButton: MaterialButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var numPlayersLabel: UILabel!
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    
//--------------------------------------------------
// MARK: - View Lifecycle
//--------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        individualMapView.delegate = self
        displayEventInfo()
        reloadView()
        
        // =========== NAVBAR SETUP ==============
        // set navbar fonts
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: fontColor]
        
        // set navbar shadow
        self.navigationController?.navigationBar.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1.0).CGColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.6
        self.navigationController?.navigationBar.layer.shadowRadius = 5.0
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        // set navbar color
        self.navigationController?.navigationBar.barTintColor = UIColor.materialMainGreen
        
        eventToDetail?.geocode(individualMapView, regionRadius: regionRadius, centeredOnPin: true)
        individualMapView.scrollEnabled = false
    }

    
//--------------------------------------------------
// MARK: - Actions
//--------------------------------------------------
    
    @IBAction func joinButtonPressed(sender: UIButton) {
        
        // References in database
        let eventRef = Firebase(url: "https://smatchfirstdraft.firebaseIO.com/events/\(eventToDetail!.eventKey)")
        let userRef = Firebase(url: "https://smatchfirstdraft.firebaseIO.com/users/\(userId)")
        
        switch viewState! {
        case EventDetailViewState.Creator:
            // CREATOR DELETES EVENT
            
            break
        case EventDetailViewState.Attendee:
            // ATTENDEE LEAVES EVENT
            
            var attendees = eventToDetail!.attendees
            var attendeesDict = Dictionary<String, AnyObject>()
            
            attendees = attendees.filter() {$0 != userId}
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
                    
                    // self.alert = showErrorAlert("Joined Successfully", msg: "You joined a new game!")
                    self.viewState = EventDetailViewState.Viewer
                    self.reloadView()
                })
                
            }) { (error) in
                print(error)
            }
            
            // attendee
            break
        default:
            // VIEWER OF EVENT JOINS GAME
            
            // update attendees list to hold current user
            var attendees = eventToDetail!.attendees
            var attendeesDict = Dictionary<String, AnyObject>()
            attendees.append(userId)
            
            attendeesDict["attendees"] = attendees
            eventRef.updateChildValues(attendeesDict)
            eventToDetail!.attendees = attendees
            
            // update user's joined events with current event
            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                var joinedEventsDict = Dictionary<String, AnyObject>()
                var joined_events = [String]()
                
                if let events = snapshot.value.objectForKey("joined_events") {
                    joined_events = events as! [String]
                }
                
                joined_events.append(self.eventToDetail!.eventKey)
                
                joinedEventsDict["joined_events"] = joined_events
                userRef.updateChildValues(joinedEventsDict, withCompletionBlock: { (error, ref) in
                    
                    // self.alert = showErrorAlert("Joined Successfully", msg: "You joined a new game!")
                    self.viewState = EventDetailViewState.Attendee
                    self.reloadView()
                })
                
            }) { (error) in
                print(error)
            }
            break
        }
    }
    
    // Go back to the previous view
    @IBAction func allGamesButtonPressed(sender: UIBarButtonItem) {
        delegate?.goBack(self)
    }
    
//--------------------------------------------------
// MARK: - Segues
//--------------------------------------------------
    
    
    
//--------------------------------------------------
// MARK: - Helper Functions
//--------------------------------------------------
    
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        let mapItem = eventToDetail?.mapItem
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        
        mapItem!.openInMapsWithLaunchOptions(launchOptions)
        
    }
    
    func reloadView() {
        
        let attendees = eventToDetail!.attendees
        let creator = eventToDetail!.creator_id
        
        // user is creator
        if creator == userId {
            
            viewState = EventDetailViewState.Creator
            joinButton.backgroundColor = UIColor.materialCancelRedColor
            joinButton.setTitle("Delete", forState: .Normal)
            
            // user is attendee but not creator
        } else if attendees.contains(userId) {
            
            viewState = EventDetailViewState.Attendee
            joinButton.backgroundColor = UIColor.materialCancelRedColor
            joinButton.setTitle("Leave", forState: .Normal)
            
            // user is neither and can join the game
        } else {
            viewState = EventDetailViewState.Viewer
            joinButton.backgroundColor = UIColor.materialAmberAccent
            joinButton.setTitle("Join", forState: .Normal)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.view.setNeedsDisplay()
        }
    }
    
    func displayEventInfo() {
        nameLabel.text = eventToDetail!.title
        dateAndTimeLabel.text = eventToDetail!.date
        locationLabel.text = eventToDetail!.address
        numPlayersLabel.text = eventToDetail!.numberOfPlayers
        competitionLabel.text = eventToDetail!.competition
        genderLabel.text = eventToDetail?.gender
        sportLabel.text = eventToDetail?.sport
    }
    
}

//--------------------------------------------------
// MARK: - Extensions
//--------------------------------------------------


/*
 Comments
*/


//--------------------------------------------------
// MARK: - Constants
//--------------------------------------------------



//--------------------------------------------------
// MARK: - Variables
//--------------------------------------------------



//--------------------------------------------------
// MARK: - Outlets
//--------------------------------------------------



//--------------------------------------------------
// MARK: - View Lifecycle
//--------------------------------------------------



//--------------------------------------------------
// MARK: - Actions
//--------------------------------------------------



//--------------------------------------------------
// MARK: - Segues
//--------------------------------------------------



//--------------------------------------------------
// MARK: - Helper Functions
//--------------------------------------------------



//--------------------------------------------------
// MARK: - Extensions
//--------------------------------------------------

