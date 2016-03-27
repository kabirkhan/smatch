//
//  Event.swift
//  smatch_1
//
//  Created by Lucas Huet-Hudson on 3/26/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation
import MapKit
import AddressBook
import CoreLocation

class Event: NSObject {
    var descript: String
    var date: String
    var sport: String
    var address: String
    var time: String
    var numberOfPlayers: Int
    
    init (description: String, date: String, sport: String, address: String, time: String, numberOfPlayers: Int) {
        self.descript = description
        self.date = date
        self.sport = sport
        self.address = address
        self.time = time
        self.numberOfPlayers = numberOfPlayers
        super.init()
    }
    let geocoder = CLGeocoder()
    
}