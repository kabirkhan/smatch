//
//  MessagesTableViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/29/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewController: UITableViewController {
    
    // MARK: ================= VARIABLES ====================
    var eventList = [Dictionary<String, AnyObject>]()
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let url = "\(DataService.ds.REF_USERS)/\(uid)"
        let ref = Firebase(url: url)
        
        ref.observeSingleEventOfType(.Value, withBlock: { user in
            
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
                    self.tableView.reloadData()

                }, withCancelBlock: { err in
                    print("help")
                    print(err.description)
                })
            }
            
            }, withCancelBlock: { error in
                print("error")
                print(error.description)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventcell", forIndexPath: indexPath) as! EventsListTableViewCell
        let event = eventList[indexPath.row]
        cell.eventNameLabel?.text = event["event_title"] as? String
        cell.eventId = event["event_id"] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("eventmessages", sender: eventList[indexPath.row]["event_id"])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventmessages" {
            let controller = segue.destinationViewController as! MessagesViewController
            controller.eventId = sender as? String
            controller.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as? String
            //TODO: Load user name
            controller.senderDisplayName = ""
        }
    }
    
    // MARK: =================================== DELEGATE FUNCTION ===================================
//    func goToEventMessages(cell: EventsListTableViewCell) {
//        performSegueWithIdentifier("goToEventMessages", sender: cell.eventId)
//    }
}
