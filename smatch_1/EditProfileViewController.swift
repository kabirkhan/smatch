//
//  EditProfileViewController.swift
//  smatch
//
//  Created by Kabir Khan on 4/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//
//  User can edit their profile information

import UIKit
import CZPicker
import Firebase

class EditProfileViewController: UITableViewController {

    //--------------------------------------
    // MARK: - VARIABLES
    //--------------------------------------
    var userInfo: Dictionary<String, AnyObject>?
    var availableGenders = ["Male", "Female", "Other", "Prefer not to say"]
    var selectedCellToEdit: StaticCellToEdit?
    var goBackDelegate: GoBackDelegate?
    var saveProfileDelegate: SaveProfileDelegate?
    var coverImage: UIImage?
    var profileImage: UIImage?
    
    let imagePickerAlertActionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    var comingSoonAlert = UIAlertController()
    
    enum StaticCellToEdit: String {
        case Birthday = "Birthday"
        case Gender = "Gender"
        case Sports = "Sports"
    }
    
    //--------------------------------------
    // MARK: - OUTLETS
    //--------------------------------------
    @IBOutlet private weak var coverPhoto: UIImageView!
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var bioTextView: UITextView!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var sportsLabel: UILabel!
    
    // Static Cells
    @IBOutlet private weak var editBirthdayCell: UITableViewCell!
    @IBOutlet private weak var editGenderCell: UITableViewCell!
    @IBOutlet private weak var editSportsCell: UITableViewCell!
 
    //--------------------------------------
    // MARK: - VIEW LIFECYCLE
    //--------------------------------------
    
    /*
        Setup Navbar, set textfields for user info.
        Setup ActionController for image changes
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    
        navigationController?.navigationBar.applyDefaultShadow(UIColor.materialMainGreen)
        navigationController?.navigationBar.setNavbarFonts()
        
        if let user = userInfo {
            nameTextField.text = user["name"] as? String
            let gender = user["gender"] as? String
            genderLabel.text = gender?.capitalizedString
            let sports = user["sports"] as! [String]
            sportsLabel.text = sports.joinWithSeparator(", ")
            let bio = user["bio"] as? String
            if let bio = bio {
                bioTextView.text = bio
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        
        let chooseFromPhotos = UIAlertAction(title: "Choose from photos", style: .Default) { (action) in
            self.setupComingSoonAlert()
        }
        
        let takeNewPhoto = UIAlertAction(title: "Take cover photo", style: .Default) { (action) in
            self.setupComingSoonAlert()
        }
        
        imagePickerAlertActionSheetController.addAction(chooseFromPhotos)
        imagePickerAlertActionSheetController.addAction(takeNewPhoto)
        imagePickerAlertActionSheetController.addAction(cancel)
        if let cover = coverImage,
            let profile = profileImage {
            coverPhoto.image = cover
            profilePhoto.image = profile
        }
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    @IBAction func coverPhotoButtonPressed(sender: AnyObject) {
        self.presentViewController(imagePickerAlertActionSheetController, animated: true, completion: nil)
    }
    
    /*
        Save user's new info to firebase and go back to user profile screen
     */
    @IBAction func saveButtonPressed(sender: AnyObject) {
        print(bioTextView.text)
        if let name = nameTextField.text, let bio = bioTextView.text where name != "" {
            print(bioTextView.text)
            userInfo![KEY_DISPLAY_NAME] = name
            userInfo!["bio"] = bio
            let userID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String
            DataService.ds.getReferenceForUser(userID).updateChildValues(userInfo)
        }
        saveProfileDelegate?.saveProfile(self)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        goBackDelegate!.goBack(self)
    }
    
    //--------------------------------------
    // MARK: - HELPER FUNCTIONS
    //--------------------------------------
    private func setupPickerView(title: String) {
        let picker = CZPickerView(headerTitle: title, cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        if selectedCellToEdit == StaticCellToEdit.Sports {
            picker.allowMultipleSelection = true
        }
        picker.delegate = self
        picker.dataSource = self
        picker.headerBackgroundColor = UIColor.materialAmberAccent
        picker.confirmButtonBackgroundColor = UIColor.materialAmberAccent
        picker.show()
    }
    
    private func setupComingSoonAlert() {
        self.comingSoonAlert = showAlert("Coming Soon!", msg: "Photo upload and storage coming soon!!!")
        self.presentViewController(self.comingSoonAlert, animated: true, completion: nil)
    }
}

//--------------------------------------
// MARK: - TABLEVIEW DELEGATE
//--------------------------------------
extension EditProfileViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath {
        case tableView.indexPathForCell(self.editGenderCell)!:
            selectedCellToEdit = StaticCellToEdit.Gender
            break
        case tableView.indexPathForCell(self.editSportsCell)!:
            selectedCellToEdit = StaticCellToEdit.Sports
            break
        default:
            break
        }
        if let cell = selectedCellToEdit where selectedCellToEdit != .Birthday {
            setupPickerView("Edit Your \(cell.rawValue)")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

/*
    Custom Picker view to help with editing user's gender or sport
    depending on cell tapped
 */

//--------------------------------------
// MARK: - CZPICKERVIEW DATASOURCE
//--------------------------------------
extension EditProfileViewController: CZPickerViewDataSource {
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        switch selectedCellToEdit! {
        case StaticCellToEdit.Gender:
            return availableGenders.count
        case StaticCellToEdit.Sports:
            return SPORTS.count
        default:
            return 0
        }
    }
    
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        switch selectedCellToEdit! {
        case StaticCellToEdit.Gender:
            return availableGenders[row]
        case StaticCellToEdit.Sports:
            return SPORTS[row].name
        default:
            return ""
        }
    }
}

//--------------------------------------
// MARK: - CZPickerView DataSource
//--------------------------------------
extension EditProfileViewController: CZPickerViewDelegate {
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        let newGender = availableGenders[row]
        genderLabel.text = newGender
        userInfo!["gender"] = newGender
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        var newSports = [String]()
        if let rows = rows as? [Int] {
            for row in rows {
                newSports.append(SPORTS[row].name)
            }
        }
        sportsLabel.text = newSports.joinWithSeparator(", ")
        userInfo!["sports"] = newSports
    }
}
