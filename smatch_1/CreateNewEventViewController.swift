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

    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    let regionRadius: CLLocationDistance = 3000

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var alert = UIViewController()
    var timer = NSTimer()
    var events = [Event]()
    var myEvents = [String]()
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var tableView: UITableView!
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "EventTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "event_cell")
        
        displayFireBaseEvents()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
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
        performSegueWithIdentifier(SEGUE_FROM_MY_EVENTS_TO_DETAIL, sender: events[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    // Display the user's joined events
    func displayFireBaseEvents() {
        
        // Get current user_id from User Defaults
        let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
        
        DataService.ds.getReferenceForUser(userID).observeEventType(.Value, withBlock: { snapshot in
            
            let userEvents = snapshot.value.objectForKey("joined_events")
            
            if let events = userEvents {
                self.myEvents = events as! [String]
            }
            
            self.events = [Event]()
            
            if self.myEvents.count > 0 {
                
                DataService.ds.getEventsFromUserJoinedEvents(self.myEvents, completion: { (events, error) in
                    if error != nil {
                        let alert = showAlert("Error Getting Data", msg: "Sorry we couldn't query your events. Please Try again later")
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        guard let events = events else { return }
                        self.events = events
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                })
                
            } else {
                
                // if they don't have games show alert telling them to join/make games
                let alert = showAlert("You don't have any games!", msg: "You can create a game here or join one in the events section")
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
        alert = showAlert("Game Created Successfully!", msg: "View your game in the my events tab")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CreateNewEventViewController.presentAlert), userInfo: nil, repeats: false)
        
    }
    
    // EVENT CREATION CANCELLED
    // unwind segue if event creation is cancelled at any point
    @IBAction func eventCreationCancelled(segue: UIStoryboardSegue) {
        alert = showAlert("Game Creation Cancelled", msg: "Not right now? Make a game later!")
        
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
    
    func presentAlert() {
        presentViewController(alert, animated: true, completion: nil)
        timer.invalidate()
    }
}
