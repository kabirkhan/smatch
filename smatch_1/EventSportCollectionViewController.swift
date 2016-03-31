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
    
    var newEvent = Event(title: "", eventKey: "", date: "", sport: "", address: "", numberOfPlayers: "0", gender: Gender.Coed.rawValue, competition: CompetitionLevel.DoesNotMatter.rawValue)

    // MARK: - VARIABLES
    var userSports = [String]()
    var userId: String?
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
        
        // get user's id if stored in defaults which it has to be to get here
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            userId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String?
        }
        
        DataService.ds.REF_USERS.childByAppendingPath(userId).observeEventType(.Value, withBlock: { (snapshot) in
            
            self.userSports = snapshot.value.objectForKey("sports") as! [String]
            self.collectionView?.reloadData()
            
            }) { (error) in
                print(error)
        }
        
        // cell is square and half the width of the view to create two columns
        let width = CGRectGetWidth(view.frame) / 2 - 1
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    // MARK: ====================== COLLECTION VIEW DATASOURCE ======================
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userSports.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("new_event_sport_cell", forIndexPath: indexPath) as! NewEventSportCollectionViewCell
        
        let sport = userSports[indexPath.item]
        cell.nameLabel.text = sport
        cell.nameLabel.textColor = UIColor.materialDarkTextColor

        return cell
    }
    
    // MARK: ====================== COLLECTION VIEW DELEGATE ======================
    // 
    // select the sport and set it tot the current sport of the newEvent
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! NewEventSportCollectionViewCell
        
        if cell.nameLabel.textColor == UIColor.materialDarkTextColor {
            newEvent.sport = cell.nameLabel.text!
            cell.nameLabel.textColor = UIColor.materialMainGreen
        }
    }
    
    // deselect old sport and select new one when a different item is selected
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! NewEventSportCollectionViewCell
        
        if cell.nameLabel.textColor == UIColor.materialMainGreen {
            newEvent.sport = ""
            cell.nameLabel.textColor = UIColor.materialDarkTextColor
        }
    }
    
    // MARK: ======================= ACTIONS AND SEGUES =======================
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        if newEvent.sport != "" {
            performSegueWithIdentifier(SEGUE_NEW_EVENT_TO_NAME_FROM_CHOOSE_SPORT, sender: nil)
        } else {
            let alert = showErrorAlert("Pick A Sport", msg: "Pick a sport to continue")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // send newEvent object to be build up
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_NEW_EVENT_TO_NAME_FROM_CHOOSE_SPORT {
            let destinationViewController = segue.destinationViewController as! EventNameViewController
            destinationViewController.newEvent = newEvent
        }
        
    }
}
