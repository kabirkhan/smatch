//
//  ConfirmSignUpViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase

class ConfirmSignUpViewController: UIViewController {

    // MARK: ===================== VARIABLES =====================
    var authData: FAuthData?
    var cachedUserProfile: AnyObject?
    
    // MARK: ===================== OUTLETS =====================
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    // MARK: ===================== VIEW LIFECYCLE =====================
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // set the cached user profile if it exists from facebook login
        if let data = authData?.providerData[VALUE_CACHED_USER_PROFILE] {
            cachedUserProfile = data
        }
        
        // if cachedUserProfile exits prepopulate the the form with that information
        if cachedUserProfile != nil {
            nameTextField.text = authData?.providerData[VALUE_DISPLAY_NAME] as? String
            genderTextField.text = cachedUserProfile![VALUE_GENDER] as? String
            ageTextField.text = cachedUserProfile![VALUE_AGE] as? String
        }
    }
    
    // MARK: ===================== ACTIONS =====================
    
    // submit user details from the text fields and add in facebook info if user logs in with facebook
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        // unwrap the text values of each text field
        if let name = nameTextField.text, gender = genderTextField.text, age = ageTextField.text where age != "" && name != "" && gender != "" {
            
            // construct a user object from the information in the text fields
            var user = [KEY_PROVIDER: VALUE_EMAIL_PASSWORD_PROVIDER,
                        KEY_DISPLAY_NAME: name,
                        KEY_GENDER: gender,
                        KEY_AGE: age]
            
            // add the information from facebook if user logged in with facebook
            if let authData = self.authData {
                user[KEY_PROVIDER] = VALUE_FACEBOOK_PROVIDER
                user[KEY_IMAGE_URL] = authData.providerData[VALUE_PROFILE_IMAGE_URL] as? String
                
                // create user in firebase database
                DataService.ds.createFirebaseUser(authData.uid, user: user)
                
                // set userid in userdefaults to check against
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_ID)
                
                // segue to the choos sports page
                performSegueWithIdentifier(SEGUE_CHOOSE_SPORTS, sender: nil)
            }
        }
    }
    
    
}
