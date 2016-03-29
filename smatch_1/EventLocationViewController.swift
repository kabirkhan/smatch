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

class EventLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var newEvent: Event?
    var searchResults = [MKMapItem]()

    @IBOutlet weak var locationTextField: HoshiTextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: ======================== VIEW LIFECYCLE ========================
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        locationTextField.addTarget(self, action: #selector(EventLocationViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
    }
    
    func textFieldDidChange(textField: HoshiTextField) {
        if let place = textField.text where place != "" {
            searchResults = []
            let worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = place
            request.region = worldRegion
            
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
    
    // MARK: ======================== TABLE VIEW DATASOURCE ========================
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let location = cell?.textLabel?.text {
            locationTextField.text = location
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        if let location = locationTextField.text where location != "" {
            newEvent?.address = location
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_DATE_FROM_LOCATION, sender: nil)
        } else {
            let alert = showErrorAlert("You forgot a location", msg: "Please enter an address for people to meet up for your event")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! CreateEventDateViewController
        destinationViewController.newEvent = newEvent
    }
    
}
