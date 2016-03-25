//
//  Colors.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit


// Base Colors to use in project
//
// All colors start with .material
// 
// USAGE: ex. view.backgroundColor = UIColor.materialDarkGreen
//        white color is UIColor.whiteColor
extension UIColor {
    
    // dark green primary color
    static var materialDarkGreen : UIColor {
        get {
            return UIColor(netHex: 0x388E3C)
        }
    }
    
    // bright green main color for project
    static var materialMainGreen : UIColor {
        get {
            return UIColor(netHex: 0x4CAF50)
        }
    }
    
    // light green color, use sparingly
    static var materialLightGreen : UIColor {
        get {
            return UIColor(netHex: 0xC8E6C9)
        }
    }
    
    // Orange/Yellow (i.e Amber) color for all accents
    static var materialAmberAccent : UIColor {
        get {
            return UIColor(netHex: 0xFFC107)
        }
    }
    
    // Dark, near black text color for all text on white backgrounds
    static var materialDarkTextColor : UIColor {
        get {
            return UIColor(netHex: 0x212121)
        }
    }
    
    // Lighter gray text color for secondary text
    static var materialLighterSecondaryTextColor : UIColor {
        get {
            return UIColor(netHex: 0x727272)
        }
    }
    
    // Light gray color used for divisions between elements, backgrounds of tableview
    static var materialDividerColor : UIColor {
        get {
            return UIColor(netHex: 0xE7E7E7)
        }
    }
    
}

// use hex values to create UIColors
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}