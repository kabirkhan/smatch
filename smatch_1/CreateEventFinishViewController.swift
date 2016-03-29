//
//  CreateEventFinish.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase

class CreateEventFinishViewController: UIViewController {

    var newEvent: Event?
    var newEventDict: Dictionary<String, String>?
    var newEventArr: [String]?
    
    @IBAction func finishButtonPressed(sender: UIButton) {
        
       
        
        if let event = newEvent {
        
            newEventDict = [
                "sport": event.sport,
                "name": event.title!,
                "description": event.eventDescription!,
                "address": event.address,
                "date": String(event.date),
                "number_of_players": String(event.numberOfPlayers),
                "gender": String(event.gender),
                "competition_level": String(event.competition)
            ]
            
            if let newEventDict = newEventDict {
                DataService.ds.createEvent(newEventDict)
            }
        }
    }
    
    
}
