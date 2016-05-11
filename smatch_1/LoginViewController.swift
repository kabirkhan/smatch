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
    @IBOutlet private weak var emailTextField: HoshiTextField!
    @IBOutlet private weak var passwordTextField: HoshiTextField!
    
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
        let permissions = ["public_profile", "email"]
        DataService.ds.loginUsingFacebook(facebookLogin, withPermissions: permissions, fromViewController: self) { (userData, error) in
            if error != nil {
                let alert = showAlert("Error Logging In", msg: "There was an error logging you in. Please try again later")
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                if let data = userData {
                    self.performSegueWithIdentifier(SEGUE_ACCOUNT_SETUP, sender: data)
                }
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
