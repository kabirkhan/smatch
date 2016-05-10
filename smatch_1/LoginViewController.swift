//
//  LoginViewController.swift
//  smatch
//
//  Created by Kabir Khan on 3/16/16.
//  Copyright © 2016 blueberries. All rights reserved.
//
//  Main Login Screen, Handles initial logins for Facebook and
//  Email/Password Login/Signup

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import TextFieldEffects

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        ViewDidLoad - Check if user has a current session and segue them
        to game table view
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) != nil {
            performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
        self.hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    /*
        Dismiss keyboard when the return is button pressed.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        Login user with facebook and request public profile.
     */
    @IBAction func loginWithFacebookPressed(sender: UIButton) {
        
        let facebookLogin = FBSDKLoginManager()
        let permissions = ["public_profile", "email"] // might not need user email
        
        facebookLogin.logInWithReadPermissions(permissions, fromViewController: self) { (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print(facebookError)
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print(FBSDKAccessToken.currentAccessToken().userID)
                
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
                        userData[KEY_ID] = authData.uid
                        self.performSegueWithIdentifier(SEGUE_ACCOUNT_SETUP, sender: userData)
                    }
                })
            }
        }
    }

    /*
        Login user with email and password. Sign up if they are a new user.
     */
    @IBAction func loginWithTwitterButtonPressed(sender: AnyObject) {
        
        let alert = showAlert("Coming Soon!", msg: "Twitter Login is Coming Soon")
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /*
        Login user with email and password. Sign up if they are a new user.
     */
    @IBAction func loginSignUpButtonPressed(sender: UIButton) {
        
        let alert = showAlert("Coming Soon!", msg: "Email and Password Login is Coming Soon")
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    
    /*
        If the user is new, segue them to account setup.
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_ACCOUNT_SETUP {
            let destVC = segue.destinationViewController as! ConfirmSignUpViewController
            destVC.userData = sender as? Dictionary<String, String>
        }
    }
}
