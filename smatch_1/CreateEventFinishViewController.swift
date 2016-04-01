//
//  CreateEventFinish.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  Create the new event, add the user as an attendee of the event, initialize a first message for the event
//  Add a joined events table for the creator of the event and set the first event to be event created

import UIKit
import Firebase
import TextFieldEffects

class CreateEventFinishViewController: UIViewController {

    // MARK: VARIABLES
    var newEvent: Event?
    var newEventDict: Dictionary<String, AnyObject>?
    var userId = ""
    var users = [String]()
    var events = [String]()
    
    // MARK: OUTLETS
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var sportTextField: HoshiTextField!
    @IBOutlet weak var locationTextField: HoshiTextField!
    @IBOutlet weak var dateAndTimeTextField: HoshiTextField!
    @IBOutlet weak var numPlayersTextField: HoshiTextField!
    @IBOutlet weak var competitivenessTextField: HoshiTextField!
    @IBOutlet weak var coedTextField: HoshiTextField!
    
    // MARK: VIEW LIFECYCLE
    // 
    // setup the textfields
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newEvent = newEvent {
            nameTextField.text = newEvent.title
            sportTextField.text = newEvent.sport
            locationTextField.text = newEvent.address
            dateAndTimeTextField.text = String(newEvent.date)
            numPlayersTextField.text = newEvent.numberOfPlayers
            competitivenessTextField.text = String(newEvent.competition)
            coedTextField.text = String(newEvent.gender)
        }
    }
    
    // When finished button pressed, construct the event dictionary and add it to firebase
    @IBAction func finishButtonPressed(sender: UIButton) {
        
        // get the current user's id and set it to userId as the creator of the event
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            
            userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
            users.append(userId)
        }
        
        // unwrap the newEvent Object
        if let event = newEvent {
        
            // construct the event dictionary for entry to firebase
            newEventDict = [
                "sport": event.sport,
                "name": event.title!,
                "address": event.address,
                "date": String(event.date),
                "number_of_players": String(event.numberOfPlayers),
                "gender": String(event.gender),
                "competition_level": String(event.competition),
                "creator_id": userId,
                "attendees": users // creator attends their own event
            ]
            
            // save event to firebase
            if let newEventDict = newEventDict {
                
                // the auto-generated ID for the event
                let eventId = DataService.ds.createEvent(newEventDict)
                
                // observe the most recent addition of events
                //
                // change joined_events to be created_events at some point to handle admin services
                DataService.ds.REF_USERS.childByAppendingPath(userId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let joined_events = snapshot.value.objectForKey("joined_events") {
                        self.events = joined_events as! [String]
                    } else {
                        self.events = [String]()
                    }
                    
                    self.events.append(eventId)
                    let joinedEvents = ["joined_events": self.events]
                    
                    let user = DataService.ds.REF_USERS.childByAppendingPath(self.userId)
                    
                    // update the joined_events key for the current user to reflect they have joind the event
                    user.updateChildValues(joinedEvents)
                    
                    }, withCancelBlock: { (error) in
                        print(error)
                })
            }
        }
    }
}
