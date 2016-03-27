//
//  EventCell.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/24/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class EventCell: UITableViewCell {
    
    @IBOutlet weak var eventMapView: MKMapView!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    @IBAction func joinButttonPressed(sender: UIButton) {
        
    }
}
