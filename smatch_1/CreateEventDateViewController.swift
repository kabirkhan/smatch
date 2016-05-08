//
//  CreateEventDateViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import TextFieldEffects

class CreateEventDateViewController: UIViewController {

    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    let datePicker = UIDatePicker()
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var newEvent: Event?
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet weak var dateAndTimeTextField: HoshiTextField!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Setup DatePicker
        Set TextField to use DatePicker as InputView
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.setDefaultStyleWithTintColor()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventDateViewController.donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        datePicker.datePickerMode = .DateAndTime
        datePicker.minimumDate = NSDate(timeIntervalSinceNow: 21600)
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.addTarget(self, action: #selector(CreateEventDateViewController.datePickerDidChange(_:)), forControlEvents: .ValueChanged)
        
        dateAndTimeTextField.inputView = datePicker
        dateAndTimeTextField.inputAccessoryView = toolBar
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        if let date = dateAndTimeTextField.text where date != "" {
            newEvent?.date = date
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE, sender: nil)
        } else {
            let alert = showAlert("You need a date!", msg: "Your new game needs a date and time for people to show up!")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE {
            let destinationViewController = segue.destinationViewController as! EventNumPlayersViewController
            destinationViewController.newEvent = newEvent
        }
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
     Hide DatePicker when done button pressed
     */
    func donePicker(sender: UIDatePicker) {
        dateAndTimeTextField.resignFirstResponder()
    }
    
    /*
     Update TextField when DatePicker changes
     */
    func datePickerDidChange(sender: UIDatePicker) {
        dateAndTimeTextField.text = NSDateFormatter.localizedStringFromDate(sender.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
}
