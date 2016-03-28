//
//  UserProfileViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserProfileViewController :UIViewController {
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportsCollectionView: UICollectionView!
    
    // MARK: =================================== VIEW LIFECYCLE ===================================
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //we force the uid unwrapp because they have a UID from log in
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID)!
        let url = "\(DataService.ds.REF_USERS)/\(uid)"
        let ref = Firebase(url: url)
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            self.nameLabel.text = snapshot.value.objectForKey("name") as? String
            self.genderLabel.text = snapshot.value.objectForKey("gender") as? String
            self.ageLabel.text = snapshot.value.objectForKey("age") as? String
            
            //TODO: set sports
            
        }, withCancelBlock: { error in
            print("error")
            print(error.description)
        })
    }
}