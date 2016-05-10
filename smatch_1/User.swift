//
//  User.swift
//  smatch_1
//
//  Created by Kabir Khan on 5/9/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  Functions to query firebase and facebook to get user's information

import UIKit
import Firebase
import FBSDKCoreKit
import Alamofire

class User {
    
    static let user = User()
    private init() {}
    
    /*
        Get all the user's information from Firebase to display in profile screen.
     */
    func getBaseUserInfo(userID: String, completion: (userInfo: Dictionary<String, AnyObject>) -> Void) {
        
        let url = "\(DataService.ds.REF_USERS)/\(userID)"
        let ref = Firebase(url: url)
        var userInfo = Dictionary<String, AnyObject>()
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            userInfo[KEY_DISPLAY_NAME] = snapshot.value.objectForKey("name")
            userInfo[KEY_GENDER] = snapshot.value.objectForKey("gender")
            userInfo[KEY_AGE] = snapshot.value.objectForKey("age")
            userInfo[KEY_SPORTS] = snapshot.value.objectForKey("sports")
            
            completion(userInfo: userInfo)
        })
    }
    
    /*
        Get the user's cover photo from facebook using a graph request.
     */
    func getFacebookCoverPhoto(completion: (profileImageData: NSData, coverImageData: NSData) -> Void) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"cover"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if (error != nil) {
                print("Error: \(error)")
            } else {
                
                if let userID: NSString = result.valueForKey("id") as? NSString {
                    let profileData = self.getUserProfileImage(userID)
                    
                    var sourceString: String!
                    let coverPhotoImageURL = "https://graph.facebook.com/\(userID)/?fields=cover&access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
                    Alamofire.request(.GET, coverPhotoImageURL).validate().responseJSON(completionHandler: { (response) -> Void in
                        guard response.result.isSuccess else {
                            print(response.result.error)
                            return
                        }
                        if let JSON = response.result.value {
                            if let info = JSON as? [String: AnyObject]{
                                if let cover = info["cover"] as? [String: AnyObject] {
                                    sourceString = cover["source"] as! String
                                    let facebookCoverURL = NSURL(string: sourceString)
                                    if let coverData = NSData(contentsOfURL: facebookCoverURL!) {
                                        completion(profileImageData: profileData, coverImageData: coverData)
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    private func getUserProfileImage(accessToken: NSString) -> NSData {
        let userID = accessToken
        let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
        guard let data = NSData(contentsOfURL: facebookProfileUrl!) else { return NSData() }
        return data
    }
}