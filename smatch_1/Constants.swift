//
//  Constants.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

// MARK: =================== KEYS ===================
let KEY_ID           = "uid"
let KEY_PROVIDER     = "provider"
let KEY_DISPLAY_NAME = "name"
let KEY_GENDER       = "gender"
let KEY_AGE          = "age"
let KEY_IMAGE_URL    = "image_url"
let KEY_EMAIL        = "email"
let KEY_PASSWORD     = "password"
let KEY_SPORTS       = "sports"

// MARK: =================== VALUES ===================
let VALUE_FACEBOOK_PROVIDER       = "facebook"
let VALUE_EMAIL_PASSWORD_PROVIDER = "email_password"
let VALUE_PROFILE_IMAGE_URL       = "profileImageURL"// facebook info
let VALUE_DISPLAY_NAME            = "displayName"
let VALUE_CACHED_USER_PROFILE     = "cachedUserProfile"
let VALUE_GENDER                  = "gender"
let VALUE_AGE                     = "age_range"

// MARK: =================== STATUS CODES ===================
let STATUS_ACCOUNT_NONEXIST = -8

// MARK: =================== SEGUES ===================
let SEGUE_ACCOUNT_SETUP                = "confirm_account_information"
let SEGUE_CHOOSE_SPORTS                = "choose_sports"
let SEGUE_FINISH_SIGNUP_TO_MAIN_SCREEN = "finish_signup_to_main_screen"
let SEGUE_LOGGED_IN                    = "logged_in"
let SEGUE_EDIT_USERPROFILE             = "edit_profile"
let SEGUE_FROM_MY_EVENTS_TO_DETAIL     = "myevents_to_event_detail"

// MARK: =================== NEW EVENT SEGUES ===================
let SEGUE_NEW_EVENT_TO_NAME_FROM_CHOOSE_SPORT       = "new_event_name_and_description"
let SEGUE_NEW_EVENT_TO_LOCATION_FROM_NAME           = "new_event_location"
let SEGUE_NEW_EVENT_TO_DATE_FROM_LOCATION           = "new_event_date"
let SEGUE_NEW_EVENT_TO_NUM_PLAYERS_FROM_DATE        = "new_event_num_players"
let SEGUE_NEW_EVENT_TO_COMPETITION_FROM_NUM_PLAYERS = "new_event_competition"
let SEGUE_NEW_EVENT_TO_GENDER_FROM_COMPETITION      = "new_event_gender"
let SEGUE_NEW_EVENT_FINISH_NEW_EVENT                = "new_event_finish"
let SEGUE_NEW_EVENT_TO_SPORTS = "new_event_sports"

// MARK: =================== CELL IDENTIFIERS ===================
let CELL_IDENTIFIER_FOR_EVENT_CELL = "event_cell"

// MARK: =================== COLORS ===================
let SHADOW_COLOR: CGFloat = 0.3

// MARK: =================== FONT =====================
let GLOBAL_FONT               = "Avenir"
let GLOBAL_FONT_SIZE: CGFloat = 14
let MAIN_DARK_FONT_COLOR = UIColor.materialDarkTextColor
let MAIN_LIGHT_FONT_COLOR = UIColor.whiteColor()
let NAVBAR_FONT               = "Avenir"
let NAVBAR_FONT_SIZE: CGFloat = 18
let BAR_BUTTON_FONT_SIZE: CGFloat = 16
let NAVBAR_FONT_COLOR = UIColor.whiteColor()

// MARK: =================== AVAILABLE SPORTS ===================

var SPORTS: [Sport] {
    get {
        var sports = [Sport]()
        sports.append(Sport(name: "Soccer", iconImageName: "soccer"))
        sports.append(Sport(name: "Ultimate Frisbee", iconImageName: "frisbee"))
        sports.append(Sport(name: "Basketball", iconImageName: "basketball"))
        sports.append(Sport(name: "Football", iconImageName: "football"))
        sports.append(Sport(name: "Tennis", iconImageName: "tennis"))
        sports.append(Sport(name: "Volleyball", iconImageName: "volleyball"))
        sports.append(Sport(name: "Badminton", iconImageName: "badminton"))
        sports.append(Sport(name: "Softball", iconImageName: "softball"))
        return sports
    }
}