//
//  CreateNewEventViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class CreateNewEventViewController: UIViewController {

    var alert = UIViewController()
    var timer = NSTimer()
    
    // unwind segue to here if you get to the end and save the event
    @IBAction func finishCreatingEvent(segue: UIStoryboardSegue) {
        alert = showErrorAlert("Game Created Successfully!", msg: "View your game in the my events tab")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CreateNewEventViewController.presentAlert), userInfo: nil, repeats: false)
        
    }
    
    // unwind segue if event creation is cancelled at any point
    @IBAction func eventCreationCancelled(segue: UIStoryboardSegue) {
        alert = showErrorAlert("Game Creation Cancelled", msg: "Not right now? Make a game later!")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CreateNewEventViewController.presentAlert), userInfo: nil, repeats: false)
    }
    
    func presentAlert() {
        presentViewController(alert, animated: true, completion: nil)
        timer.invalidate()
    }
    
}
