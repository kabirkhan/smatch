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

class EventNameViewController: UIViewController, UITextFieldDelegate {
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var newEvent: Event?
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var eventNameTextField: HoshiTextField!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        eventNameTextField.delegate = self
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        Unwrap and check that name field is not empty,
        set values to newEvent and segue to location view.
     */
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        if let name = eventNameTextField.text where name != "" {
            newEvent?.title = "\(newEvent!.sport): \(name)"
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_LOCATION_FROM_NAME, sender: nil)
        } else {
            let alert = showAlert("Oops, you forgot a name", msg: "Please enter another a name for your event")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_NEW_EVENT_TO_LOCATION_FROM_NAME {
            let destinationViewController = segue.destinationViewController as! EventLocationViewController
            destinationViewController.newEvent = newEvent
        }
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Dismiss keyboard when the return is button pressed.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
