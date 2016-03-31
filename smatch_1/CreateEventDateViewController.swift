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

    var newEvent: Event?
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var dateAndTimeTextField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup datepicker
        datePicker.datePickerMode = .DateAndTime
        datePicker.minimumDate = NSDate(timeIntervalSinceNow: 21600) // need to give at least 6 hours notice for game
        datePicker.backgroundColor = UIColor.whiteColor()
        
        datePicker.addTarget(self, action: #selector(CreateEventDateViewController.datePickerDidChange(_:)), forControlEvents: .ValueChanged)
        
        // set a toolbar for the pickerview with a done button
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        // create a barbutton for done to dismiss the pickerview
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(CreateEventDateViewController.donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        // when textfield selected, activate datepicker
        dateAndTimeTextField.inputView = datePicker
        dateAndTimeTextField.inputAccessoryView = toolBar
    }
    
    func donePicker(sender: UIDatePicker) {
        dateAndTimeTextField.resignFirstResponder()
    }
    
    func datePickerDidChange(sender: UIDatePicker) {
        dateAndTimeTextField.text = NSDateFormatter.localizedStringFromDate(sender.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
    
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        newEvent?.date = NSDateFormatter.localizedStringFromDate(datePicker.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE {
            let destinationViewController = segue.destinationViewController as! EventNumPlayersViewController
            destinationViewController.newEvent = newEvent
        }
    }
}
