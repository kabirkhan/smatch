//
//  DataService.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  Handles all major Firebase calls including user 
//  and event queries for posting and getting

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import Firebase

let URL_BASE = "https://smatchfirstdraft.firebaseIO.com"

class DataService {
    
    static let ds = DataService()
    
    private init() {}
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_EVENTS = Firebase(url: "\(URL_BASE)/events")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_EVENTS: Firebase {
        return _REF_EVENTS
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, AnyObject>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    func createEvent(event: Dictionary<String, AnyObject>) -> String {
        let newEventRef = REF_EVENTS.childByAutoId()
        newEventRef.setValue(event)
        return newEventRef.key
    }
    
    func getReferenceForUser(uid: String) -> Firebase {
        return REF_USERS.childByAppendingPath(uid)
    }
    
    func getReferenceForEvent(eventId: String) -> Firebase {
        return REF_EVENTS.childByAppendingPath(eventId)
    }
    
    func getReferenceForEventMessages(eventId: String) -> Firebase {
        return getReferenceForEvent(eventId).childByAppendingPath("/messages")
    }
    
    func getReferenceForEventAttendees(eventId: String) -> Firebase {
        return getReferenceForEvent(eventId).childByAppendingPath("/attendees")
    }
    
    /*
        Handle the user's facebook login
     */
    func loginUsingFacebook(facebookLogin: FBSDKLoginManager,
                            withPermissions permissions: [String],
                            fromViewController viewController: UIViewController,
                                               withCompletionHandler completion: (userData: Dictionary<String, String>?, error: NSError?) -> Void) {
        var error: NSError?
        
        facebookLogin.logInWithReadPermissions(permissions, fromViewController: viewController) { (facebookResult, facebookError) in
            if facebookError != nil {
                error = facebookError
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                // log the user in to firebase
                DataService.ds.REF_BASE.authWithOAuthProvider(VALUE_FACEBOOK_PROVIDER, token: accessToken, withCompletionBlock: { (loginError, authData) -> Void in
                    
                    if loginError != nil {
                        error = loginError
                    } else {
                        var userData = Dictionary<String, String>()
                        userData[KEY_PROVIDER] = VALUE_FACEBOOK_PROVIDER
                        userData[KEY_IMAGE_URL] = authData.providerData[VALUE_PROFILE_IMAGE_URL] as? String
                        userData[KEY_DISPLAY_NAME] = authData.providerData[VALUE_DISPLAY_NAME] as? String
                        userData[KEY_GENDER] = authData.providerData[VALUE_CACHED_USER_PROFILE]![VALUE_GENDER] as? String
                        userData[KEY_ID] = authData.uid
                        completion(userData: userData, error: error)
                    }
                })
            }
        }
    }
    
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
    
    /*
        Get all firebase events from query
     */
    func getFirebaseEvents() {
        
    }
    
    /*
        Given a facebook access token, return the image data 
        for the user's profile pic.
     */
    private func getUserProfileImage(accessToken: NSString) -> NSData {
        let userID = accessToken
        let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
        guard let data = NSData(contentsOfURL: facebookProfileUrl!) else { return NSData() }
        return data
    }
}