//
//  EventSportViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class EventSportCollectionViewController: UICollectionViewController {
    
    var userSports = SPORTS
    var newEvent = Event(title: "", date: NSDate(), sport: "", address: "", numberOfPlayers: 0, gender: Gender.Coed, competition: CompetitionLevel.DoesNotMatter)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationViewController = segue.destinationViewController as! EventNameViewController
        destinationViewController.newEvent = newEvent
        
    }
    
}
