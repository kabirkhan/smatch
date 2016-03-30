//
//  CreateEventGenderViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class CreateEventGenderViewController: UIViewController {

    // VARIABLES
    var newEvent: Event?
    var gender: Gender?
    
    // OUTLETS
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // get the current value of the segmented control and set gender from it
    @IBAction func finishedButtonPressed(sender: UIBarButtonItem) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            gender = Gender.OnlyGuys
        case 1:
            gender = Gender.OnlyGirls
        default:
            gender = Gender.Coed
        }
        
        newEvent?.gender = gender!.rawValue

        
        performSegueWithIdentifier(SEGUE_NEW_EVENT_FINISH_NEW_EVENT, sender: nil)
    }
    
    // send newEvent to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_FINISH_NEW_EVENT {
            let destinationViewController = segue.destinationViewController as! CreateEventFinishViewController
            destinationViewController.newEvent = newEvent
        }
    }
}
