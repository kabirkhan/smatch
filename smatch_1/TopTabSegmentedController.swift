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
    @IBInspectable dynamic public var unselectedBackgroundImage: UIImage? {
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
    
    // image to display inbetween segments
    @IBInspectable dynamic public var segmentDividerImage: UIImage? {
        didSet {
            setupBackground()
        }
    }
    
    func initUI(){
        setupBackground()
        setupFonts()
    }
    
    // update the selected_bg image for color
    func setupBackground(){
        
        self.setBackgroundImage(unselectedBackgroundImage, forState: .Normal, barMetrics: .Default)
        self.setBackgroundImage(selectedBackgroundImage, forState: .Selected, barMetrics: .Default)
        self.backgroundColor = UIColor.materialMainGreen
       
    }
    
    // update for app fonts
    func setupFonts(){
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Highlighted)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Selected)
    }
}