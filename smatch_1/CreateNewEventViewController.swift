  //
//  CreateNewEventViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class CreateNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GoBackDelegate {

    // MARK: =================== VARIBALES =====================
    var alert = UIViewController()
    var timer = NSTimer()
    
    var events = [Event]()
    var myEvents = [String]()
    let regionRadius: CLLocationDistance = 3000
    
    // MARK: =================== OUTLETS ======================
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: ================== View Lifecycle ====================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the user's joined events
        displayFireBaseEvents()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // ALERT CREATION
    func presentAlert() {
        presentViewController(alert, animated: true, completion: nil)
        timer.invalidate()
    }
    
    // MARK: =================== TABLEVIEW DATASOURCE =====================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_FOR_EVENT_CELL) as! EventCell
        cell.eventNameLabel.text = events[indexPath.row].title
        cell.eventLocationLabel.text = events[indexPath.row].address
        cell.dateLabel.text = events[indexPath.row].date
        //Geocode the event and pin it on the mini event map
        
        events[indexPath.row].geocode(cell.eventMapView, regionRadius: regionRadius, centeredOnPin: true)
        cell.eventMapView.scrollEnabled = false
        return cell
    }
    
    // MARK: =================== TABLEVIEW DELEGATE =====================
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Send the event detail controller the event to display data for as "sender"
        performSegueWithIdentifier(SEGUE_FROM_MY_EVENTS_TO_DETAIL, sender: events[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    // MARK: ==================== Firebase ====================
    // 
    // Display the user's joined events
    func displayFireBaseEvents() {
        
        // Get current user_id from User Defaults
        let userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        
        let userRef = Firebase(url: "https://smatchfirstdraft.firebaseio.com/users/\(userId)")
        userRef.observeEventType(.Value, withBlock: { snapshot in
            
            let userEvents = snapshot.value.objectForKey("joined_events")
            
            // unwrap the snapshot to check for nil events
            if let events = userEvents {
                self.myEvents = events as! [String]
            }
            
            self.events = [Event]()
            
            // if user has games display them in a table
            if self.myEvents.count != 0 {
                for event in self.myEvents {
                    let singleEventRef = DataService.ds.REF_EVENTS.childByAppendingPath(event)
                    print(singleEventRef)
                    singleEventRef.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
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
                        self.tableView.reloadData()

                        
                        }, withCancelBlock: { (error) in
                            print(error)
                    })
                }
            } else {
                
                // if they don't have games show alert telling them to join/make games
                let alert = showErrorAlert("You don't have any games!", msg: "You can create a game here or join one in the events section")
                self.presentViewController(alert, animated: true, completion: nil)
            }

            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    // MARK: =================== ACTIONS AND SEGUES =====================
    //
    // EVENT CREATION COMPLETED SUCCESSFULLY
    // unwind segue to here if you get to the end and save the event
    @IBAction func finishCreatingEvent(segue: UIStoryboardSegue) {
        alert = showErrorAlert("Game Created Successfully!", msg: "View your game in the my events tab")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CreateNewEventViewController.presentAlert), userInfo: nil, repeats: false)
        
    }
    
    // EVENT CREATION CANCELLED
    // unwind segue if event creation is cancelled at any point
    @IBAction func eventCreationCancelled(segue: UIStoryboardSegue) {
        alert = showErrorAlert("Game Creation Cancelled", msg: "Not right now? Make a game later!")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CreateNewEventViewController.presentAlert), userInfo: nil, repeats: false)
    }
    
    // GoBack Delegate to send the user back here from event detail
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_FROM_MY_EVENTS_TO_DETAIL {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! EventDetailViewController
            controller.eventToDetail = sender as? Event
            controller.delegate = self
        }
    }
}
