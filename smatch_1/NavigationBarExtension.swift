//
//  NavigationBar.swift
//  smatch
//
//  Created by Kabir Khan on 4/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    // remove the shadow on navbar and set it's tint color
    func removeShadowOnBottomOfBarAndSetColorWith(color: UIColor? = nil) {
        setBackgroundImage(UIImage(), forBarMetrics: .Default)
        shadowImage = UIImage()
        if let color = color {
            tintColor = color
            barTintColor = color
            backgroundColor = color
        }
    }
    
    // apply the default shadow for the application and set it's tint color
    func applyDefaultShadow(color: UIColor? = nil) {
        layer.shadowColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.5)
        if let color = color {
            tintColor = color
            barTintColor = color
            backgroundColor = color
        }
    }
    
    // Set the font for the navbar
    func setNavbarFonts() {
        if let font = UIFont(name: NAVBAR_FONT, size: NAVBAR_FONT_SIZE) {
            titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: NAVBAR_FONT_COLOR]
        }
    }
}
