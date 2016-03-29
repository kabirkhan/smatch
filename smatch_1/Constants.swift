//
//  Constants.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation

// MARK: KEYS
let KEY_ID = "uid"
let KEY_PROVIDER = "provider"
let KEY_DISPLAY_NAME = "name"
let KEY_GENDER = "gender"
let KEY_AGE = "age"
let KEY_IMAGE_URL = "image_url"
let KEY_EMAIL = "email"
let KEY_PASSWORD = "password"
let KEY_SPORTS = "sports"


// MARK: VALUES
let VALUE_FACEBOOK_PROVIDER = "facebook"
let VALUE_EMAIL_PASSWORD_PROVIDER = "email_password"
let VALUE_PROFILE_IMAGE_URL = "profileImageURL" // facebook info
let VALUE_DISPLAY_NAME = "displayName"
let VALUE_CACHED_USER_PROFILE = "cachedUserProfile"
let VALUE_GENDER = "gender"
let VALUE_AGE = "age_range"

// MARK: STATUS CODES
let STATUS_ACCOUNT_NONEXIST = -8

// MARK: SEGUES
let SEGUE_ACCOUNT_SETUP = "confirm_account_information"
let SEGUE_CHOOSE_SPORTS = "choose_sports"
let SEGUE_FINISH_SIGNUP_TO_MAIN_SCREEN = "finish_signup_to_main_screen"
let SEGUE_LOGGED_IN = "logged_in"
let SEGUE_EDIT_USERPROFILE = "edit_profile"

// NEW EVENT SEGUES
let SEGUE_NEW_EVENT_TO_NAME_FROM_CHOOSE_SPORT = "new_event_name_and_description"
let SEGUE_NEW_EVENT_TO_LOCATION_FROM_NAME = "new_event_location"
let SEGUE_NEW_EVENT_TO_DATE_FROM_LOCATION = "new_event_date"
let SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE = "new_event_num_players"
let SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS = "new_event_competition"
let SEGUE_NEW_EVENT_TO_GENDER_FROM_COMPETITION = "new_event_gender"
let SEGUE_NEW_EVENT_FINISH_NEW_EVENT = "new_event_finish"

// MARK: CELL IDENTIFIERS
let CELL_IDENTIFIER_FOR_EVENT_CELL = "event_cell"

// MARK: THINGS
var SPORTS: [String] {
    get {
        var sportDict = [String]()
        sportDict.append("Softball")
        sportDict.append("Football")
        sportDict.append("Soccer")
        sportDict.append("Tennis")
        sportDict.append("Basketball")
        sportDict.append("Badminton")
        sportDict.append("Volleyball")
        sportDict.append("Ultimate Frisbee")
        return sportDict
    }
}