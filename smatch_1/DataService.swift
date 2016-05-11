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
    
    func createFirebaseUser(userID: String, user: Dictionary<String, AnyObject>) {
        REF_USERS.childByAppendingPath(userID).setValue(user)
    }
    
    func createEvent(event: Dictionary<String, AnyObject>) -> String {
        let newEventRef = REF_EVENTS.childByAutoId()
        newEventRef.setValue(event)
        return newEventRef.key
    }
    
    func getReferenceForUser(userID: String) -> Firebase {
        return REF_USERS.childByAppendingPath(userID)
    }
    
    func getReferenceForEvent(eventID: String) -> Firebase {
        return REF_EVENTS.childByAppendingPath(eventID)
    }
    
    func getReferenceForEventMessages(eventID: String) -> Firebase {
        return getReferenceForEvent(eventID).childByAppendingPath("/messages")
    }
    
    func getReferenceForEventAttendees(eventID: String) -> Firebase {
        return getReferenceForEvent(eventID).childByAppendingPath("/attendees")
    }
    
    //--------------------------------------
    // MARK: - Login
    //--------------------------------------
    
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
            } else if facebookResult.isCancelled {
                // Just dismiss view Facebook popup
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                // Log the user in to firebase
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
    
    //--------------------------------------
    // MARK: - User Queries
    //--------------------------------------
    
    /*
        Get all the user's information from Firebase to display in profile screen.
     */
    func getBaseUserInfo(userID: String, completion: (userInfo: Dictionary<String, AnyObject>) -> Void) {
        
        let url = "\(DataService.ds.REF_USERS)/\(userID)"
        let ref = Firebase(url: url)
        var userInfo = Dictionary<String, AnyObject>()
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            userInfo[KEY_DISPLAY_NAME] = snapshot.value.objectForKey("name")
            userInfo["bio"] = snapshot.value.objectForKey("bio")
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
    
    //--------------------------------------
    // MARK: - Event Queries
    //--------------------------------------
    
    /*
        Get all firebase events from query for the user's sports
     */
    func getFirebaseEventsWithUserSports(sports: [String], completion: (events: [Event]?, error: NSError?) -> Void) {
        var events = [Event]()
        var queryError: NSError?
        DataService.ds.REF_EVENTS.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { snapshot in
            if let sport = snapshot.value.objectForKey("sport") {
                for index in sports {
                    if sport as! String == index {
                        events.append(self.createEventFromSnapshot(snapshot))
                    }
                }
                completion(events: events, error: queryError)
            }
            }, withCancelBlock: { error in
                queryError = error
                completion(events: events, error: queryError)
        })
    }
    
    /*
        Get the user's events from their joined_events
     */
    func getEventsFromUserJoinedEvents(events: [String], completion: (events: [Event]?, error: NSError?) -> Void) {
        var userEvents = [Event]()
        var queryError: NSError?
        for eventID in events {
            let singleEventRef = DataService.ds.REF_EVENTS.childByAppendingPath(eventID)
            singleEventRef.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let newEvent = self.createEventFromSnapshot(snapshot)
                userEvents.append(newEvent)
                completion(events: userEvents, error: queryError)
                }, withCancelBlock: { (error) in
                    queryError = error
                    completion(events: userEvents, error: queryError)
            })
        }
    }
    
    /*
        Given event, update it's attendees list
     */
    func updateEventAttendees(event: Event,
                              viewState: EventDetailViewState,
                              userID: String,
                              completion: (event: Event) -> Void) {
    
        var attendees = event.attendees
        var attendeesDict = Dictionary<String, AnyObject>()
        switch viewState {
        case .Creator:
            break
        case .Attendee:
            attendees = attendees.filter() { $0 != userID }
        case .Viewer:
            attendees.append(userID)
        }
        attendeesDict["attendees"] = attendees
        DataService.ds.getReferenceForEvent(event.eventKey).updateChildValues(attendeesDict) { (error, ref) in
            event.attendees = attendees
            completion(event: event)
        }
    }
    
    /*
        Given event, update it's attendees list
     */
    func updateUserJoinedEvents(event: Event,
                                viewState: EventDetailViewState,
                                userID: String,
                                completion: (error: NSError?) -> Void) {
        DataService.ds.getReferenceForUser(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            var joinedEventsDict = Dictionary<String, AnyObject>()
            var joinedEvents = [String]()
            
            if let events = snapshot.value.objectForKey("joined_events") {
                joinedEvents = events as! [String]
            }
            
            switch viewState {
            case .Viewer:
                joinedEvents.append(event.eventKey)
            default:
                joinedEvents = joinedEvents.filter() { $0 != event.eventKey }
            }
            
            joinedEventsDict["joined_events"] = joinedEvents
            
            DataService.ds.getReferenceForUser(userID).updateChildValues(joinedEventsDict, withCompletionBlock: { (error, ref) in
                completion(error: error)
            })
        })
    }
    
    //--------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------
    
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
    
    /*
        Setup an array of Event objects given a snapshot value of the database
     */
    private func createEventFromSnapshot(snapshot: FDataSnapshot) -> Event {
        let eventName = snapshot.value.objectForKey("name") as! String
        let eventKey = snapshot.key
        let eventAddress = snapshot.value.objectForKey("address") as! String
        let eventCompetition = snapshot.value.objectForKey("competition_level") as! String
        let eventDate = snapshot.value.objectForKey("date") as! String
        let eventGender = snapshot.value.objectForKey("gender") as! String
        let eventPlayers = snapshot.value.objectForKey("number_of_players") as! String
        let eventSport = snapshot.value.objectForKey("sport") as! String
        let eventAttendees = snapshot.value.objectForKey("attendees") as! [String]
        let eventCreatorId = snapshot.value.objectForKey("creator_id") as! String
        return Event(title: eventName, eventKey: eventKey, date: eventDate, sport: eventSport, address: eventAddress, numberOfPlayers: eventPlayers, gender: eventGender, competition: eventCompetition, attendees: eventAttendees, creator_id: eventCreatorId)
    }
}