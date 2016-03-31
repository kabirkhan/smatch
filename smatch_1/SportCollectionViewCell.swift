//
//  SportCollectionViewCell.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/25/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
// Add Information For Icon Image Once Icons Are created

import UIKit

class SportCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    var sport: Sport?
    
    func toggleColor() {
        if nameLabel.textColor == UIColor.materialMainGreen {
            nameLabel.textColor = UIColor.blackColor()
        } else {
            nameLabel.textColor = UIColor.materialMainGreen
        }
    }
}
