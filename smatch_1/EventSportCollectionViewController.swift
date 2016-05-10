//
//  EventSportViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  User creating event picks the sport that they want, set sport to the
//  newEvent object and send it to next vc through segue

import UIKit
import Firebase

class EventSportCollectionViewController: UICollectionViewController {
    
    //--------------------------------------------------
    // MARK: - Constants
    //--------------------------------------------------
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var userSports = [String]()
    var userSportsAsSports = [Sport]()
    var userID: String?
    var newEvent = Event(title: "", eventKey: "", date: "", sport: "", address: "", numberOfPlayers: "0", gender: Gender.Coed.rawValue, competition: CompetitionLevel.DoesNotMatter.rawValue, attendees: [String](), creator_id: "")
    
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Setup Collection View Layout.
        Query Current User's sports.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.applyDefaultShadow(UIColor.materialMainGreen)
        navigationController?.navigationBar.setNavbarFonts()
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String?
        }
        
        // get the user's sports as strings from firebase
        // create an array of sport objects from the strings
        DataService.ds.REF_USERS.childByAppendingPath(userID).observeEventType(.Value, withBlock: { (snapshot) in
            
            self.userSports = snapshot.value.objectForKey("sports") as! [String]
            
            for sport in SPORTS {
                if self.userSports.contains(sport.name) {
                    self.userSportsAsSports.append(sport)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
            
            }) { (error) in
                print(error)
        }
        
        let width = CGRectGetWidth(view.frame) / 2 - 1
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        if newEvent.sport != "" {
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_NAME_FROM_CHOOSE_SPORT, sender: nil)
        } else {
            let alert = showAlert("Pick A Sport", msg: "Pick a sport to continue")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_NAME_FROM_CHOOSE_SPORT {
            let destinationViewController = segue.destinationViewController as! EventNameViewController
            destinationViewController.newEvent = newEvent
        }
    }
}

//--------------------------------------------------
// MARK: - Collection View Datasource
//--------------------------------------------------
extension EventSportCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userSportsAsSports.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("new_event_sport_cell", forIndexPath: indexPath) as! NewEventSportCollectionViewCell
        let sport = userSportsAsSports[indexPath.item]
        cell.sport = sport
        cell.nameLabel.text = sport.name
        cell.nameLabel.textColor = UIColor.materialDarkTextColor
        cell.imageView.image = UIImage(named: sport.iconImageName)
        return cell
    }
}

//--------------------------------------------------
// MARK: - Collection View Delegate
//--------------------------------------------------
extension EventSportCollectionViewController {
   
    /* 
        When user selects a sport and set it to the current sport of the newEvent
     */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! NewEventSportCollectionViewCell
        if cell.nameLabel.textColor == UIColor.materialDarkTextColor {
            newEvent.sport = cell.nameLabel.text!
            cell.nameLabel.textColor = UIColor.materialMainGreen
            cell.imageView.image = UIImage(named: "\(userSportsAsSports[indexPath.item].iconImageName)_selected")
            cell.cellView.backgroundColor = UIColor.materialLightGreen
        }
    }
    
    /*
        When user selects a different sport,
        deselect old sport and set current sport
        as the newly selected cell
     */
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! NewEventSportCollectionViewCell
        if cell.nameLabel.textColor == UIColor.materialMainGreen {
            newEvent.sport = ""
            cell.nameLabel.textColor = UIColor.materialDarkTextColor
            cell.imageView.image = UIImage(named: "\(userSportsAsSports[indexPath.item].iconImageName)")
            cell.cellView.backgroundColor = UIColor.whiteColor()
        }
    }
}
