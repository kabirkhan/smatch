//
//  UserProfileViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  Display the user's profile information from facebook

import Foundation
import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class UserProfileViewController :UIViewController, GoBackDelegate, SaveProfileDelegate {
    
    //--------------------------------------
    // MARK: - Constants
    //--------------------------------------
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    
    //--------------------------------------
    // MARK: - Variables
    //--------------------------------------
    var userInfo = Dictionary<String, AnyObject>()
    
    //--------------------------------------
    // MARK: - Outlets
    //--------------------------------------
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportsLabel: UILabel!
    
    //--------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------
    override func viewDidLoad() {
        returnUsersProfileAndCoverPhotos()
    }
    
    /*
        Get the user's profile information from firebase and setup the view
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)! as? String else { return }
        returnUserInfo(userID)
    }
    
    //--------------------------------------
    // MARK: - Navigation
    //--------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_EDIT_USERPROFILE {
            let destController = segue.destinationViewController as! UINavigationController
            let controller = destController.topViewController as! EditProfileViewController
            controller.userInfo = userInfo
            controller.goBackDelegate = self
            controller.saveProfileDelegate = self
            if coverPhoto.image != nil {
                print("Cover Photo")
            }
            controller.coverImage = self.coverPhoto.image
            controller.profileImage = self.profilePhoto.image
        }
    }
    
    /*
        Cancel and go back function
     */
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
        Update view with saved profile information
     */
    func saveProfile(controller: EditProfileViewController) {
        self.userInfo = controller.userInfo!
        controller.dismissViewControllerAnimated(true, completion: nil)
        dispatch_async(dispatch_get_main_queue(), {
            self.view.setNeedsDisplay()
        })
    }
    
    //--------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------
    
    /*
        Get the user's photos from facebook
     */
    func returnUsersProfileAndCoverPhotos() {
        User.user.getFacebookCoverPhoto { (profileImageData, coverImageData) in
            self.profilePhoto.image = UIImage(data: profileImageData)
            self.coverPhoto.image = UIImage(data: coverImageData)
        }
    }
    
    func returnUserInfo(userID: String) {
        User.user.getBaseUserInfo(userID) { (userInfo) in
            self.userInfo = userInfo
            self.nameLabel.text = self.userInfo[KEY_DISPLAY_NAME] as? String
            self.bioLabel.text = self.userInfo["bio"] as? String
            let gender = self.userInfo[KEY_GENDER] as? String
            self.genderLabel.text = gender?.capitalizedString
            let age = self.userInfo[KEY_AGE] as? String
            if let ageString = age {
                self.ageLabel.text = "\(ageString) years old"
            }
            let sports = self.userInfo[KEY_SPORTS] as? [String]
            self.sportsLabel.text = sports?.joinWithSeparator(", ")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.view.setNeedsDisplay()
            })
        }
    }
}
