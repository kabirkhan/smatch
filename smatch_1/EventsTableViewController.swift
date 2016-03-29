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
    

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
