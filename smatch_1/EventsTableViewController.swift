//
//  EventsTableViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/23/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView? = MaterialView()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_FOR_EVENT_CELL) as! EventCell
        
        cell.eventImageView.image = UIImage(named: "Bitmap")
        cell.eventImageView.layer.cornerRadius = 2.0
        cell.eventImageView.layer.masksToBounds = true
        cell.eventNameLabel.text = "Test Event"
        cell.eventLocationLabel.text = "Test Location"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("show_event_detail", sender: nil)
    }
}
