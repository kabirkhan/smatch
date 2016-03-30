//
//  LoginViewController.swift
//  smatch
//
//  Created by Kabir Khan on 3/16/16.
//  Copyright © 2016 blueberries. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import TextFieldEffects

class LoginViewController: UIViewController {
    
    // MARK: =================================== OUTLETS ===================================
    
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    // MARK: =================================== ACTIONS ===================================
    
    // Login with facebook when facebook button pressed
    @IBAction func loginWithFacebookPressed(sender: UIButton) {
        
        let facebookLogin = FBSDKLoginManager()
        let permissions = ["public_profile", "email"] // might not need user email
        
        // login with facebook process - NEED TO HANDLE ERRORS (alerts)
        facebookLogin.logInWithReadPermissions(permissions, fromViewController: self) { (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print(facebookError)
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                // log the user in to firebase
                DataService.ds.REF_BASE.authWithOAuthProvider(VALUE_FACEBOOK_PROVIDER, token: accessToken, withCompletionBlock: { (error, authData) -> Void in
                    
                    if error != nil {
                        print(error)
                    } else {
                        var userData = Dictionary<String, String>()
                        userData[KEY_PROVIDER] = VALUE_FACEBOOK_PROVIDER
                        userData[KEY_IMAGE_URL] = authData.providerData[VALUE_PROFILE_IMAGE_URL] as? String
                        userData[KEY_DISPLAY_NAME] = authData.providerData[VALUE_DISPLAY_NAME] as? String
                        userData[KEY_GENDER] = authData.providerData[VALUE_CACHED_USER_PROFILE]![VALUE_GENDER] as? String
                        //userData[KEY_AGE] = authData.providerData[VALUE_CACHED_USER_PROFILE]![VALUE_AGE] as? String
                        userData[KEY_ID] = authData.uid
                        self.performSegueWithIdentifier(SEGUE_ACCOUNT_SETUP, sender: userData)
                    }
                    
                })
            }
        }

    }


    @IBAction func loginSignUpButtonPressed(sender: UIButton) {
        
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
            //try an authenticate a user with the provided email and password
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (error, authData) -> Void in
                if error != nil {
                    //If the User doesn't exist we create an account for them
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        //store the information and segue to the info view
                        var userData = Dictionary<String, String>()
                        userData[KEY_PROVIDER] = VALUE_EMAIL_PASSWORD_PROVIDER
                        userData[KEY_EMAIL] = email
                        userData[KEY_PASSWORD] = pwd
                        self.performSegueWithIdentifier(SEGUE_ACCOUNT_SETUP, sender: userData)
                        
                    } else {
                        //Handle Other Errors
                    }
                } else {
                    //log in suceeded segue to main app
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        } else {
            presentViewController(showErrorAlert("Email and Password are Required", msg: "You must enter both an email and a password!"), animated: true, completion: nil)
        }
    }
    
    // MARK: =================================== NAVIGATION ===================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // for testing purposes
        if segue.identifier == SEGUE_ACCOUNT_SETUP {
            let destVC = segue.destinationViewController as! ConfirmSignUpViewController
            destVC.userData = sender as? Dictionary<String, String>
        }
    }
    
    // MARK: =================================== VIEW LIFECYCLE ===================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if there is already a logged in user, move forward
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
}
