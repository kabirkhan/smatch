 //
//  EventLocationViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  MKLocalSearchCompleter introduced in iOS 9.3 for autocomplete search
//
//  if #available(iOS 9.3, *) {
//      let req = MKLocalSearchCompleter()
//  } else {
        // Fallback on earlier versions
//  }

import UIKit
import TextFieldEffects
import MapKit

class EventLocationViewController: UIViewController {

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var newEvent: Event?
    var searchResults = [MKMapItem]()
    var locationManager = UserLocation.userLocation
    var currentLocation = CLLocation()

    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet weak var locationTextField: HoshiTextField!
    @IBOutlet weak var tableView: UITableView!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Get user's current location and setup tableview
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.hidden = true
        currentLocation = locationManager.returnLocation()
    }
    
    /*
        Add selector to check when TextField changes.
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        locationTextField.addTarget(self, action: #selector(EventLocationViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        
        if let location = locationTextField.text where location != "" {
            newEvent?.address = location
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_DATE_FROM_LOCATION, sender: nil)
        } else {
            let alert = showAlert("You forgot a location", msg: "Please enter an address for people to meet up for your event")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_DATE_FROM_LOCATION {
            let destinationViewController = segue.destinationViewController as! CreateEventDateViewController
            destinationViewController.newEvent = newEvent
        }
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Get address based on area around user's current location.
        Reload results each time TextField changes
     */
    func textFieldDidChange(textField: HoshiTextField) {
        
        if let place = textField.text where place != "" {
            tableView.hidden = false
            searchResults = []
            
            let span = MKCoordinateSpan(latitudeDelta: 30000, longitudeDelta: 30000)
            
            let mapRegion = MKCoordinateRegionMake(currentLocation.coordinate, span)
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = place
            request.region = mapRegion
            
            let search = MKLocalSearch(request: request)
            
            search.startWithCompletionHandler({ (response, error) in
                guard let response = response else {
                    print("error: \(error)")
                    return
                }
                
                for item in response.mapItems {
                    self.searchResults.append(item)
                    self.tableView.reloadData()
                }
            })
        }
    }
}
 
//--------------------------------------------------
// MARK: - TableView DataSource
//--------------------------------------------------
extension EventLocationViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // setup tableview to display the search results
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("location_search_cell")
        
        // build up an address string
        var addressString = ""
        let placemark = searchResults[indexPath.row].placemark.description
        let address = placemark.componentsSeparatedByString(", ")
        // get the place name and address and set to address string
        if address[0] == address[1] {
            addressString = address[0]
        } else {
            addressString = "\(address[0]), \(address[1])"
        }
        
        // e.g Seattle, WA 98133
        let cityString = "\(address[2]), \(address[3])"
        
        // set up tableviewcell
        cell?.textLabel?.text = addressString
        cell?.detailTextLabel?.text = cityString
        
        return cell!
    }
}

//--------------------------------------------------
// MARK: - TableView Delegate
//--------------------------------------------------
extension EventLocationViewController: UITableViewDelegate {
    // When a row (location) is selected, set the text field text to that row's title
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let address = cell?.textLabel?.text, city = cell?.detailTextLabel?.text {
            locationTextField.text = "\(address) \(city)"
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
