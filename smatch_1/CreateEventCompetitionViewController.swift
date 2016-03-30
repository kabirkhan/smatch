//
//  CreateEventCompetitionViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class CreateEventCompetitionViewController: UIViewController {

    var newEvent: Event?
    var competitionLevel: CompetitionLevel?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
   
    @IBAction func createButtonPressed(sender: UIBarButtonItem) {
       
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            competitionLevel = CompetitionLevel.NotCompetitive
        case 2:
            competitionLevel = CompetitionLevel.Competitive
        default:
            competitionLevel = CompetitionLevel.DoesNotMatter
        }
        newEvent?.competition = competitionLevel!.rawValue
        performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_GENDER_FROM_COMPETITION, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_GENDER_FROM_COMPETITION {
            let destinationViewController = segue.destinationViewController as! CreateEventGenderViewController
            destinationViewController.newEvent = newEvent
        }
    }
    
}
