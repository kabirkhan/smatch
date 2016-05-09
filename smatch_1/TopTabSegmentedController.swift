//
//  TopTabSegmentedController.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/23/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

@IBDesignable public class TopTabSegmentedControl: UISegmentedControl {
    
    // MARK: ==================== Segment Images ====================
    // background image to display when segment is unselected
    @IBInspectable dynamic public var unselectedBackgroundImage: UIImage = UIImage() {
        didSet {
            setupBackground()
        }
    }
    
    // background image to display on selected segment
    @IBInspectable dynamic public var selectedBackgroundImage: UIImage? {
        didSet {
            setupBackground()
        }
    }
    
    @IBInspectable dynamic public var font: UIFont? {
        didSet {
            setFonts()
        }
    }
    
    func initUI(){
        setupBackground()
        setFonts()
        addShadow()
    }
    
    // update the selected_bg image for color
    func setupBackground(){
        self.setBackgroundImage(unselectedBackgroundImage, forState: .Normal, barMetrics: .Default)
        self.setBackgroundImage(selectedBackgroundImage, forState: .Selected, barMetrics: .Default)
        self.backgroundColor = UIColor.materialMainGreen
    }
}

extension TopTabSegmentedControl {
    func addShadow() {
        layer.shadowColor = UIColor.shadowColor.CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }
    
    func setFonts() {
        if let font = UIFont(name: GLOBAL_FONT, size: 12) {
            self.setTitleTextAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: MAIN_LIGHT_FONT_COLOR], forState: .Normal)
        }
    }
}