//
//  Sports.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/22/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

// structure for a sport to be displayed when the users is asked to select specific sports for their profile
struct Sport {
    let name: String
    let iconImageName: String
    
    init(name: String, iconImageName: String) {
        self.name = name
        self.iconImageName = iconImageName
    }
}
