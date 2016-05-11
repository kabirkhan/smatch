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
    private let regionRadius: CLLocationDistance = 5000
    private let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var eventToDetail: Event?
    var delegate: GoBackDelegate?
    private var viewState: EventDetailViewState?
    private var alert = UIAlertController()

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
        
        switch viewState! {
        /*
            User is the Event Creator
         */
        case .Creator:
            DataService.ds.getReferenceForEvent(eventToDetail!.eventKey).removeValue()
            DataService.ds.updateUserJoinedEvents(self.eventToDetail!, viewState: self.viewState!, userID: self.userID, completion: { (error) in })
            delegate?.goBack(self)
        /*
            User Attendee or Viewer.
            Handle Joining and leaving the event.
         */
        default:
            DataService.ds.updateEventAttendees(self.eventToDetail!, viewState: self.viewState!, userID: self.userID, completion: { (event) in
                self.eventToDetail = event
            })
            DataService.ds.updateUserJoinedEvents(self.eventToDetail!, viewState: self.viewState!, userID: self.userID, completion: { (error) in
                
                if error != nil {
                    var alertMessage = ""
                    switch self.viewState! {
                    case .Attendee:
                        alertMessage = "join"
                    case .Viewer:
                        alertMessage = "leave"
                    default: break
                    }
                    self.alert = showAlert("Couldn't \(alertMessage) this game", msg: "Please try again later")
                    self.presentViewController(self.alert, animated: true, completion: nil)
                } else {
                    self.viewState = .Viewer
                    self.reloadView()
                }
            })
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
        return setupMapViewPins(mapView, annotation: annotation)
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



