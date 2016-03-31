//
//  AlertModel.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
import UIKit

func showErrorAlert(title: String, msg: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(action)
    return alert
}