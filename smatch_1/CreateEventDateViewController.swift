//
//  CreateEventDateViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class CreateEventDateViewController: UIViewController {

    var newEvent: Event?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .DateAndTime
    }
    
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        newEvent?.date = NSDateFormatter.localizedStringFromDate(datePicker.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! EventNumPlayersViewController
        destinationViewController.newEvent = newEvent
    }
}
