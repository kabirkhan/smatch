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

class EventsTableViewController: UITableViewController {
    
    // MARK: - Variables and Constants
    
    var events = [Event]()
    let regionRadius: CLLocationDistance = 3000
    
    // MARK: - Dummy Data
    
    let event1 = Event(title: "Pick-Up Basketball", date: "3-30-2016", sport: "Basketball", address: "1053 25th Ave East, Seattle, WA", time: "12:00pm", numberOfPlayers: 10, gender: "Coed", competitiveness: "competitive")
    let event2 = Event(title: "Sand Volleyball", date: "3-31-2016", sport: "Volleyball", address: "130th Avenue Northeast, Bellevue, WA", time: "2:00pm", numberOfPlayers: 12, gender: "Coed", competitiveness: "competitive")
    let event3 = Event(title: "Badminton in the Park", date: "4-2-2016", sport: "Badminton", address: "4311 University Way Northeast, Seattle, WA", time: "1:00pm", numberOfPlayers: 4, gender: "Coed", competitiveness: "competitive")
    let event4 = Event(title: "Pick-Up Soccer", date: "3-29-2016", sport: "Soccer", address: "3510 Fremont Avenue North, Seattle, WA", time: "4:00pm", numberOfPlayers: 20, gender: "Coed", competitiveness: "competitive")
    let event5 = Event(title: "Ultimate", date: "4-3-2016", sport: "Ultimate Frisbee", address: "Rainier Avenue South, Renton, WA", time: "7:30pm", numberOfPlayers: 12, gender: "Coed", competitiveness: "competitive")
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        events.append(event1)
        events.append(event2)
        events.append(event3)
        events.append(event4)
        events.append(event5)
        tableView.tableFooterView? = MaterialView()
    }
    // MARK: - Table View Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_FOR_EVENT_CELL) as! EventCell
        cell.eventNameLabel.text = events[indexPath.row].title
        cell.eventLocationLabel.text = events[indexPath.row].address
        
        //Geocode the event and pin it on the map
        
        events[indexPath.row].geocode(cell.eventMapView, regionRadius: regionRadius, centeredOnPin: true)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Send the event detail controller the event to display data for
        performSegueWithIdentifier("show_event_detail", sender: events[indexPath.row])
    }
    
    // MARK: - Segues
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_event_detail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EventDetailViewController
            controller.eventToDetail = sender as! Event
            controller.delegate = self
            
        }
    }
    
}
