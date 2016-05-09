
//
//  ConfirmSignUpViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/21/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  If user is signing up, Confirm Sign Up information

import UIKit
import Firebase

class ConfirmSignUpViewController: UIViewController, UITextFieldDelegate {
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    var userData: Dictionary<String, AnyObject>?
    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Populate the text fields for name and gender if they exist
        because the user logged in with an OAuth client
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if let name = userData![KEY_DISPLAY_NAME], gender = userData![KEY_GENDER] {
            nameTextField.text = name as? String
            genderTextField.text = gender as? String
        }
        
        self.hideKeyboardWhenTappedAround()
        nameTextField.delegate = self
        ageTextField.delegate = self
        genderTextField.delegate = self
    }
    
    /*
        Dismiss keyboard when return button pressed
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        Submit user details from the text fields.
        Add in profile info if user logs in with OAuth client
     */
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        if let name = nameTextField.text,
                gender = genderTextField.text,
                age = ageTextField.text
                where age != "" && name != "" && gender != "" {
            
            userData![KEY_DISPLAY_NAME] = name
            userData![KEY_AGE] = age
            userData![KEY_GENDER] = gender
            performSegueWithIdentifier(SEGUE_CHOOSE_SPORTS, sender: userData)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Navigation
    //--------------------------------------------------
    
    /*
        Send user data to Choose Sports Controller to complete 
        profile creation
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! ChooseSportsCollectionViewController
        destinationViewController.userData = sender as! Dictionary<String, AnyObject>?
    }
}
