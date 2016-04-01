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
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    // sport image icons
    @IBOutlet weak var iconImage1: UIImageView!
    @IBOutlet weak var iconImage2: UIImageView!
    @IBOutlet weak var iconImage3: UIImageView!
    @IBOutlet weak var iconImage4: UIImageView!
    @IBOutlet weak var iconImage5: UIImageView!
    @IBOutlet weak var iconImage6: UIImageView!
    @IBOutlet weak var iconImage7: UIImageView!
    @IBOutlet weak var iconImage8: UIImageView!
    
    
    // MARK: =================================== VIEW LIFECYCLE ===================================
    override func viewDidLoad() {
        
        
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

            returnUserData()
    }
    
    func updateImages() {
        iconImage1.image = UIImage(named: "soccer")
        iconImage2.image = UIImage(named: "frisbee")
        iconImage3.image = UIImage(named: "basketball")
        iconImage4.image = UIImage(named: "football")
        iconImage5.image = UIImage(named: "tennis")
        iconImage6.image = UIImage(named: "volleyball")
        iconImage7.image = UIImage(named: "badminton")
        iconImage8.image = UIImage(named: "softball")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateImages()
        
        //we force the uid unwrapp because they have a UID from log in
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        let url = "\(DataService.ds.REF_USERS)/\(uid)"
        let ref = Firebase(url: url)
        
        ref.observeEventType(.Value, withBlock: { snapshot in

            self.userInfo[KEY_DISPLAY_NAME] = snapshot.value.objectForKey("name")
            self.userInfo[KEY_GENDER] = snapshot.value.objectForKey("gender")
            self.userInfo[KEY_AGE] = snapshot.value.objectForKey("age")
            self.userInfo[KEY_SPORTS] = snapshot.value.objectForKey("sports")
            print(self.userInfo[KEY_SPORTS])
            
            self.nameLabel.text = self.userInfo[KEY_DISPLAY_NAME] as? String
            self.genderLabel.text = self.userInfo[KEY_GENDER] as? String
            self.ageLabel.text = self.userInfo[KEY_AGE] as? String
            
            for sport in self.userInfo[KEY_SPORTS] as! [String] {
                print(self.userInfo[KEY_SPORTS])
                switch sport {
                case "Soccer":
                    self.iconImage1.image = UIImage(named: "soccer_selected")
                    break
                case "Ultimate Frisbee":
                    self.iconImage2.image = UIImage(named: "frisbee_selected")
                    break
                case "Basketball":
                    self.iconImage3.image = UIImage(named: "basketball_selected")
                    break
                case "Football":
                    self.iconImage4.image = UIImage(named: "football_selected")
                    break
                case "Tennis":
                    self.iconImage5.image = UIImage(named: "tennis_selected")
                    break
                case "Volleyball":
                    self.iconImage6.image = UIImage(named: "volleyball_selected")
                    break
                case "Badminton":
                    self.iconImage7.image = UIImage(named: "badminton_selected")
                    break
                case "Softball":
                    self.iconImage8.image = UIImage(named: "softball_selected")
                    break
                default:
                    break
                }
            }
            self.view.setNeedsDisplay()
            
        }, withCancelBlock: { error in
            print("error")
            print(error.description)
        })
    }
    
    // MARK: =================================== NAVIGATION ===================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_EDIT_USERPROFILE {
            let controller = segue.destinationViewController as! EditUserProfileViewController
            controller.userInfo = userInfo
            controller.goBackDelegate = self
            controller.saveProfileDelegate = self
            controller.selectedSports = userInfo[KEY_SPORTS] as? [String]
        }
    }
    
    // MARK: =================================== DELEGATE FUNCTION ===================================
    func goBack(controller: UIViewController) {
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveProfile(controller: EditUserProfileViewController) {
        self.userInfo = controller.userInfo!
        self.view.setNeedsDisplay()
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: =================================== FACEBOOK PICTURES ===================================
    
    func returnUserData() {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"cover"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                
                // Process error
                print("Error: \(error)")
            } else {
                
                if let id: NSString = result.valueForKey("id") as? NSString {
                    self.returnUserProfileImages(id)
                } else {
                    print("ID es null")
                }
                var sourceString: String!
                let imgURLCoverPhoto = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/?fields=cover&access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
                print(imgURLCoverPhoto)
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
                                    self.coverPhoto.image = UIImage(data: data)
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