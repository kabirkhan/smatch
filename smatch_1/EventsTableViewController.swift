//
//  EventsTableViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/23/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import CZPicker

class EventsTableViewController: UITableViewController {
    
    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    
    let regionRadius: CLLocationDistance = 10000
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    
    var factory = [Event]()
    var sports = [String]()
    var filter = String()
    var bool = false
    var choices = ["Sports", "Gender", "Competitiveness Level"]
    var genders = ["Coed", "Only Guys", "Only Girls"]
    var competitiveness = ["Does Not Matter", "Not Competitive", "Competitive"]
    var filteredSports = [String]()
    var filteredGenders = ["Coed", "Only Guys", "Only Girls"]
    var filteredCompetitiveness = ["Does Not Matter", "Not Competitive", "Competitive"]
    var pickerWithImage: CZPickerView?
    var query: UInt?
    var events = [Event]()
    
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "EventTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "event_cell")
        tableView.contentInset = UIEdgeInsetsMake(0, 0, -50, 0)
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        sports = [String]()
        filteredSports = [String]()
        filteredGenders = ["Coed", "Only Guys", "Only Girls"]
        filteredCompetitiveness = ["Does Not Matter", "Not Competitive", "Competitive"]
        factory = [Event]()
        events = [Event]() 
        
