//
//  MessagesTableViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/29/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewController: UIViewController {
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var eventList = [Dictionary<String, AnyObject>]()
    var userName = ""
    var query: UInt?
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var eventListTableView: UITableView!
    
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        eventList = [Dictionary<String, AnyObject>]()
        
        navigationController?.navigationBar.applyDefaultShadow(UIColor.materialMainGreen)
        navigationController?.navigationBar.setNavbarFonts()
        
        let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
        
        let ref = DataService.ds.getReferenceForUser(userID)
        query = ref.observeEventType(.Value, withBlock: { user in
            self.userName = (user.value.objectForKey(KEY_DISPLAY_NAME) as? String)!
            guard let eventsIDList = user.value.objectForKey("joined_events") as? [String]
                else { return }
            
            for eventID in eventsIDList {
                let eventID = eventID
                let url = "\(DataService.ds.REF_EVENTS)/\(eventID)"
                let ref = Firebase(url: url)
                
                ref.observeEventType(.Value, withBlock: { event in
                    var eventDictionary = Dictionary<String, AnyObject>()
                    eventDictionary["event_title"] = event.value.objectForKey("name")
                    eventDictionary["event_id"] = eventID
                    
                    self.eventList.append(eventDictionary)
                    self.eventListTableView.reloadData()
                    
                    }, withCancelBlock: { err in
                        print(err.description)
                })
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func viewDidLoad() {
        eventListTableView.dataSource = self
        eventListTableView.delegate = self
        eventListTableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if query != nil {
            DataService.ds.REF_USERS.removeAllObservers()
            DataService.ds.REF_EVENTS.removeAllObservers()
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventmessages" {
            let controller = segue.destinationViewController as! MessagesViewController
            controller.eventId = sender as? String
            controller.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as? String
            //TODO: Load user name
            controller.senderDisplayName = userName
        }
    }
}

//--------------------------------------------------
// MARK: - TableViewDataSource
//--------------------------------------------------
extension MessagesTableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventcell", forIndexPath: indexPath) as! EventsListTableViewCell
        let event = eventList[indexPath.row]
        cell.eventNameLabel?.text = event["event_title"] as? String
        cell.eventId = event["event_id"] as? String
        return cell
    }
}

//--------------------------------------------------
// MARK: - TableViewDataSource
//--------------------------------------------------
extension MessagesTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("eventmessages", sender: eventList[indexPath.row]["event_id"])
    }
}