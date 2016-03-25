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
    var userData: Dictionary<String, String>?
    
    // MARK: ===================== OUTLETS =====================
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    // MARK: ===================== VIEW LIFECYCLE =====================
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // populate data from the passed userData
        nameTextField.text = userData![KEY_DISPLAY_NAME] ?? ""
        genderTextField.text = userData![KEY_GENDER] ?? ""
        //ageTextField.text = userData![KEY_AGE]
    }
    
    // MARK: ===================== ACTIONS =====================
    
    // submit user details from the text fields and add in facebook info if user logs in with facebook
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        // unwrap the text values of each text field
        if let name = nameTextField.text, gender = genderTextField.text, age = ageTextField.text where age != "" && name != "" && gender != "" {
            
            let uid = userData?.removeValueForKey(KEY_ID)
            userData![KEY_DISPLAY_NAME] = name
            userData![KEY_AGE] = age
            userData![KEY_GENDER] = gender
            
            
            // This should be moved to Choose Sports when we eventually finish Account Creation
            // add the information from facebook if user logged in with facebook
            if userData![KEY_PROVIDER] == VALUE_FACEBOOK_PROVIDER {
                
                // create user in firebase database
                DataService.ds.createFirebaseUser(uid!, user: userData!)
                
                // set userid in userdefaults to check against
                NSUserDefaults.standardUserDefaults().setValue(uid, forKey: KEY_ID)
            } else if userData![KEY_PROVIDER] == VALUE_EMAIL_PASSWORD_PROVIDER {
                
                DataService.ds.REF_BASE.createUser(userData![KEY_EMAIL], password: userData![KEY_PASSWORD], withValueCompletionBlock: { (error, result) -> Void in
                    if error != nil {
                        self.presentViewController(showErrorAlert("Woah", msg: "Something went really wrong"), animated: true, completion: nil)
                    } else {
                        //set the default key for the user and log them in
                        NSUserDefaults.standardUserDefaults().setValue(result[KEY_ID], forKey: KEY_ID)
                        DataService.ds.REF_BASE.authUser(self.userData![KEY_EMAIL], password: self.userData![KEY_PASSWORD], withCompletionBlock: { (error, authData) in
                            
                            //now that we've created the user we clean up the userdata
                            self.userData?.removeValueForKey(KEY_EMAIL)
                            self.userData?.removeValueForKey(KEY_PASSWORD)
                            
                            //create a user in firebase
                            //(Might need error checking if provider didnt show up.  if it doesnt show up handle errors)
                            DataService.ds.createFirebaseUser(authData.uid, user: self.userData!)
                        })
                        
                    }
                })
                
            }
            
            // segue to the choos sports page
            performSegueWithIdentifier(SEGUE_CHOOSE_SPORTS, sender: nil)
        }
    }
    
    
}
