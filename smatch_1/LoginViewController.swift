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
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: authData)
                    }
                    
                })
            }
        }
        
    }
    
    // MARK: =================================== Navigation ===================================

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // for testing purposes
        if segue.identifier == SEGUE_LOGGED_IN {
            let destVC = segue.destinationViewController as! ConfirmSignUpViewController
            destVC.authData = sender as! FAuthData?
        }
    }
    

}
