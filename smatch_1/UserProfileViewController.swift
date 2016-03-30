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

class UserProfileViewController :UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GoBackDelegate {
    
    // MARK: =================================== OUTLETS ===================================
    
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportsCollectionView: UICollectionView!
    
    // MARK: =================================== VARIABLES ===================================
    
    var userInfo = Dictionary<String, AnyObject>()
    
    // MARK: =================================== VIEW LIFECYCLE ===================================
    override func viewDidLoad() {
        sportsCollectionView.dataSource = self
        sportsCollectionView.delegate = self
        
        // set collection view item size to be half the
        // width of the frame to create two columns
        let width = CGRectGetWidth(view.frame) / 2 - 1
        let layout = sportsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        sportsCollectionView.hidden = true
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
            self.genderLabel.text = self.userInfo[KEY_GENDER] as? String
            self.ageLabel.text = self.userInfo[KEY_AGE] as? String
            
            print(self.userInfo[KEY_SPORTS] as! [String])
            
            self.sportsCollectionView.reloadData()
            self.sportsCollectionView.hidden = false
            
            //TODO: set sports
            
        }, withCancelBlock: { error in
            print("error")
            print(error.description)
        })
    }
    
    // MARK: ============== COLLECTION VIEW DATA SOURCE ================
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sportsCount = (userInfo[KEY_SPORTS] as? [String])?.count {
            return sportsCount
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sportscell", forIndexPath: indexPath) as! UserProfileSportsColletionViewCell
        if let sportsArr = userInfo[KEY_SPORTS] as? [String] {
            let sport = sportsArr[indexPath.row]
            cell.nameLabel.text = sport
            cell.nameLabel.textColor = UIColor.darkTextColor()
            
        }
        return cell
    }
        
    // MARK: =================================== NAVIGATION ===================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_EDIT_USERPROFILE {
            let controller = segue.destinationViewController as! EditUserProfileViewController
            controller.userInfo = userInfo
            controller.goBackDelegate = self
            controller.selectedSports = userInfo[KEY_SPORTS] as? [String]
        }
    }
    
    // MARK: =================================== DELEGATE FUNCTION ===================================
    func goBack(controller: UIViewController) {
        controller.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: =================================== FACEBOOK PICTURES ===================================
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"cover"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                
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