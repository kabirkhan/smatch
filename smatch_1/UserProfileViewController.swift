//
//  UserProfileViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class UserProfileViewController :UIViewController, GoBackDelegate, SaveProfileDelegate {
    
    // MARK: =================================== VARIABLES ===================================
    var userInfo = Dictionary<String, AnyObject>()
    let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE)
    let fontColor = UIColor.whiteColor()
    
    // MARK: =================================== OUTLETS ===================================
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    // MARK: =================================== VIEW LIFECYCLE ===================================
    override func viewDidLoad() {
        returnUserData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //we force the uid unwrapp because they have a UID from log in
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        let url = "\(DataService.ds.REF_USERS)/\(uid)"
        let ref = Firebase(url: url)
        
        ref.observeEventType(.Value, withBlock: { snapshot in

            self.userInfo[KEY_DISPLAY_NAME] = snapshot.value.objectForKey("name")
            self.userInfo[KEY_GENDER] = snapshot.value.objectForKey("gender")
            self.userInfo[KEY_AGE] = snapshot.value.objectForKey("age")
            self.userInfo[KEY_SPORTS] = snapshot.value.objectForKey("sports")
            
            self.nameLabel.text = self.userInfo[KEY_DISPLAY_NAME] as? String
            self.bioLabel.text = self.userInfo["bio"] as? String
            let gender = self.userInfo[KEY_GENDER] as? String
            self.genderLabel.text = gender?.capitalizedString
            let age = self.userInfo[KEY_AGE] as? String
            if let age = age {
                self.ageLabel.text = "\(age) years old"
            }
            
             dispatch_async(dispatch_get_main_queue(), {
                 self.view.setNeedsDisplay()
             })
            
        }, withCancelBlock: { error in
            print("error")
            print(error.description)
        })
    }
    
    // MARK: =================================== NAVIGATION ===================================
    
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
    
    // MARK: =================================== DELEGATE FUNCTION ===================================
    func goBack(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveProfile(controller: EditProfileViewController) {
        self.userInfo = controller.userInfo!
        controller.dismissViewControllerAnimated(true, completion: nil)
         dispatch_async(dispatch_get_main_queue(), {
             self.view.setNeedsDisplay()
         })
    }
    
    // MARK: =================================== FACEBOOK PICTURES ===================================
    
    func returnUserData() {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"cover"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if (error != nil) {
                print("Error: \(error)")
            } else {
                
                if let userID: NSString = result.valueForKey("id") as? NSString {
                    self.returnUserProfileImages(userID)
                } else {
                    print("ID is null")
                }
                var sourceString: String!
                let imgURLCoverPhoto = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/?fields=cover&access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
                Alamofire.request(.GET, imgURLCoverPhoto).validate().responseJSON(completionHandler: { (response) -> Void in
                    guard response.result.isSuccess else {
                        print(response.result.error)
                        return
                    }
                    if let JSON = response.result.value {
                        if let info = JSON as? [String: AnyObject]{
                            if let cover = info["cover"] as? [String: AnyObject] {
                                sourceString = cover["source"] as! String
                                let facebookCoverUrl = NSURL(string: sourceString)
                                if let data = NSData(contentsOfURL: facebookCoverUrl!) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.coverPhoto.image = UIImage(data: data)
                                    })
                                }
                            }
                        }
                    }
                })
            }
        })
    }
    
    func returnUserProfileImages(accessToken: NSString){
        let userID = accessToken as NSString
        let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            profilePhoto.image = UIImage(data: data)
        }
    }
}
