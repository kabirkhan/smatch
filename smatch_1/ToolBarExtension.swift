//
//  ToolBarExtension.swift
//  smatch_1
//
//  Created by Kabir Khan on 5/6/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

extension UIToolbar {

    func setDefaultStyleWithTintColor(color: UIColor? = nil, andBackgroundColor backgroundColor: UIColor? = nil) {
        barStyle = UIBarStyle.Default
        translucent = true
        tintColor = color ?? UIColor.materialMainGreen
        self.backgroundColor = backgroundColor ?? UIColor.whiteColor()
        sizeToFit()
        userInteractionEnabled = true
    }
}