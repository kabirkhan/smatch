//
//  CreateEventGenderViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class CreateEventGenderViewController: UIViewController {

    var newEvent: Event?
    var gender: Gender?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func finishedButtonPressed(sender: UIBarButtonItem) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            gender = Gender.OnlyGuys
        case 1:
            gender = Gender.OnlyGirls
        default:
            gender = Gender.Coed
        }
        
        newEvent?.gender = gender!
        performSegueWithIdentifier(SEGUE_NEW_EVENT_FINISH_NEW_EVENT, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! CreateEventFinishViewController
        destinationViewController.newEvent = newEvent
    }
}
