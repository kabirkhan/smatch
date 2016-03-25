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
    
    func toggleTextColor() {
        if nameLabel.textColor == UIColor.materialMainGreen {
            nameLabel.textColor = UIColor.blackColor()
        } else {
            nameLabel.textColor = UIColor.materialMainGreen
        }
    }
    
//    var sport: Sport? {
//        didSet {
//            if let sport = sport {
//                nameLabel.text = sport.name
//            }
//        }
//    }
}
