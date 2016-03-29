//
//  NewEventSportCollectionViewCell.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class NewEventSportCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func toggleTextColor() {
        if nameLabel.textColor == UIColor.materialMainGreen {
            nameLabel.textColor = UIColor.blackColor()
        } else {
            nameLabel.textColor = UIColor.materialMainGreen
        }
    }
}
