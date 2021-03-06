//
//  ChooseSportsCollectionViewController.swift
//  smatch
//
//  Created by Kabir Khan on 3/16/16.
//  Copyright © 2016 blueberries. All rights reserved.
//
//  Collection View to display all the available sports that
//  a user can participate in. Get the selected cells and set 
//  them as the user's sports.

import UIKit

class ChooseSportsCollectionViewController: UIViewController {

    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var userData: Dictionary<String, AnyObject>?
    var sports = SPORTS
    var selectedSports = [String]()
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var collectionView: UICollectionView!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Setup Collection View Layout and delegate/datasource.
        Register SportCell
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let width = CGRectGetWidth(view.frame) / 2 - 1
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        Create user when they press done. 
        Create sessionID in UserDefaults.
        Save how the created their account 
        (i.e facebook, twitter, email/password).
     */
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        
        let userId = userData?.removeValueForKey(KEY_ID)
        userData!["sports"] = selectedSports
        userData!["joined_events"] = [String]()
        
        if userData!["provider"] as! String == "facebook" {
            DataService.ds.createFirebaseUser(userId! as! String, user: userData!)
            NSUserDefaults.standardUserDefaults().setValue(userId, forKey: KEY_ID)
        } else if userData![KEY_PROVIDER] as! String == VALUE_EMAIL_PASSWORD_PROVIDER {
            
            DataService.ds.REF_BASE.createUser(userData![KEY_EMAIL] as! String, password: userData![KEY_PASSWORD] as! String, withValueCompletionBlock: { (error, result) -> Void in
                if error != nil {
                    self.presentViewController(showAlert("Woah", msg: "Something went really wrong"), animated: true, completion: nil)
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(result[KEY_ID], forKey: KEY_ID)
                    DataService.ds.REF_BASE.authUser(self.userData![KEY_EMAIL] as! String, password: self.userData![KEY_PASSWORD] as! String, withCompletionBlock: { (error, authData) in
                        
                        self.userData?.removeValueForKey(KEY_EMAIL)
                        self.userData?.removeValueForKey(KEY_PASSWORD)
                        
                        DataService.ds.createFirebaseUser(authData.uid, user: self.userData!)
                    })
                }
            })
        }
        performSegueWithIdentifier(SEGUE_FINISH_SIGNUP_TO_MAIN_SCREEN, sender: nil)
    }
}

//--------------------------------------------------
// MARK: - Collection View Datasource
//--------------------------------------------------
extension ChooseSportsCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sports.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sportscell", forIndexPath: indexPath) as! SportCollectionViewCell
        
        let sport = sports[indexPath.row]
        cell.sport = sport
        cell.nameLabel.text = sport.name
        cell.nameLabel.textColor = UIColor.materialDarkTextColor
        cell.iconImageView.image = UIImage(named: sport.iconImageName)
        
        return cell
    }
}

//--------------------------------------------------
// MARK: - Collection View Delegate
//--------------------------------------------------
extension ChooseSportsCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SportCollectionViewCell
        toggleSelectedSport(cell, indexPath: indexPath)
    }
    
    /*
        Toggle the color of the cell when tapped, toggle sport in selected sports
     */
    private func toggleSelectedSport(cell: SportCollectionViewCell, indexPath: NSIndexPath) {
        
        if cell.nameLabel.textColor == UIColor.materialDarkTextColor {
            
            selectedSports.append(cell.nameLabel.text!)
            cell.nameLabel.textColor = UIColor.materialMainGreen
            cell.iconImageView.image = UIImage(named: "\(cell.sport!.iconImageName)_selected")
            cell.cellView.backgroundColor = UIColor.materialLightGreen
        } else {
            
            for i in 0..<selectedSports.count {
                if selectedSports[i] == cell.nameLabel.text {
                    selectedSports.removeAtIndex(i)
                    break
                }
            }
            cell.nameLabel.textColor = UIColor.materialDarkTextColor
            cell.iconImageView.image = UIImage(named: cell.sport!.iconImageName)
            cell.cellView.backgroundColor = UIColor.whiteColor()
        }
    }
}
