//
//  EventNumPlayersViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import TextFieldEffects

class EventNumPlayersViewController: UIViewController {

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var newEvent: Event?
    var numPlayers = 0
    var datasource = [Int]() // Int values 2 - 50
    let numberPlayersPickerView = UIPickerView()
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var numPlayersTextField: HoshiTextField!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Setup PickerView and its Datasource.
        Setup TextField to have PickerView as its InputView
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberPlayersPickerView.delegate = self
        numberPlayersPickerView.dataSource = self
        numberPlayersPickerView.backgroundColor = UIColor.whiteColor()
        
        let toolBar = UIToolbar()
        toolBar.setDefaultStyleWithTintColor()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EventNumPlayersViewController.donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        for i in 2...50 {
            datasource.append(i)
        }
        
        numPlayersTextField.inputView = numberPlayersPickerView
        numPlayersTextField.inputAccessoryView = toolBar
        numPlayersTextField.text = String(datasource[0])
        numPlayers = Int(numPlayersTextField.text!)!
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        if numPlayers != 0 {
            newEvent!.numberOfPlayers = String(numPlayers)
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS, sender: nil)
        } else {
            let alert = showAlert("You need some players", msg: "Add an approximate number of players to continue")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS {
            let destinationViewController = segue.destinationViewController as! CreateEventCompetitionViewController
            destinationViewController.newEvent = newEvent
        }
    }
}

//--------------------------------------------------
// MARK: - PickerView DataSource
//--------------------------------------------------
extension EventNumPlayersViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(datasource[row])
    }
}

//--------------------------------------------------
// MARK: - PickerView Delegate
//--------------------------------------------------
extension EventNumPlayersViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numPlayersTextField.text = String(datasource[row])
        numPlayers = datasource[row]
    }
    
    /*
        Dismiss Picker when done button pressed
     */
    func donePicker(sender: UIDatePicker) {
        numPlayersTextField.resignFirstResponder()
    }
}
