//
//  Keyboard.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/30/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

/*
    Hide keyboard when the view is tapped anywhere outside the keyboard
 */
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



