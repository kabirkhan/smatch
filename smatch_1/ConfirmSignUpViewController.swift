
//
//  ConfirmSignUpViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase

class ConfirmSignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: ===================== VARIABLES =====================
    var userData: Dictionary<String, AnyObject>?
    
    // MARK: ===================== OUTLETS =====================
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    // MARK: ===================== VIEW LIFECYCLE =====================
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // populate data from the passed userData
        if let name = userData![KEY_DISPLAY_NAME], gender = userData![KEY_GENDER] {
            nameTextField.text = name as? String
            genderTextField.text = gender as? String
        }
        
        // setup keyboard dismiss on view tap
        self.hideKeyboardWhenTappedAround()
        
        // setup text field delegates to use delegate functions
        nameTextField.delegate = self
        ageTextField.delegate = self
        genderTextField.delegate = self
    }
    
    // MARK: ===================== TEXT FIELD DELEGATE =====================
    
    // dismiss keyboard when return button pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: ===================== ACTIONS =====================
    
    // submit user details from the text fields and add in facebook info if user logs in with facebook
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        // unwrap the text values of each text field
        if let name = nameTextField.text, gender = genderTextField.text, age = ageTextField.text where age != "" && name != "" && gender != "" {
            
            userData![KEY_DISPLAY_NAME] = name
            userData![KEY_AGE] = age
            userData![KEY_GENDER] = gender
            
            // This should be moved to Choose Sports when we eventually finish Account Creation
            // add the information from facebook if user logged in with facebook
                        
            // segue to the choose sports page
            performSegueWithIdentifier(SEGUE_CHOOSE_SPORTS, sender: userData)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! ChooseSportsCollectionViewController
        destinationViewController.userData = sender as! Dictionary<String, AnyObject>?
    }
    
    
}
