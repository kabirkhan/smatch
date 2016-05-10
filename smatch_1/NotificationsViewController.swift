//
//  NotificationsViewController.swift
//  smatch_1
//
//  Created by Kabir Khan on 5/9/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    /*
        Show alert each time view appears.
        Notifications are coming soon
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let alert = showAlert("Coming Soon!", msg: "Notifications and Push Notifications are coming soon.")
        presentViewController(alert, animated: true, completion: nil)
    }
}
