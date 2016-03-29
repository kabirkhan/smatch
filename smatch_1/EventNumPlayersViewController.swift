//
//  EventNumPlayersViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class EventNumPlayersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var newEvent: Event?
    var numPlayers: Int?
    var datasource = [Int]() // Int values 2 - 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberPlayersPickerView.delegate = self
        numberPlayersPickerView.dataSource = self
        
        for i in 2...50 {
            datasource.append(i)
        }
    }
    
    @IBOutlet weak var numberPlayersPickerView: UIPickerView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(datasource[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numPlayers = datasource[row]
    }
    
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        
        if numPlayers != nil {
            newEvent?.numberOfPlayers = numPlayers! as! String
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS, sender: nil)
        } else {
            let alert = showErrorAlert("You need some players", msg: "Add an approximate number of players to continue")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! CreateEventCompetitionViewController
        
        destinationViewController.newEvent = newEvent
    }
}
