//
//  CreateEventGenderViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class CreateEventGenderViewController: UIViewController {

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var newEvent: Event?
    var gender: Gender?
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /* 
        Set gender based on SegmentedControl value
     */
    @IBAction func finishedButtonPressed(sender: UIBarButtonItem) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            gender = Gender.OnlyGuys
        case 2:
            gender = Gender.OnlyGirls
        default:
            gender = Gender.Coed
        }
        newEvent?.gender = gender!.rawValue
        
        performSegueWithIdentifier(SEGUE_NEW_EVENT_FINISH_NEW_EVENT, sender: nil)
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_FINISH_NEW_EVENT {
            let destinationViewController = segue.destinationViewController as! CreateEventFinishViewController
            destinationViewController.newEvent = newEvent
        }
    }
}
