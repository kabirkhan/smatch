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

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var newEvent: Event?
    var newEventDict: Dictionary<String, AnyObject>?
    var userId = ""
    var users = [String]()
    var events = [String]()
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var sportTextField: HoshiTextField!
    @IBOutlet weak var locationTextField: HoshiTextField!
    @IBOutlet weak var dateAndTimeTextField: HoshiTextField!
    @IBOutlet weak var numPlayersTextField: HoshiTextField!
    @IBOutlet weak var competitivenessTextField: HoshiTextField!
    @IBOutlet weak var coedTextField: HoshiTextField!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Setup TextFields with information from newEvent object.
     */
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
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        When finished button pressed, 
        construct the event dictionary and add it to firebase.
        Add the creator as the creator and an attendee of 
        the new game.
        Add the game to the creator's joined_events.
     */
    @IBAction func finishButtonPressed(sender: UIButton) {
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
            users.append(userId)
        }
        
        if let event = newEvent {
            newEventDict = [
                "sport": event.sport,
                "name": event.title!,
                "address": event.address,
                "date": String(event.date),
                "number_of_players": String(event.numberOfPlayers),
                "gender": String(event.gender),
                "competition_level": String(event.competition),
                "creator_id": userId,
                "attendees": users
            ]
            
            if let newEventDict = newEventDict {
                let eventId = DataService.ds.createEvent(newEventDict)
            
                DataService.ds.REF_USERS.childByAppendingPath(userId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let joined_events = snapshot.value.objectForKey("joined_events") {
                        self.events = joined_events as! [String]
                    } else {
                        self.events = [String]()
                    }
                    
                    self.events.append(eventId)
                    let joinedEvents = ["joined_events": self.events]
                    
                    let user = DataService.ds.REF_USERS.childByAppendingPath(self.userId)
                    
                    user.updateChildValues(joinedEvents)
                    
                    }, withCancelBlock: { (error) in
                        print(error)
                })
            }
        }
    }
}