        displayFireBaseEvents()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if query != nil {
            DataService.ds.REF_EVENTS.removeAllObservers()
        }
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    @IBAction func filterButtonClicked(sender: AnyObject) {
        showWithOneSelectionFilters(sender)
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_event_detail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EventDetailViewController
            controller.eventToDetail = sender as? Event
            controller.delegate = self
        }
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Takes the users sports from the database, then takes all the events from the database.
        If the event concerns a sport that the user is subscribed to,
        it will add the event to the array of events that are made into table cells.
     */
    func displayFireBaseEvents() {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
        query = DataService.ds.getReferenceForUser(userID).observeEventType(.Value, withBlock: { snapshot in
            self.events = [Event]()
            let userSports = snapshot.value.objectForKey("sports") as! [String]
            self.sports = userSports
            self.filteredSports = userSports
            
            DataService.ds.getFirebaseEventsWithUserSports(self.sports, completion: { (events, error) in
                if error != nil {
                    let alert = showAlert("Error Getting Data", msg: "Sorry we couldn't query your events. Please Try again later")
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    guard let events = events else { return }
                    self.events = events
                    self.factory = events
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            })
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
}

//--------------------------------------------------
// MARK: - Go Back Delegate
//--------------------------------------------------

extension EventsTableViewController: GoBackDelegate {
    
    /*
        Allows the user to go back to the current controller page from the event detail
     */
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

//--------------------------------------------------
// MARK: - Table View Data Source
//--------------------------------------------------

extension EventsTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_FOR_EVENT_CELL) as! EventCell
        cell.eventNameLabel.text = events[indexPath.row].title
        cell.eventLocationLabel.text = events[indexPath.row].address
        cell.dateLabel.text = events[indexPath.row].date
        events[indexPath.row].geocode(cell.eventMapView, regionRadius: regionRadius, centeredOnPin: true)
        cell.eventMapView.scrollEnabled = false
        return cell
    }
}

//--------------------------------------------------
// MARK: - Table View Delegate
//--------------------------------------------------

extension EventsTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("show_event_detail", sender: events[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

//--------------------------------------------------
// MARK: - CZPickerView Data Source
//--------------------------------------------------

extension EventsTableViewController:CZPickerViewDataSource {
    
    /*
        Sets number of rows in the CZ Picker
     */
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        if bool == false {
            return choices.count
        } else {
            if filter == "Sports" {
                return sports.count
            } else if filter == "Gender"{
                return genders.count
            } else {
                return competitiveness.count
            }
        }
    }
    
    /*
        Sets title of rows in the CZ Picker depending on which filter choice was selected
     */
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        if bool == false {
            return choices[row]
        } else {
            if filter == "Sports" {
                return sports[row]
            } else if filter == "Gender"{
                return genders[row]
            } else {
                return competitiveness[row]
            }
        }
    }
}

//--------------------------------------------------
// MARK: - CZPickerView Delegate
//--------------------------------------------------

extension EventsTableViewController: CZPickerViewDelegate {
    
    /*
        Initial CZ Picker
     */
    func showWithOneSelectionFilters(sender: AnyObject?) {
        let picker = CZPickerView(headerTitle: "Filter By", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setupPickerWithPicker(picker, andMultipleSelectionValueOf: false)
    }
    
    /*
        CZ Picker that loads if the user selects the sports filters
     */
    func showWithMultipleSportsSelections(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Sports", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setupPickerWithPicker(picker, andMultipleSelectionValueOf: true)
    }
    
    /*
        CZ Picker that loads if the user selects the gender filters
    */
    func showWithMultipleGenderSelections(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Gender", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setupPickerWithPicker(picker, andMultipleSelectionValueOf: true)
    }
    
    /*
        CZ Picker that loads if the user selects the competitiveness filters
     */
    func showWithMultipleCompetitivenessSelections(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Competitiveness Level", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setupPickerWithPicker(picker, andMultipleSelectionValueOf: true)
    }
    
    /*
        Sets CZ Picker properties
     */
    func setupPickerWithPicker(picker: CZPickerView, andMultipleSelectionValueOf multipleSelection: Bool) {
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.allowMultipleSelection = multipleSelection
        picker.headerBackgroundColor = UIColor.materialAmberAccent
        picker.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker.cancelButtonNormalColor = UIColor.blackColor()
        picker.confirmButtonNormalColor = UIColor.whiteColor()
        picker.checkmarkColor = UIColor.materialMainGreen
        picker.show()
    }
    
    /*
        Sets bool as true which allows the CZ Picker to have multiple selections.
        Then sets the filter depending on which row was clicked and loads the
        corresponding CZ Picker for those filters
     */
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        bool = true
        if choices[row] == "Sports"{
            print("hello")
            filter = "Sports"
            showWithMultipleSportsSelections(choices[row])
        } else if choices[row] == "Gender" {
            filter = "Gender"
            showWithMultipleGenderSelections(choices[row])
        } else if choices[row] == "Competitiveness Level" {
            filter = "Competitveness"
            showWithMultipleCompetitivenessSelections(choices[row])
        }
    }
    
    /*
        Saves the filters the user selected.
        Then goes through the events and if an event has all of those filter properties,
        the event will be re loaded in the table.
     */
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        if filter == "Sports" {
            filteredSports = [String]()
            for row in rows {
                if let row = row as? Int {
                    filteredSports.append(sports[row])
                }
            }
        } else if filter == "Gender"{
            filteredGenders = [String]()
            for row in rows {
                if let row = row as? Int {
                    filteredGenders.append(genders[row])
                }
            }
        } else {
            filteredCompetitiveness = [String]()
            for row in rows {
                if let row = row as? Int {
                    filteredCompetitiveness.append(competitiveness[row])
                }
            }
        }
        events = [Event]()
        print(events)
        filter = String()
        bool = false
        for event in factory {
            for filteredSport in filteredSports {
                for filteredCompetition in filteredCompetitiveness {
                    for filteredGender in filteredGenders {
                        print(event)
                        if filteredSport == event.sport && filteredCompetition == event.competition && filteredGender == event.gender {
                            events.append(event)
                        }
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    /*
        When the cancel button is clicked it re initializes which filter had been clicked and bool.
        When bool is false it loads the choices of possible filters
        (Sports, Genders, Competitiveness Levels).
     */
    func czpickerViewDidClickCancelButton(pickerView: CZPickerView!) {
        filter = String()
        bool = false
    }
}


