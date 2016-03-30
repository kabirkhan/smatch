//
//  DataService.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
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
        
        // post first message for event
        let newEventMessagesRef = REF_EVENTS.childByAppendingPath(newEventRef.key).childByAppendingPath("messages").childByAutoId() 
        
        let message: Dictionary<NSObject, AnyObject> = ["message_content": "Join Now!", "created_at": String(NSDate().timeIntervalSince1970 * 1000), "sender_id": event["creator_id"]!]
        
        newEventMessagesRef.updateChildValues(message)
        
        // return the key for use in creation file
        return newEventRef.key
    }
}