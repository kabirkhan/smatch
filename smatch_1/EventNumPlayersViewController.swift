//
//  EventNumPlayersViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import TextFieldEffects

class EventNumPlayersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // VARIABLES
    var newEvent: Event?
    var numPlayers: Int?
    var datasource = [Int]() // Int values 2 - 50
    let numberPlayersPickerView = UIPickerView()
    
    @IBOutlet weak var numPlayersTextField: HoshiTextField!
    
    // MARK: ================= VIEW LIFECYCLE ==================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a pickerview
        numberPlayersPickerView.delegate = self
        numberPlayersPickerView.dataSource = self
        numberPlayersPickerView.backgroundColor = UIColor.whiteColor()
        
        // set a toolbar for the pickerview with a done button
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        // create a barbutton for done to dismiss the pickerview
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(EventNumPlayersViewController.donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        // setup the textfield to get information from the pickerview
        numPlayersTextField.inputView = numberPlayersPickerView
        numPlayersTextField.inputAccessoryView = toolBar

        // setup a number of players datasource for the pickeview 2 - 50 players
        for i in 2...50 {
            datasource.append(i)
        }
    }
    
    // MARK: ================= PICKER VIEW DATASOURCE ===================
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(datasource[row])
    }
    
    // MARK: ================= PICKER VIEW DATASOURCE ===================
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        numPlayersTextField.text = String(datasource[row])
        numPlayers = datasource[row]
    }
    
    // MARK: ================= ACTIONS AND SEGUES ===================
    //
    // DISMISS THE PICKER VIEW WHEN IT'S DONE BUTTON IS PRESSED
    func donePicker(sender: UIDatePicker) {
        numPlayersTextField.resignFirstResponder()
    }
    
    // INITIATE THE SEGUE
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        
        if numPlayers != nil {
            newEvent?.numberOfPlayers = String(numPlayers)
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS, sender: nil)
        } else {
            let alert = showErrorAlert("You need some players", msg: "Add an approximate number of players to continue")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS {
            let destinationViewController = segue.destinationViewController as! CreateEventCompetitionViewController
            destinationViewController.newEvent = newEvent
        }
    }
}
