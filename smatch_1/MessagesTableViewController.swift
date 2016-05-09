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
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    //store this in userdefaults on login/creation
    var userName = ""
    var query: UInt?
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
        @IBOutlet weak var eventListTableView: UITableView!
    //--------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        eventList = [Dictionary<String, AnyObject>]()
        print("loading...")
        
        // =========== NAVBAR SETUP ==============
        // set navbar fonts
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: fontColor]
        
        // set navbar shadow
        self.navigationController?.navigationBar.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1.0).CGColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.6
        self.navigationController?.navigationBar.layer.shadowRadius = 5.0
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        // set navbar color
        self.navigationController?.navigationBar.barTintColor = UIColor.materialMainGreen
        
        //we force the uid unwrapp because they have a UID from log in
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        
        let ref = DataService.ds.getReferenceForUser(uid as! String)
        query = ref.observeEventType(.Value, withBlock: { user in
            print("hello: start")
            self.userName = (user.value.objectForKey(KEY_DISPLAY_NAME) as? String)!
            guard let eventsIDList = user.value.objectForKey("joined_events") as? [String]
                else {
                    return
            }
            
            for i in 0..<eventsIDList.count {
                let eventID = eventsIDList[i]
                let url = "\(DataService.ds.REF_EVENTS)/\(eventID)"
                let ref = Firebase(url: url)
                
                ref.observeSingleEventOfType(.Value, withBlock: { event in
                    var eventDictionary = Dictionary<String, AnyObject>()
                    eventDictionary["event_title"] = event.value.objectForKey("name")
                    eventDictionary["event_id"] = eventID
                    
                    self.eventList.append(eventDictionary)
                    
                    print("hello2")
                    self.eventListTableView.reloadData()
                    
                    }, withCancelBlock: { err in
                        print("help")
                        print(err.description)
                })
            }
            
            print("hello end")
            
            }, withCancelBlock: { error in
                print("error")
                print(error.description)
        })
    }
    
    override func viewDidLoad() {
        eventListTableView.dataSource = self;
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
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventcell", forIndexPath: indexPath) as! EventsListTableViewCell
        let event = eventList[indexPath.row]
        cell.eventNameLabel?.text = event["event_title"] as? String
        cell.eventId = event["event_id"] as? String
        return cell
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("eventmessages", sender: eventList[indexPath.row]["event_id"])
    }
}
