//
//  MessagesTableViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/29/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewController: UITableViewController, GoToEventMessagesDelegate {
    var eventList = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //we force the uid unwrapp because they have a UID from log in
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        let url = "\(DataService.ds.REF_USERS)/\(uid)"
        let ref = Firebase(url: url)
        
        ref.observeEventType(.Value, withBlock: { user in
            
            let eventsIDList = user.value.objectForKey("joined_events") as! [String]
            
            for i in 0..<eventsIDList.count {
                let eventID = eventsIDList[i]
                let url = "\(DataService.ds.REF_EVENTS)/\(eventID)"
                let ref = Firebase(url: url)
                
                ref.observeEventType(.Value, withBlock: { event in
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: =================================== DELEGATE FUNCTION ===================================
//    func goToEventMessages(cell: EventsListTableViewCell) {
//        performSegueWithIdentifier("goToEventMessages", sender: cell.eventId)
//    }
}
