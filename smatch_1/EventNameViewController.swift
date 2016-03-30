//
//  EventNameViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  User enters a name for their event and optional description

import UIKit
import TextFieldEffects

class EventNameViewController: UIViewController {
    
    // event from last page segue
    var newEvent: Event?
    
    @IBOutlet weak var eventNameTextField: HoshiTextField!
    @IBOutlet weak var eventDescriptionTextField: HoshiTextField!
    
    // MARK: ================== ACTIONS AND SEGUES ==================
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        
        // unwrap and check that name field is not empty, set values to newEvent and segue to location view
        if let name = eventNameTextField.text, description = eventDescriptionTextField.text where name != "" {
            newEvent?.title = "\(newEvent!.sport): \(name)"
            newEvent?.eventDescription = description
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_LOCATION_FROM_NAME, sender: nil)
        } else {
            // name is empty show alert
            let alert = showErrorAlert("Oops, you forgot a name", msg: "Please enter another a name for your event")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_LOCATION_FROM_NAME {
            let destinationViewController = segue.destinationViewController as! EventLocationViewController
            destinationViewController.newEvent = newEvent
        }
    }
}
