//
//  EditUserProfileViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
import UIKit
import TextFieldEffects
import Firebase

class EditUserProfileViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: =================================== OUTLETS ===================================
    
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var genderTextField: HoshiTextField!
    @IBOutlet weak var ageTextField: HoshiTextField!
    @IBOutlet weak var sportsCollectionView: UICollectionView!
    
    // MARK: =================================== VARIABLES ===================================
    var userInfo: Dictionary<String, AnyObject>?
    var selectedSports: [String]?
    
    // MARK: =================================== DELEGATES ===================================
    var goBackDelegate: GoBackDelegate?
    
    // MARK: =================================== VIEW LIFECYCLE ===================================
    override func viewDidLoad() {
        sportsCollectionView.dataSource = self
        sportsCollectionView.delegate = self
        
        // set collection view item size to be half the
        // width of the frame to create two columns
        let width = CGRectGetWidth(view.frame) / 2 - 1
        let layout = sportsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.nameTextField.text = self.userInfo![KEY_DISPLAY_NAME] as? String
        self.genderTextField.text = self.userInfo![KEY_GENDER] as? String
        self.ageTextField.text = self.userInfo![KEY_AGE] as? String
    }
    
    // MARK: ============== COLLECTION VIEW DATA SOURCE ================
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SPORTS.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sportscell", forIndexPath: indexPath) as! EditUserProfileSportsColletionViewCell
        
        let sport = SPORTS[indexPath.row]
        if selectedSports!.contains(sport.name) {
            cell.nameLabel.text = sport.name
            cell.nameLabel.textColor = UIColor.materialMainGreen
        } else {
            cell.nameLabel.text = sport.name
            cell.nameLabel.textColor = UIColor.darkTextColor()
        }
        
        
        return cell
    }
    
    // MARK: ============== COLLECTION VIEW DELEGATE ================
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EditUserProfileSportsColletionViewCell
        
        toggleSelectedSport(cell, indexPath: indexPath)
    }
    
    private func toggleSelectedSport(cell: EditUserProfileSportsColletionViewCell, indexPath: NSIndexPath) {
        
        if cell.nameLabel.textColor == UIColor.darkTextColor() {
            
            selectedSports!.append(cell.nameLabel.text!)
            
            cell.nameLabel.textColor = UIColor.materialMainGreen
        } else {
            
            for i in 0..<selectedSports!.count {
                if selectedSports![i] == cell.nameLabel.text {
                    selectedSports!.removeAtIndex(i)
                    break
                }
            }
            
            cell.nameLabel.textColor = UIColor.darkTextColor()
        }
        
    }
    
    // MARK: =================================== ACTIONS ===================================
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        if let name = nameTextField.text, gender = genderTextField.text, age = ageTextField.text where age != "" && name != "" && gender != "" {
            userInfo![KEY_AGE] = age
            userInfo![KEY_DISPLAY_NAME] = name
            userInfo![KEY_GENDER] = gender
            userInfo![KEY_SPORTS] = selectedSports
            
            //we force the uid unwrapp because they have a UID from log in
            let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
            let url = "\(DataService.ds.REF_USERS)/\(uid)"
            let ref = Firebase(url: url)
            ref.updateChildValues(userInfo)
            
            goBackDelegate?.goBack(self)
        }
    }
    
    
}