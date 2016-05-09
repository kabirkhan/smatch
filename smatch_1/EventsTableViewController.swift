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

class EventsTableViewController: UITableViewController, GoBackDelegate {
    
    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    
    let regionRadius: CLLocationDistance = 10000
    let filterButton = UIButton()
    
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    
    var factory = [Event]()
    var sports = [String]()
    var filter = String()
    var bool = false
    var choices = ["Sports", "Gender", "Competitiveness Level"]
    var genders = ["Coed", "Only Guys", "Only Girls"]
    var competitiveness = ["NotCompetitive", "Competitive"]
    var filteredSports = [String]()
    var filteredGenders = ["Coed", "Only Guys", "Only Girls"]
    var filteredCompetitiveness = ["NotCompetitive", "Competitive"]
    var pickerWithImage: CZPickerView?
    var mySports = [String]()
    var query: UInt?
    var events = [Event]()
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var frame = filterButton.frame
        frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - filterButton.frame.size.height;
        filterButton.frame = frame
        view.addSubview(filterButton)
        view.bringSubviewToFront(filterButton)
    }
    
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(-64, 0, -50, 0)
        filterButton.setBackgroundImage(UIImage(named: "Filter Button"), forState: .Normal)
    }
    
    override func viewDidDisappear(animated: Bool) {
        sports = [String]()
        filteredSports = [String]()
        filteredGenders = ["Coed", "Only Guys", "Only Girls"]
        filteredCompetitiveness = ["NotCompetitive", "Competitive"]
        factory = [Event]()
        events = [Event]()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    // MARK: - Segues
    //--------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_event_detail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EventDetailViewController
            controller.eventToDetail = sender as? Event
            controller.delegate = self
        }
    }
    
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    func displayFireBaseEvents() {
        
        let authData = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        
        //Set mySports - Array of sports the user has on their profile
        
        let user = Firebase(url: "https://smatchfirstdraft.firebaseio.com/users/\(authData)")
        query = user.observeEventType(.Value, withBlock: { snapshot in
            
            self.events = [Event]()
            
            let userSports = snapshot.value.objectForKey("sports")
            self.mySports = userSports as! [String]
            self.sports = userSports as! [String]
            self.filteredSports = userSports as! [String]
            print(self.sports)
            //Set events - Array of events that only include events of sports that are inside mySports
            let eventsRef = DataService.ds.REF_EVENTS
            eventsRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { snapshot in
                if let sport = snapshot.value.objectForKey("sport") {
                    for i in 0...self.mySports.count-1 {
                        
                        //if the sport is one of "mySports" create an event and append it to our events array.
                        
                        if sport as! String == self.mySports[i] {
                            let eventName = snapshot.value.objectForKey("name") as! String
                            let eventKey = snapshot.key
                            let eventAddress = snapshot.value.objectForKey("address") as! String
                            let eventCompetition = snapshot.value.objectForKey("competition_level") as! String
                            let eventDate = snapshot.value.objectForKey("date") as! String
                            let eventGender = snapshot.value.objectForKey("gender") as! String
                            let eventPlayers = snapshot.value.objectForKey("number_of_players") as! String
                            let eventSport = snapshot.value.objectForKey("sport") as! String
                            let eventAttendees = snapshot.value.objectForKey("attendees") as! [String]
                            let eventCreatorId = snapshot.value.objectForKey("creator_id") as! String
                            
                            let newEvent = Event(title: eventName, eventKey: eventKey, date: eventDate, sport: eventSport, address: eventAddress, numberOfPlayers: eventPlayers, gender: eventGender, competition: eventCompetition, attendees: eventAttendees, creator_id: eventCreatorId)
                            self.events.append(newEvent)
                            self.factory.append(newEvent)
                        }
                    }
                    //reload the table data. Otherwise the table will load without data and be empty/blank.
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
                }, withCancelBlock: { error in
                    print(error.description)
            })
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Send the event detail controller the event to display data for as "sender"
        performSegueWithIdentifier("show_event_detail", sender: events[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_FOR_EVENT_CELL) as! EventCell
        cell.eventNameLabel.text = events[indexPath.row].title
        cell.eventLocationLabel.text = events[indexPath.row].address
        cell.dateLabel.text = events[indexPath.row].date
        //Geocode the event and pin it on the mini event map
        
        events[indexPath.row].geocode(cell.eventMapView, regionRadius: regionRadius, centeredOnPin: true)
        cell.eventMapView.scrollEnabled = false
        return cell
    }
}

//--------------------------------------------------
// MARK: - Extensions
//--------------------------------------------------

extension EventsTableViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    
    func showWithOneSelectionFilters(sender: AnyObject) {
        let picker1 = CZPickerView(headerTitle: "Filter By", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker1.delegate = self
        picker1.dataSource = self
        picker1.needFooterView = false
        picker1.allowMultipleSelection = false
        picker1.headerBackgroundColor = UIColor.materialAmberAccent
        picker1.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker1.cancelButtonNormalColor = UIColor.blackColor()
        picker1.confirmButtonNormalColor = UIColor.whiteColor()
        picker1.checkmarkColor = UIColor.materialMainGreen
        picker1.show()
    }
    
    func showWithMultipleSportsSelections(sender: AnyObject) {
        let picker1 = CZPickerView(headerTitle: "Sports", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker1.delegate = self
        picker1.dataSource = self
        picker1.needFooterView = false
        picker1.allowMultipleSelection = true
        picker1.headerBackgroundColor = UIColor.materialAmberAccent
        picker1.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker1.cancelButtonNormalColor = UIColor.blackColor()
        picker1.confirmButtonNormalColor = UIColor.whiteColor()
        picker1.checkmarkColor = UIColor.materialMainGreen
        picker1.show()
    }
    
    func showWithMultipleGenderSelections(sender: AnyObject) {
        let picker1 = CZPickerView(headerTitle: "Gender", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker1.delegate = self
        picker1.dataSource = self
        picker1.needFooterView = false
        picker1.allowMultipleSelection = true
        picker1.headerBackgroundColor = UIColor.materialAmberAccent
        picker1.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker1.cancelButtonNormalColor = UIColor.blackColor()
        picker1.confirmButtonNormalColor = UIColor.whiteColor()
        picker1.checkmarkColor = UIColor.materialMainGreen
        picker1.show()
    }
    
    func showWithMultipleCompetitivenessSelections(sender: AnyObject) {
        let picker1 = CZPickerView(headerTitle: "Competitiveness Level", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker1.delegate = self
        picker1.dataSource = self
        picker1.needFooterView = false
        picker1.allowMultipleSelection = true
        picker1.headerBackgroundColor = UIColor.materialAmberAccent
        picker1.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker1.cancelButtonNormalColor = UIColor.blackColor()
        picker1.confirmButtonNormalColor = UIColor.whiteColor()
        picker1.checkmarkColor = UIColor.materialMainGreen
        picker1.show()
    }
    
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
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        bool = true
        if choices[row] == "Sports"{
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
        tableView.reloadData()
    }
    
    func czpickerViewDidClickCancelButton(pickerView: CZPickerView!) {
        filter = String()
        bool = false
        
    }
}
