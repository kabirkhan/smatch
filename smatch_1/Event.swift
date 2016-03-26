//
//  Event.swift
//  smatch_1
//
//  Created by Lucas Huet-Hudson on 3/26/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import Foundation

class Event: NSObject {
    var description: String?
    var date: String?
    var sport: String?
    var address: String?
    var time: String?
    init (description: description, date: date, sport: sport, address: address, time: time) {
        self.description = description
        self.date = date
        self.sport = sport
        self.address = address
        self.time = time
        super.init()
    }
    //need built in function that takes in location string and returns usable coordinates
}