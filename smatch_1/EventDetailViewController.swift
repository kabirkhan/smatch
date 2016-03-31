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
    
    // MARK: ================== VARIABLES =====================
    var eventToDetail: Event?
    var userId: String?
    var delegate: GoBackDelegate?
    
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    
    // MARK: ================== OUTLETS =====================
    @IBOutlet weak var individualMapView: MKMapView!
    let regionRadius: CLLocationDistance = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // get user's id if stored in defaults which it has to be to get here
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String?
        }
        
        eventToDetail?.geocode(individualMapView, regionRadius: regionRadius, centeredOnPin: true)
    }
    
    // MARK: ==================== ACTIONS AND SEGUES =====================
    @IBAction func joinButtonPressed(sender: UIButton) {
        
        // Get userId from User Defaults
        let userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
        
        // References in database
        print(userId)
        print(eventToDetail!.eventKey as String)
        
        let eventRef = Firebase(url: "https://smatchfirstdraft.firebaseIO.com/events/\(eventToDetail!.eventKey)")
        let userRef = Firebase(url: "https://smatchfirstdraft.firebaseIO.com/users/\(userId)")
        
        // update attendees list to hold current user
        eventRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            var attendeesDict = Dictionary<String, AnyObject>()
            print(snapshot)
            print(snapshot.value)
            var attendees = snapshot.value.objectForKey("attendees") as! [String]
            attendees.append(userId)
            
            attendeesDict["attendees"] = attendees
            eventRef.updateChildValues(attendeesDict)
            
            }) { (error) in
                print(error)
        }
        
        // update user's joined events with current event
        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            var joinedEventsDict = Dictionary<String, AnyObject>()
            print(snapshot)
            print(snapshot.value)
            
            var joined_events = [String]()
            
            if let events = snapshot.value.objectForKey("joined_events") {
                joined_events = events as! [String]
            }
            
            joined_events.append(self.eventToDetail!.eventKey)
            
            joinedEventsDict["joined_events"] = joined_events
            userRef.updateChildValues(joinedEventsDict)
            
        }) { (error) in
            print(error)
        }
    }
    
    // Go back to the previous view
    @IBAction func allGamesButtonPressed(sender: UIBarButtonItem) {
        
        delegate?.goBack(self)
    }
    
}
